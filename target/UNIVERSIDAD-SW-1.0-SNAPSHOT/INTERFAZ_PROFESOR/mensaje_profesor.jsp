<%@ page contentType="text:html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page session="true" %>

<%
    // --- VALIDACIÓN DE SESIÓN INICIAL ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idProfesorObj = session.getAttribute("id_profesor");

    // Redirigir si el usuario no está logueado, no es profesor o no tiene un ID de profesor en sesión
    if (emailSesion == null || !"profesor".equalsIgnoreCase(rolUsuario) || idProfesorObj == null) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp"); // Ajusta esta ruta si es diferente
        return;
    }

    // Datos del profesor logueado, obtenidos de la sesión
    int idProfesor = -1; // Usamos 'idProfesor' para toda la lógica
    if (idProfesorObj instanceof Integer) {
        idProfesor = (Integer) idProfesorObj;
    } else {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
        return;
    }

    String nombreProfesor = "";
    String emailProfesor = emailSesion;
    String facultadProfesor = "No Asignada";

    String globalDbErrorMessage = null;

    Conexion conUtil = null;
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conUtil = new Conexion();
        conn = conUtil.conecta();

        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }

        // --- Obtener información detallada del profesor ---
        String sqlProfesorInfo = "SELECT CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', IFNULL(p.apellido_materno, '')) AS nombre_completo, f.nombre_facultad as facultad "
                                 + "FROM profesores p "
                                 + "LEFT JOIN facultades f ON p.id_facultad = f.id_facultad "
                                 + "WHERE p.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlProfesorInfo);
        pstmt.setInt(1, idProfesor);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            nombreProfesor = rs.getString("nombre_completo");
            facultadProfesor = rs.getString("facultad") != null ? rs.getString("facultad") : "No asignada";
        } else {
            globalDbErrorMessage = "No se encontró información detallada para el profesor con ID " + idProfesor + ".";
        }
        if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
        if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }

        // --- Obtener estadísticas generales (si aún son deseadas, aunque para mensajería pura podrían ser eliminadas) ---
        // Retiradas para un enfoque más puro de mensajería, pero puedes reinsertarlas si las necesitas.
        // int totalClases = 0;
        // int totalAlumnos = 0;
        // int totalCapacidadClasesActivas = 0;
        // int totalAlumnosEnClasesActivas = 0;

        // String sqlStats = "SELECT COUNT(DISTINCT cl.id_clase) as total_clases, "
        //                   + "COUNT(DISTINCT i.id_alumno) as total_alumnos_unicos, "
        //                   + "SUM(CASE WHEN cl.estado = 'activo' THEN cl.capacidad_maxima ELSE 0 END) as total_capacidad_clases_activas, "
        //                   + "SUM(CASE WHEN cl.estado = 'activo' THEN (SELECT COUNT(*) FROM inscripciones sub_i WHERE sub_i.id_clase = cl.id_clase AND sub_i.estado = 'inscrito') ELSE 0 END) as total_alumnos_en_clases_activas "
        //                   + "FROM clases cl LEFT JOIN inscripciones i ON cl.id_clase = i.id_clase WHERE cl.id_profesor = ?";
        // pstmt = conn.prepareStatement(sqlStats);
        // pstmt.setInt(1, idProfesor);
        // rs = pstmt.executeQuery();
        // if (rs.next()) {
        //     totalClases = rs.getInt("total_clases");
        //     totalAlumnos = rs.getInt("total_alumnos_unicos");
        //     totalCapacidadClasesActivas = rs.getInt("total_capacidad_clases_activas");
        //     totalAlumnosEnClasesActivas = rs.getInt("total_alumnos_en_clases_activas");
        // }
        // if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
        // if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }


    } catch (SQLException e) {
        globalDbErrorMessage = "Error de base de datos en la carga inicial: " + e.getMessage();
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        globalDbErrorMessage = "Error: No se encontró el driver JDBC de MySQL. Asegúrate de que mysql-connector-java.jar esté en WEB-INF/lib.";
        e.printStackTrace();
    } finally {
        // La conexión 'conn' NO se cierra aquí. Se mantendrá abierta para la tabla de clases
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mensajería del Profesor - Sistema Universitario</title>
    <link rel="icon" type="image/x-icon" href="https://ejemplo.com/favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* CSS completo de tu interfaz */
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
            background-color: #f9f9f9;
            color: var(--dark-color);
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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

        .container {
            display: flex;
            min-height: calc(100vh - 60px);
        }

        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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

        .info-box {
            background-color: #e7f3ff;
            border-left: 4px solid #17a2b8;
            padding: 1rem;
            margin-bottom: 2rem;
            border-radius: 4px;
        }

        .info-box h4 {
            color: #0c5460;
            margin-top: 0;
        }

        .info-box p {
            color: #0c5460;
            margin-bottom: 0;
        }

        .message-section { /* Sección principal para la tabla de clases o mensajes */
            background-color: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-color);
            margin-bottom: 2rem; /* Added margin for separation */
        }

        .message-section h2 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1.5rem;
        }

        .message-table { /* Tabla para listar clases o mensajes */
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .message-table th {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }

        .message-table td {
            padding: 1rem;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }

        .message-table tr:hover {
            background-color: #f8f9fa;
        }

        .message-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .message-table tr:nth-child(even):hover {
            background-color: #f0f0f0;
        }

        .badge {
            padding: 0.35em 0.65em;
            border-radius: 50rem;
            font-size: 0.75em;
            font-weight: 700;
        }

        .badge-primary {
            background-color: var(--primary-color);
            color: white;
        }
        .badge-success { /* Para estado activo */
            background-color: #28a745;
            color: white;
        }
        .badge-secondary { /* Para estado inactivo/finalizado */
            background-color: #6c757d;
            color: white;
        }
        .badge-info { /* For Unread messages */
            background-color: #17a2b8;
            color: white;
        }
        .badge-read { /* For Read messages */
            background-color: #6c757d;
            color: white;
        }

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

        .no-data {
            text-align: center;
            padding: 3rem;
            color: #666;
            font-style: italic;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                padding: 1rem 0;
            }
            .main-content {
                padding: 1rem;
            }
            .message-table {
                font-size: 0.85rem;
            }
            .message-table th,
            .message-table td {
                padding: 0.75rem 0.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreProfesor%></p>
            <p><%= emailProfesor%></p>
            <p><%= facultadProfesor%></p>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>

    <div class="container">
        <div class="sidebar">
            <ul>
                <li><a href="home_profesor.jsp">Inicio</a></li>
                <li><a href="facultad_profesor.jsp">Facultades</a></li>
                <li><a href="carreras_profesor.jsp">Carreras</a></li>
                <li><a href="cursos_profesor.jsp">Cursos</a></li>
                <li><a href="salones_profesor.jsp">Clases</a></li>
                <li><a href="horarios_profesor.jsp">Horarios</a></li>
                <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                <li><a href="mensaje_profesor.jsp" class="active">Mensajería</a></li>
                <li><a href="nota_profesor.jsp">Notas</a></li>
            </ul>
        </div>

        <div class="main-content">
            <div class="welcome-section">
                <h1>Panel de Mensajería</h1>
                <p>Gestiona los mensajes enviados a tus estudiantes y revisa los mensajes recibidos.</p>
            </div>

            <div class="info-box">
                <h4>ℹ️ Información</h4>
                <p>Utiliza la tabla "Enviar Mensajes por Sección" para comunicarte con grupos específicos de estudiantes. La sección "Mensajes Recibidos" te mostrará las comunicaciones directas hacia ti.</p>
            </div>

            <div class="message-section">
                <h2>Enviar Mensajes por Sección - <%= nombreProfesor%></h2>

                <%
                    PreparedStatement pstmtClases = null;
                    ResultSet rsClases = null;
                    String classesLoadError = null;

                    try {
                        if (conn == null || conn.isClosed()) {
                            // Re-conectar si la conexión se cerró por alguna razón previa
                            Conexion tempCon = new Conexion();
                            conn = tempCon.conecta();
                        }

                        if (conn != null && !conn.isClosed() && idProfesor != -1) {
                            // Consulta para obtener las clases del profesor y el conteo de mensajes ENVIADOS por el profesor a esa clase
                            String sqlClases = "SELECT cl.id_clase, cl.seccion, cl.ciclo, cl.semestre, cl.año_academico, cl.estado AS clase_estado, "
                                               + "cu.nombre_curso, cu.codigo_curso, "
                                               + "(SELECT COUNT(*) FROM inscripciones i WHERE i.id_clase = cl.id_clase AND i.estado = 'inscrito') as alumnos_inscritos, "
                                               + "(SELECT COUNT(DISTINCT m.id_mensaje) FROM mensajes m "
                                               + " INNER JOIN inscripciones ins ON m.id_destinatario = ins.id_alumno "
                                               + " WHERE m.id_remitente = ? AND m.tipo_remitente = 'profesor' AND ins.id_clase = cl.id_clase) as mensajes_enviados_clase "
                                               + "FROM clases cl "
                                               + "INNER JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                               + "WHERE cl.id_profesor = ? AND cl.estado = 'activo' "
                                               + "GROUP BY cl.id_clase, cl.seccion, cl.ciclo, cl.semestre, cl.año_academico, cl.estado, cu.nombre_curso, cu.codigo_curso "
                                               + "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso, cl.seccion";

                            pstmtClases = conn.prepareStatement(sqlClases);
                            pstmtClases.setInt(1, idProfesor); // Parámetro para el subquery de mensajes enviados
                            pstmtClases.setInt(2, idProfesor); // Parámetro para la clase del profesor
                            rsClases = pstmtClases.executeQuery();

                            boolean hayClases = false;
                %>
                <table class="message-table">
                    <thead>
                        <tr>
                            <th>Clase / Sección</th>
                            <th>Curso</th>
                            <th>Período Académico</th>
                            <th>Alumnos Inscritos</th>
                            <th>Mensajes Enviados</th>
                            <th>Estado de Clase</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rsClases.next()) {
                                hayClases = true;
                                String estadoClase = rsClases.getString("clase_estado");
                                String badgeClass = "";
                                if ("activo".equals(estadoClase)) {
                                    badgeClass = "badge-success";
                                } else {
                                    badgeClass = "badge-secondary"; // Should mostly be active due to WHERE clause
                                }
                        %>
                        <tr>
                            <td>
                                <span class="clase-name">Sección: <%= rsClases.getString("seccion")%> - Ciclo: <%= rsClases.getString("ciclo")%></span>
                            </td>
                            <td>
                                <%= rsClases.getString("nombre_curso")%>
                                <br><small class="text-muted">Código: <%= rsClases.getString("codigo_curso")%></small>
                            </td>
                            <td>
                                <%= rsClases.getString("semestre")%> / <%= rsClases.getInt("año_academico")%>
                            </td>
                            <td><%= rsClases.getInt("alumnos_inscritos")%></td>
                            <td><%= rsClases.getInt("mensajes_enviados_clase")%></td>
                            <td><span class="badge <%= badgeClass%>"><%= estadoClase.toUpperCase()%></span></td>
                            <td>
                                <form action="enviar_mensaje_seccion.jsp" method="get" style="display:inline;">
                                    <input type="hidden" name="id_clase" value="<%= rsClases.getInt("id_clase") %>">
                                    <input type="hidden" name="nombre_curso" value="<%= rsClases.getString("nombre_curso") %>">
                                    <input type="hidden" name="seccion" value="<%= rsClases.getString("seccion") %>">
                                    <button type="submit" style="background-color: #007bff; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer;">
                                        <i class="fas fa-paper-plane"></i> Enviar Mensaje
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                            } // Cierre de while

                            if (!hayClases) {
                        %>
                        <tr>
                            <td colspan="7" class="no-data">
                                ✉️ No tienes clases activas para enviar mensajes.
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                            classesLoadError = "No se pudo establecer la conexión a la base de datos o el ID de profesor es inválido para cargar clases.";
                        }
                    } catch (SQLException e) {
                        classesLoadError = "Error de SQL al cargar las clases para mensajería: " + e.getMessage();
                        e.printStackTrace();
                    } catch (ClassNotFoundException e) {
                        classesLoadError = "Error: No se encontró el driver JDBC de MySQL para las clases.";
                        e.printStackTrace();
                    } finally {
                        if (pstmtClases != null) { try { pstmtClases.close(); } catch (SQLException ignore) {} }
                        if (rsClases != null) { try { rsClases.close(); } catch (SQLException ignore) {} }
                    }

                    if (classesLoadError != null) {
                %>
                    <div class="no-data" style="color: red;"><%= classesLoadError %></div>
                <%
                    }
                %>
            </div>

            <div class="message-section">
                <h2>Mensajes Recibidos - <%= nombreProfesor%></h2>
                <%
                    PreparedStatement pstmtMensajesRecibidos = null;
                    ResultSet rsMensajesRecibidos = null;
                    String receivedMessagesError = null;

                    try {
                        if (conn == null || conn.isClosed()) {
                            Conexion tempCon = new Conexion();
                            conn = tempCon.conecta();
                        }

                        if (conn != null && !conn.isClosed() && idProfesor != -1) {
                            String sqlMensajesRecibidos = "SELECT m.id_mensaje, m.asunto, m.contenido, m.fecha_envio, m.leido, "
                                                          + "CASE m.tipo_remitente "
                                                          + "    WHEN 'alumno' THEN CONCAT(a.nombre, ' ', a.apellido_paterno) "
                                                          + "    WHEN 'profesor' THEN CONCAT(p.nombre, ' ', p.apellido_paterno) "
                                                          + "    ELSE 'Administrador/Otro' "
                                                          + "END AS remitente_nombre, "
                                                          + "m.tipo_remitente "
                                                          + "FROM mensajes m "
                                                          + "LEFT JOIN alumnos a ON m.id_remitente = a.id_alumno AND m.tipo_remitente = 'alumno' "
                                                          + "LEFT JOIN profesores p ON m.id_remitente = p.id_profesor AND m.tipo_remitente = 'profesor' "
                                                          + "WHERE m.id_destinatario = ? AND m.tipo_destinatario = 'profesor' "
                                                          + "ORDER BY m.fecha_envio DESC";

                            pstmtMensajesRecibidos = conn.prepareStatement(sqlMensajesRecibidos);
                            pstmtMensajesRecibidos.setInt(1, idProfesor);
                            rsMensajesRecibidos = pstmtMensajesRecibidos.executeQuery();

                            boolean hayMensajesRecibidos = false;
                %>
                <table class="message-table">
                    <thead>
                        <tr>
                            <th>De</th>
                            <th>Asunto</th>
                            <th>Mensaje</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Acción</th> <%-- Para marcar como leído/responder --%>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rsMensajesRecibidos.next()) {
                                hayMensajesRecibidos = true;
                                int idMensaje = rsMensajesRecibidos.getInt("id_mensaje");
                                String remitenteNombre = rsMensajesRecibidos.getString("remitente_nombre");
                                String asuntoMensaje = rsMensajesRecibidos.getString("asunto");
                                String contenidoMensaje = rsMensajesRecibidos.getString("contenido");
                                Timestamp fechaEnvio = rsMensajesRecibidos.getTimestamp("fecha_envio");
                                boolean leido = rsMensajesRecibidos.getBoolean("leido");
                                String tipoRemitente = rsMensajesRecibidos.getString("tipo_remitente");

                                String badgeStatusClass = leido ? "badge-read" : "badge-info";
                                String statusText = leido ? "Leído" : "No Leído";
                        %>
                        <tr>
                            <td><%= remitenteNombre %> (<%= tipoRemitente %>)</td>
                            <td><%= asuntoMensaje %></td>
                            <td><%= contenidoMensaje.length() > 70 ? contenidoMensaje.substring(0, 70) + "..." : contenidoMensaje %></td>
                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(fechaEnvio) %></td>
                            <td><span class="badge <%= badgeStatusClass%>"><%= statusText%></span></td>
                            <td>
                                <% if (!leido) { %>
                                    <form action="marcar_leido_mensaje.jsp" method="post" style="display:inline;">
                                        <input type="hidden" name="id_mensaje" value="<%= idMensaje %>">
                                        <button type="submit" style="background-color: #28a745; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">
                                            Marcar Leído
                                        </button>
                                    </form>
                                <% } %>
                                <%-- Podrías agregar un botón de "Ver Mensaje Completo" o "Responder" aquí --%>
                                <%-- Ejemplo de "Ver Mensaje Completo" con un modal o nueva página --%>
                                <button onclick="alert('Asunto: <%= asuntoMensaje.replace("'", "\\'") %>\nContenido: <%= contenidoMensaje.replace("'", "\\'") %>')"
                                        style="background-color: #17a2b8; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; margin-left: 5px;">
                                    Ver
                                </button>
                            </td>
                        </tr>
                        <%
                            } // Cierre de while

                            if (!hayMensajesRecibidos) {
                        %>
                        <tr>
                            <td colspan="6" class="no-data">
                                Inbox vacío. No hay mensajes recibidos.
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        } else {
                            receivedMessagesError = "No se pudo establecer la conexión a la base de datos o el ID de profesor es inválido para cargar mensajes recibidos.";
                        }
                    } catch (SQLException e) {
                        receivedMessagesError = "Error de SQL al cargar mensajes recibidos: " + e.getMessage();
                        e.printStackTrace();
                    } catch (ClassNotFoundException e) {
                        receivedMessagesError = "Error: No se encontró el driver JDBC de MySQL para mensajes recibidos.";
                        e.printStackTrace();
                    } finally {
                        if (pstmtMensajesRecibidos != null) { try { pstmtMensajesRecibidos.close(); } catch (SQLException ignore) {} }
                        if (rsMensajesRecibidos != null) { try { rsMensajesRecibidos.close(); } catch (SQLException ignore) {} }
                    }

                    if (receivedMessagesError != null) {
                %>
                    <div class="no-data" style="color: red;"><%= receivedMessagesError %></div>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <%
        // Cierre final de la conexión 'conn'
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    %>
</body>
</html>