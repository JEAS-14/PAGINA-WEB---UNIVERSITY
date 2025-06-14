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
        session.setAttribute("id_apoderado", 1);  // ID del apoderado en tu BD (ej: Roberto Carlos Sánchez Díaz)
        System.out.println("DEBUG (home_apoderado): Sesión forzada para prueba.");
    }
    // ====================================================================

    // --- Obtener información de la sesión ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idApoderadoObj = session.getAttribute("id_apoderado");
    
    // --- Variables para los datos del apoderado y su hijo ---
    int idApoderado = -1; 
    String nombreApoderado = "Apoderado Desconocido";
    String emailApoderado = (emailSesion != null ? emailSesion : "N/A");
    String telefonoApoderado = "No registrado";
    String ultimoAcceso = "Ahora";

    int idHijo = -1;
    String nombreHijo = "Hijo No Asignado";
    String dniHijo = "N/A";
    String carreraHijo = "Carrera Desconocida";
    String estadoHijo = "N/A";

    int totalCursosHijo = 0;
    int cursosActivosHijo = 0;
    int totalClasesHijo = 0;
    int totalPagosPendientes = 0;

    // Listas para tablas
    List<Map<String, String>> cursosHijoList = new ArrayList<>();
    List<Map<String, String>> pagosPendientesList = new ArrayList<>();

    Connection conn = null; 
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String globalErrorMessage = null; 

    try {
        // --- 1. Validar y obtener ID del Apoderado de Sesión ---
        if (emailSesion == null || !"apoderado".equalsIgnoreCase(rolUsuario) || idApoderadoObj == null) {
            System.out.println("DEBUG (home_apoderado): Sesión inválida o rol incorrecto. Redirigiendo a login.");
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp"); // Ajusta la ruta si es diferente
            return;
        }
        try {
            idApoderado = Integer.parseInt(String.valueOf(idApoderadoObj));
            System.out.println("DEBUG (home_apoderado): ID Apoderado de sesión: " + idApoderado);
        } catch (NumberFormatException e) {
            System.err.println("ERROR (home_apoderado): ID de apoderado en sesión no es un número válido. " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
            return;
        }

        // --- 2. Conectar a la Base de Datos ---
        Conexion c = new Conexion();
        conn = c.conecta();
        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }
        System.out.println("DEBUG (home_apoderado): Conexión a BD establecida.");

        // --- 3. Obtener Datos Principales del Apoderado ---
        PreparedStatement pstmtApoderado = null;
        ResultSet rsApoderado = null;
        try {
            String sqlApoderado = "SELECT nombre, apellido_paterno, apellido_materno, email, telefono "
                                 + "FROM apoderados WHERE id_apoderado = ?";
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
                emailApoderado = rsApoderado.getString("email");
                telefonoApoderado = rsApoderado.getString("telefono") != null ? rsApoderado.getString("telefono") : "No registrado";
                System.out.println("DEBUG (home_apoderado): Datos de apoderado cargados: " + nombreApoderado);
            } else {
                globalErrorMessage = "Apoderado no encontrado en la base de datos.";
                System.err.println("ERROR (home_apoderado): Apoderado con ID " + idApoderado + " no encontrado en BD.");
                // Si el apoderado no existe, redirigir
                response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp?error=apoderado_no_encontrado");
                return;
            }
        } finally {
            cerrarRecursos(rsApoderado, pstmtApoderado);
        }

        // --- 4. Obtener Datos del Hijo (Primer hijo asociado al apoderado) ---
        PreparedStatement pstmtHijo = null;
        ResultSet rsHijo = null;
        try {
            String sqlHijo = "SELECT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, c.nombre_carrera, a.estado "
                             + "FROM alumnos a "
                             + "JOIN alumno_apoderado aa ON a.id_alumno = aa.id_alumno "
                             + "JOIN carreras c ON a.id_carrera = c.id_carrera "
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
                dniHijo = rsHijo.getString("dni") != null ? rsHijo.getString("dni") : "N/A";
                carreraHijo = rsHijo.getString("nombre_carrera") != null ? rsHijo.getString("nombre_carrera") : "Desconocida";
                estadoHijo = rsHijo.getString("estado") != null ? rsHijo.getString("estado") : "N/A";
                System.out.println("DEBUG (home_apoderado): Datos del hijo cargados: " + nombreHijo);
            } else {
                globalErrorMessage = "No se encontró un hijo asociado a este apoderado.";
                System.err.println("ERROR (home_apoderado): No se encontró hijo para apoderado ID: " + idApoderado);
            }
        } finally {
            cerrarRecursos(rsHijo, pstmtHijo);
        }

        // --- 5. Obtener Estadísticas del Hijo (si hay un hijo asignado) ---
        if (idHijo != -1) {
            // Total Cursos del Hijo
            PreparedStatement pstmtCursosHijo = null;
            ResultSet rsCursosHijo = null;
            try {
                String sqlCountCursosHijo = "SELECT COUNT(DISTINCT cl.id_curso) AS total "
                                            + "FROM inscripciones i "
                                            + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                            + "WHERE i.id_alumno = ? AND i.estado = 'inscrito'";
                pstmtCursosHijo = conn.prepareStatement(sqlCountCursosHijo);
                pstmtCursosHijo.setInt(1, idHijo);
                rsCursosHijo = pstmtCursosHijo.executeQuery();
                if (rsCursosHijo.next()) {
                    totalCursosHijo = rsCursosHijo.getInt("total");
                }
                System.out.println("DEBUG (home_apoderado): Total Cursos Hijo: " + totalCursosHijo);
            } finally {
                cerrarRecursos(rsCursosHijo, pstmtCursosHijo);
            }

            // Cursos Activos del Hijo (se puede mejorar la lógica para definir 'activo' de un curso para un alumno)
            PreparedStatement pstmtCursosActivosHijo = null;
            ResultSet rsCursosActivosHijo = null;
            try {
                String sqlCursosActivosHijo = "SELECT COUNT(DISTINCT cl.id_curso) AS total "
                                              + "FROM inscripciones i "
                                              + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                              + "WHERE i.id_alumno = ? AND i.estado = 'inscrito' AND cl.estado = 'activo'"; // Clases activas
                pstmtCursosActivosHijo = conn.prepareStatement(sqlCursosActivosHijo);
                pstmtCursosActivosHijo.setInt(1, idHijo);
                rsCursosActivosHijo = pstmtCursosActivosHijo.executeQuery();
                if (rsCursosActivosHijo.next()) {
                    cursosActivosHijo = rsCursosActivosHijo.getInt("total");
                }
                System.out.println("DEBUG (home_apoderado): Cursos Activos Hijo: " + cursosActivosHijo);
            } finally {
                cerrarRecursos(rsCursosActivosHijo, pstmtCursosActivosHijo);
            }

            // Total Clases Matriculadas por el Hijo (cuenta clases, no cursos)
            PreparedStatement pstmtTotalClasesHijo = null;
            ResultSet rsTotalClasesHijo = null;
            try {
                String sqlTotalClasesHijo = "SELECT COUNT(*) AS total FROM inscripciones WHERE id_alumno = ? AND estado = 'inscrito'";
                pstmtTotalClasesHijo = conn.prepareStatement(sqlTotalClasesHijo);
                pstmtTotalClasesHijo.setInt(1, idHijo);
                rsTotalClasesHijo = pstmtTotalClasesHijo.executeQuery();
                if (rsTotalClasesHijo.next()) {
                    totalClasesHijo = rsTotalClasesHijo.getInt("total");
                }
                 System.out.println("DEBUG (home_apoderado): Total Clases Hijo (inscripciones): " + totalClasesHijo);
            } finally {
                cerrarRecursos(rsTotalClasesHijo, pstmtTotalClasesHijo);
            }

            // Pagos Pendientes del Hijo
            PreparedStatement pstmtPagos = null;
            ResultSet rsPagos = null;
            try {
                String sqlPagos = "SELECT id_pago, concepto, monto, fecha_vencimiento, estado "
                                + "FROM pagos WHERE id_alumno = ? AND estado = 'pendiente'";
                pstmtPagos = conn.prepareStatement(sqlPagos);
                pstmtPagos.setInt(1, idHijo);
                rsPagos = pstmtPagos.executeQuery();
                while(rsPagos.next()) {
                    Map<String, String> pago = new HashMap<>();
                    pago.put("id_pago", String.valueOf(rsPagos.getInt("id_pago")));
                    pago.put("concepto", rsPagos.getString("concepto"));
                    pago.put("monto", String.valueOf(rsPagos.getDouble("monto")));
                    pago.put("fecha_vencimiento", rsPagos.getDate("fecha_vencimiento").toString());
                    pago.put("estado", rsPagos.getString("estado"));
                    pagosPendientesList.add(pago);
                }
                totalPagosPendientes = pagosPendientesList.size();
                System.out.println("DEBUG (home_apoderado): Pagos pendientes: " + totalPagosPendientes);
            } finally {
                cerrarRecursos(rsPagos, pstmtPagos);
            }
            
            // Lista de Cursos del Hijo para tabla
            PreparedStatement pstmtCursosHijoList = null;
            ResultSet rsCursosHijoList = null;
            try {
                String sqlCursosHijoList = "SELECT cu.nombre_curso, cl.seccion, cl.semestre, cl.año_academico "
                                        + "FROM inscripciones i "
                                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                        + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                        + "WHERE i.id_alumno = ? AND i.estado = 'inscrito' "
                                        + "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso";
                pstmtCursosHijoList = conn.prepareStatement(sqlCursosHijoList);
                pstmtCursosHijoList.setInt(1, idHijo);
                rsCursosHijoList = pstmtCursosHijoList.executeQuery();
                while(rsCursosHijoList.next()) {
                    Map<String, String> curso = new HashMap<>();
                    curso.put("nombre_curso", rsCursosHijoList.getString("nombre_curso"));
                    curso.put("seccion", rsCursosHijoList.getString("seccion"));
                    curso.put("semestre", rsCursosHijoList.getString("semestre"));
                    curso.put("anio", String.valueOf(rsCursosHijoList.getInt("año_academico")));
                    cursosHijoList.add(curso);
                }
                System.out.println("DEBUG (home_apoderado): Cursos de hijo listados: " + cursosHijoList.size());
            } finally {
                cerrarRecursos(rsCursosHijoList, pstmtCursosHijoList);
            }

        } // Fin de if (idHijo != -1)
        
        // --- Obtener la fecha y hora actual para "Último acceso" ---
        ultimoAcceso = LocalDateTime.now().format(DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM 'de'yyyy, HH:mm"));

    } catch (SQLException e) {
        globalErrorMessage = "Error de base de datos: " + e.getMessage();
        System.err.println("ERROR (home_apoderado) SQL Principal: " + globalErrorMessage);
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        globalErrorMessage = "Error de configuración: Driver JDBC no encontrado.";
        System.err.println("ERROR (home_apoderado) DRIVER Principal: " + globalErrorMessage);
        e.printStackTrace();
    } finally {
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
    <title>Dashboard Apoderado | UNI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
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

        .apoderado-info, .hijo-info { /* Clases para las tarjetas de info */
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--primary-color);
        }

        .apoderado-info h3, .hijo-info h3, .content-section h3 {
            color: var(--primary-color);
            margin-bottom: 1.5rem;
            font-weight: bold;
        }

        .apoderado-info p, .hijo-info p {
            margin-bottom: 0.5rem;
        }

        .apoderado-info strong, .hijo-info strong {
            color: var(--dark-color);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-bottom: 4px solid var(--accent-color);
            transition: transform 0.3s ease-in-out;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card .value {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--secondary-color);
            margin-bottom: 0.5rem;
        }

        .stat-card .description {
            font-size: 0.9rem;
            color: #666;
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
            vertical-align: top;
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

        /* Acciones Rápidas */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .action-card {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-bottom: 4px solid var(--secondary-color);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.08);
        }

        .action-card i {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1rem;
        }

        .action-card h4 {
            color: var(--primary-color);
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .action-card p {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 1.5rem;
        }

        .action-btn {
            display: inline-block;
            background-color: var(--primary-color);
            color: white;
            padding: 0.6rem 1.2rem;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.3s ease;
        }

        .action-btn:hover {
            background-color: var(--accent-color);
            color: white;
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

            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreApoderado %></p>
            <p><%= emailApoderado %></p>
            <p>Apoderado</p>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>

    <div class="main-wrapper"> 
        <div class="sidebar">
            <ul>
                <li><a href="home_apoderado.jsp" class="active">Inicio</a></li>
                <li><a href="cursos_apoderado.jsp">Cursos de mi hijo</a></li>
                <li><a href="asistencia_apoderado.jsp">Asistencia de mi hijo</a></li>
                <li><a href="notas_apoderado.jsp">Notas de mi hijo</a></li>
                <li><a href="pagos_apoderado.jsp">Pagos y Mensualidades</a></li>
                <li><a href="mensajes_apoderado.jsp">Mensajes</a></li>
            </ul>
        </div>

        <div class="main-content">
            <div class="welcome-section">
                <h1>Bienvenido, <%= nombreApoderado %></h1>
                <p>Este es su panel de apoderado. Aquí puede ver un resumen de la información académica y financiera de su hijo.</p>
            </div>

            <% if (globalErrorMessage != null) { %>
                <div class="alert-message">
                    <i class="fas fa-exclamation-triangle"></i> <%= globalErrorMessage %>
                </div>
            <% } %>

            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Cursos del Hijo</h3>
                    <div class="value"><%= totalCursosHijo %></div>
                    <div class="description">Cursos inscritos</div>
                </div>
                <div class="stat-card">
                    <h3>Clases Activas</h3>
                    <div class="value"><%= cursosActivosHijo %></div>
                    <div class="description">Clases en curso</div>
                </div>
                <div class="stat-card">
                    <h3>Pagos Pendientes</h3>
                    <div class="value"><%= totalPagosPendientes %></div>
                    <div class="description">Mensualidades por pagar</div>
                </div>
                <div class="stat-card">
                    <h3>Estado del Hijo</h3>
                    <div class="value"><%= estadoHijo.toUpperCase() %></div>
                    <div class="description">Estado académico</div>
                </div>
            </div>

            <div class="apoderado-info mb-4">
                <h3 class="section-title">Mi Información</h3>
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Nombre completo:</strong> <%= nombreApoderado %></p>
                        <p><strong>Email:</strong> <%= emailApoderado %></p>
                        <p><strong>Teléfono:</strong> <%= telefonoApoderado %></p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Último acceso:</strong> <%= ultimoAcceso %></p>
                        <p><strong>Rol:</strong> Apoderado</p>
                        </div>
                </div>
            </div>

            <div class="hijo-info mb-4">
                <h3 class="section-title">Información de mi Hijo: <%= nombreHijo %></h3>
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>DNI:</strong> <%= dniHijo %></p>
                        <p><strong>Carrera:</strong> <%= carreraHijo %></p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Estado Académico:</strong> <%= estadoHijo.toUpperCase() %></p>
                        <p><strong>Total Clases:</strong> <%= totalClasesHijo %></p>
                    </div>
                </div>
            </div>

            <div class="content-section mb-4">
                <h3 class="section-title">Cursos de <%= nombreHijo %></h3>
                <div class="table-responsive">
                    <% if (!cursosHijoList.isEmpty()) { %>
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Curso</th>
                                <th>Sección</th>
                                <th>Semestre</th>
                                <th>Año</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> curso : cursosHijoList) {%>
                            <tr>
                                <td><%= curso.get("nombre_curso") %></td>
                                <td><%= curso.get("seccion") %></td>
                                <td><%= curso.get("semestre") %></td>
                                <td><%= curso.get("anio") %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <p class="text-muted">No hay cursos inscritos para su hijo/a actualmente.</p>
                    <% } %>
                </div>
            </div>

            <div class="content-section mb-4">
                <h3 class="section-title">Pagos Pendientes de <%= nombreHijo %></h3>
                <div class="table-responsive">
                    <% if (!pagosPendientesList.isEmpty()) { %>
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Concepto</th>
                                <th>Monto</th>
                                <th>Fecha Vencimiento</th>
                                <th>Estado</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> pago : pagosPendientesList) {%>
                            <tr>
                                <td><%= pago.get("concepto") %></td>
                                <td>S/. <%= pago.get("monto") %></td>
                                <td><%= pago.get("fecha_vencimiento") %></td>
                                <td><span class="badge bg-warning"><%= pago.get("estado").toUpperCase() %></span></td>
                                <td>
                                    <button onclick="alert('Funcionalidad de pago para <%= pago.get("concepto") %> por desarrollar.')" 
                                            style="background-color: var(--primary-color); color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">
                                        Pagar
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <p class="text-muted">No hay pagos pendientes para su hijo/a.</p>
                    <% } %>
                </div>
            </div>

            <div class="content-section">
                <h3 class="section-title">Acciones Rápidas</h3>
                <div class="quick-actions">
                    <div class="action-card">
                        <i class="fas fa-clipboard-check"></i>
                        <h4>Ver Asistencia</h4>
                        <p>Consulte el registro de asistencia de su hijo.</p>
                        <a href="asistencia_apoderado.jsp" class="action-btn">Ir ahora</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-graduation-cap"></i>
                        <h4>Ver Notas</h4>
                        <p>Revise las calificaciones de su hijo.</p>
                        <a href="notas_apoderado.jsp" class="action-btn">Ir ahora</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-money-bill-wave"></i>
                        <h4>Historial de Pagos</h4>
                        <p>Consulte los pagos realizados y pendientes.</p>
                        <a href="pagos_apoderado.jsp" class="action-btn">Ver historial</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-envelope"></i>
                        <h4>Mensajes</h4>
                        <p>Revise los mensajes y comunicados importantes.</p>
                        <a href="mensajes_apoderado.jsp" class="action-btn">Ver mensajes</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>