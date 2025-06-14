<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page session="true" %>

<%!
    // Método para cerrar recursos de BD
    private static void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
            System.err.println("Error cerrando ResultSet: " + e.getMessage());
        }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
            System.err.println("Error cerrando PreparedStatement: " + e.getMessage());
        }
    }
%>

<%
    // ====================================================================
    // 🧪 FORZAR SESIÓN TEMPORALMENTE PARA APODERADO (SOLO PARA TEST)
    // REMOVER ESTE BLOQUE EN PRODUCCIÓN O CUANDO EL LOGIN REAL FUNCIONE
    if (session.getAttribute("id_apoderado") == null) {
        session.setAttribute("email", "roberto.sanchez@gmail.com"); // Email de un apoderado que exista en tu BD (ID 1 en bd_sw)
        session.setAttribute("rol", "apoderado");
        session.setAttribute("id_apoderado", 1);    // ID del apoderado en tu BD (ej: Roberto Carlos Sánchez Díaz)
        System.out.println("DEBUG (pagos_apoderado): Sesión forzada para prueba.");
    }
    // ====================================================================

    // --- Obtener información de la sesión ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idApoderadoObj = session.getAttribute("id_apoderado");
    
    // --- Variables para los datos del apoderado y su hijo ---
    int idApoderado = -1; 
    String nombreApoderado = "Apoderado Desconocido";
    String nombreHijo = "Hijo No Asignado";
    int idHijo = -1;

    List<Map<String, String>> pagosHijoList = new ArrayList<>();

    Connection conn = null;    
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String globalErrorMessage = null;   

    try {
        // --- 1. Validar y obtener ID del Apoderado de Sesión ---
        if (emailSesion == null || !"apoderado".equalsIgnoreCase(rolUsuario) || idApoderadoObj == null) {
            System.out.println("DEBUG (pagos_apoderado): Sesión inválida o rol incorrecto. Redirigiendo a login.");
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp"); // Ajusta la ruta si es diferente
            return;
        }
        try {
            idApoderado = Integer.parseInt(String.valueOf(idApoderadoObj));
            System.out.println("DEBUG (pagos_apoderado): ID Apoderado de sesión: " + idApoderado);
        } catch (NumberFormatException e) {
            System.err.println("ERROR (pagos_apoderado): ID de apoderado en sesión no es un número válido. " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
            return;
        }

        // --- 2. Conectar a la Base de Datos ---
        Conexion c = new Conexion();
        conn = c.conecta();
        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }
        System.out.println("DEBUG (pagos_apoderado): Conexión a BD establecida.");

        // --- 3. Obtener Nombre del Apoderado para el encabezado ---
        PreparedStatement pstmtApoderado = null;
        ResultSet rsApoderado = null;
        try {
            String sqlApoderado = "SELECT nombre, apellido_paterno, apellido_materno FROM apoderados WHERE id_apoderado = ?";
            pstmtApoderado = conn.prepareStatement(sqlApoderado);
            pstmtApoderado.setInt(1, idApoderado);
            rsApoderado = pstmtApoderado.executeQuery();
            if (rsApoderado.next()) {
                String nombre = rsApoderado.getString("nombre") != null ? rsApoderado.getString("nombre") : "";
                String apPaterno = rsApoderado.getString("apellido_paterno") != null ? rsApoderado.getString("apellido_paterno") : "";
                String apMaterno = rsApoderado.getString("apellido_materno") != null ? rsApoderado.getString("apellido_materno") : "";
                nombreApoderado = nombre + " " + apPaterno;
                if (!apMaterno.isEmpty()) {
                    nombreApoderado += " " + apMaterno;
                }
            }
        } finally {
            cerrarRecursos(rsApoderado, pstmtApoderado);
        }

        // --- 4. Obtener ID y Nombre del Hijo ---
        PreparedStatement pstmtHijo = null;
        ResultSet rsHijo = null;
        try {
            String sqlHijo = "SELECT a.id_alumno, a.nombre, a.apellido_paterno, a.apellido_materno "
                             + "FROM alumnos a "
                             + "JOIN alumno_apoderado aa ON a.id_alumno = aa.id_alumno "
                             + "WHERE aa.id_apoderado = ? LIMIT 1"; // Asumimos un hijo por ahora
            pstmtHijo = conn.prepareStatement(sqlHijo);
            pstmtHijo.setInt(1, idApoderado);
            rsHijo = pstmtHijo.executeQuery();
            if (rsHijo.next()) {
                idHijo = rsHijo.getInt("id_alumno");
                String nombre = rsHijo.getString("nombre") != null ? rsHijo.getString("nombre") : "";
                String apPaterno = rsHijo.getString("apellido_paterno") != null ? rsHijo.getString("apellido_paterno") : "";
                String apMaterno = rsHijo.getString("apellido_materno") != null ? rsHijo.getString("apellido_materno") : "";
                nombreHijo = nombre + " " + apPaterno;
                if (!apMaterno.isEmpty()) {
                    nombreHijo += " " + apMaterno;
                }
            } else {
                globalErrorMessage = "No se encontró un hijo asociado a este apoderado.";
                System.err.println("ERROR (pagos_apoderado): No se encontró hijo para apoderado ID: " + idApoderado);
            }
        } finally {
            cerrarRecursos(rsHijo, pstmtHijo);
        }

        // --- 5. Obtener Historial de Pagos del Hijo (si hay un hijo asignado) ---
        if (idHijo != -1) {
            String sqlPagos = "SELECT id_pago, fecha_pago, fecha_vencimiento, concepto, monto, metodo_pago, referencia, estado "
                            + "FROM pagos "
                            + "WHERE id_alumno = ? "
                            + "ORDER BY fecha_vencimiento DESC, fecha_pago DESC";
            
            pstmt = conn.prepareStatement(sqlPagos);
            pstmt.setInt(1, idHijo);
            rs = pstmt.executeQuery();

            while(rs.next()) {
                Map<String, String> pagoRecord = new HashMap<>();
                pagoRecord.put("id_pago", String.valueOf(rs.getInt("id_pago")));
                
                // Corrected handling for fecha_pago
                java.sql.Date fechaPagoSql = rs.getDate("fecha_pago");
                pagoRecord.put("fecha_pago", fechaPagoSql != null ? fechaPagoSql.toString() : "N/A"); 
                
                // Corrected handling for fecha_vencimiento
                java.sql.Date fechaVencimientoSql = rs.getDate("fecha_vencimiento");
                pagoRecord.put("fecha_vencimiento", fechaVencimientoSql != null ? fechaVencimientoSql.toString() : "N/A"); 
                
                pagoRecord.put("concepto", rs.getString("concepto"));
                pagoRecord.put("monto", String.format("%.2f", rs.getDouble("monto")));
                
                String metodoPago = rs.getString("metodo_pago");
                pagoRecord.put("metodo_pago", metodoPago != null && !metodoPago.isEmpty() ? metodoPago : "N/A"); 
                
                String referencia = rs.getString("referencia");
                pagoRecord.put("referencia", referencia != null && !referencia.isEmpty() ? referencia : "N/A"); 
                
                pagoRecord.put("estado", rs.getString("estado").toUpperCase());
                
                pagosHijoList.add(pagoRecord);
            }
            System.out.println("DEBUG (pagos_apoderado): Registros de pagos de hijo listados: " + pagosHijoList.size());
        }

    } catch (SQLException e) {
        globalErrorMessage = "Error de base de datos: " + e.getMessage();
        System.err.println("ERROR (pagos_apoderado) SQL Principal: " + globalErrorMessage);
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        globalErrorMessage = "Error de configuración: Driver JDBC no encontrado.";
        System.err.println("ERROR (pagos_apoderado) DRIVER Principal: " + globalErrorMessage);
        e.printStackTrace();
    } finally {
        cerrarRecursos(rs, pstmt);
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            System.err.println("Error al cerrar conexión final: " + e.getMessage());
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pagos y Mensualidades | Dashboard Apoderado | UNI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        /* Incluir los estilos de home_apoderado.jsp */
        :root {
            --primary-color: #002366; /* Azul universitario oscuro */
            --secondary-color: #FFD700; /* Dorado */
            --accent-color: #800000; /* Granate */
            --light-color: #F5F5F5;
            --dark-color: #333333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--light-color);
            color: var(--dark-color);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            flex-shrink: 0;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--secondary-color);
        }

        .user-info {
            text-align: right;
        }

        .user-info p {
            margin: 0.2rem 0;
            font-size: 0.9rem;
        }

        .user-name {
            font-weight: bold;
            color: var(--secondary-color);
        }

        .main-wrapper {
            display: flex;
            flex: 1;
            width: 100%;
        }

        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 0;
            flex-shrink: 0;
            min-height: 100%;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar li a {
            display: block;
            padding: 0.8rem 1.5rem;
            color: white;
            text-decoration: none;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .sidebar li a:hover {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 4px solid var(--secondary-color);
        }

        .sidebar li a.active {
            background-color: rgba(255, 255, 255, 0.2);
            border-left: 4px solid var(--secondary-color);
            font-weight: bold;
        }

        .main-content {
            flex: 1;
            padding: 2rem;
            overflow-y: auto;
        }

        .welcome-section {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--secondary-color);
        }

        .welcome-section h1 {
            color: var(--primary-color);
            margin-top: 0;
        }

        .content-section { /* Se usa para todas las secciones de contenido */
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--primary-color);
        }

        .content-section h3 {
            color: var(--primary-color);
            margin-bottom: 1.5rem;
            font-weight: bold;
        }

        /* Tablas */
        .table-responsive {
            margin-top: 1rem;
        }

        .table {
            width: 100%;
            margin-bottom: 1rem;
            color: var(--dark-color);
            border-collapse: collapse;
        }

        .table th, .table td {
            padding: 0.75rem;
            vertical-align: middle; /* Alineación vertical para celdas */
            border-top: 1px solid #dee2e6;
        }

        .table thead th {
            vertical-align: bottom;
            border-bottom: 2px solid var(--primary-color);
            color: var(--primary-color);
            font-weight: 600;
            background-color: var(--light-color);
        }

        .table tbody tr:hover {
            background-color: rgba(0, 35, 102, 0.05);
        }

        /* Badge for status */
        .badge-pago {
            padding: 0.35em 0.65em;
            font-size: 0.75em;
            font-weight: 700;
            line-height: 1;
            color: #fff;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: 0.375rem;
        }
        .bg-success { background-color: #198754 !important; } /* Pagado */
        .bg-warning { background-color: #ffc107 !important; color: #000 !important;} /* Pendiente */
        .bg-danger { background-color: #dc3545 !important; } /* Vencido */

        /* Botón de Pagar */
        .btn-pay {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            font-size: 0.85rem;
        }

        .btn-pay:hover {
            background-color: var(--accent-color);
        }

        /* Mensajes de error/info */
        .alert-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c2c7;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }

        /* Botones de logout */
        .logout-btn {
            background-color: var(--accent-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 0.5rem;
            transition: background-color 0.3s;
        }

        .logout-btn:hover {
            background-color: #990000;
        }

        /* Responsividad */
        @media (max-width: 768px) {
            .main-wrapper {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                min-height: auto;
                padding: 1rem 0;
            }

            .header {
                flex-direction: column;
                text-align: center;
            }

            .user-info {
                text-align: center;
                margin-top: 1rem;
            }

            .main-content {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreApoderado %></p>
            <p><%= emailSesion %></p>
            <p>Apoderado</p>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>

    <div class="main-wrapper">    
        <div class="sidebar">
            <ul>
                <li><a href="home_apoderado.jsp">Inicio</a></li>
                <li><a href="cursos_apoderado.jsp">Cursos de mi hijo</a></li>
                <li><a href="asistencia_apoderado.jsp">Asistencia de mi hijo</a></li>
                <li><a href="notas_apoderado.jsp">Notas de mi hijo</a></li>
                <li><a href="pagos_apoderado.jsp" class="active">Pagos y Mensualidades</a></li>
                <li><a href="mensajes_apoderado.jsp">Mensajes</a></li>
            </ul>
        </div>

        <div class="main-content">
            <div class="welcome-section">
                <h1>Pagos y Mensualidades de <%= nombreHijo %></h1>
                <p>Aquí puede ver el historial de todos los pagos de su hijo/a, así como las mensualidades pendientes o vencidas.</p>
            </div>

            <% if (globalErrorMessage != null) { %>
                <div class="alert-message">
                    <i class="fas fa-exclamation-triangle"></i> <%= globalErrorMessage %>
                </div>
            <% } %>

            <div class="content-section mb-4">
                <h3 class="section-title">Historial de Pagos</h3>
                <div class="table-responsive">
                    <% if (!pagosHijoList.isEmpty()) { %>
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Concepto</th>
                                <th>Monto</th>
                                <th>Fecha Vencimiento</th>
                                <th>Fecha Pago</th>
                                <th>Método</th>
                                <th>Referencia</th>
                                <th>Estado</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> pago : pagosHijoList) {%>
                            <tr>
                                <td><%= pago.get("concepto") %></td>
                                <td>S/. <%= pago.get("monto") %></td>
                                <td><%= pago.get("fecha_vencimiento") %></td>
                                <td><%= pago.get("fecha_pago") %></td>
                                <td><%= pago.get("metodo_pago") %></td>
                                <td><%= pago.get("referencia") %></td>
                                <td>
                                    <% 
                                        String estadoPago = pago.get("estado");
                                        String badgeClass = "";
                                        if ("PAGADO".equalsIgnoreCase(estadoPago)) {
                                            badgeClass = "bg-success";
                                        } else if ("PENDIENTE".equalsIgnoreCase(estadoPago)) {
                                            badgeClass = "bg-warning";
                                        } else if ("VENCIDO".equalsIgnoreCase(estadoPago)) {
                                            badgeClass = "bg-danger";
                                        }
                                    %>
                                    <span class="badge badge-pago <%= badgeClass %>"><%= estadoPago %></span>
                                </td>
                                <td>
                                    <% if ("PENDIENTE".equalsIgnoreCase(pago.get("estado")) || "VENCIDO".equalsIgnoreCase(pago.get("estado"))) { %>
                                        <button onclick="alert('Se iniciará el proceso de pago para el concepto: <%= pago.get("concepto") %>. ID de Pago: <%= pago.get("id_pago") %>')"
                                                class="btn-pay">Pagar Ahora</button>
                                    <% } else { %>
                                        <button class="btn-pay" disabled>Pagado</button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <p class="text-muted">No hay registros de pagos disponibles para su hijo/a actualmente.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>