<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.util.Base64" %>
<%@ page session="true" %>

<%
    // Obtener información de la sesión
    String email = (String) session.getAttribute("email");

    // Variables para mensajes y datos
    String mensaje = "";
    String tipoMensaje = "info";
    int idProfesor = 0;
    String nombreProfesor = "";
    String facultadProfesor = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Obtener información del profesor logueado
    try {
        Conexion c = new Conexion();
        conn = c.conecta();
        String sql = "SELECT p.id_profesor, p.nombre, p.apellido_paterno, p.apellido_materno, f.nombre_facultad "
                + "FROM profesores p "
                + "LEFT JOIN facultades f ON p.id_facultad = f.id_facultad "
                + "WHERE p.email = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, email);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            idProfesor = rs.getInt("id_profesor");
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido_paterno")
                    + (rs.getString("apellido_materno") != null ? " " + rs.getString("apellido_materno") : "");
            facultadProfesor = rs.getString("nombre_facultad") != null ? rs.getString("nombre_facultad") : "Sin asignar";
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
        }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
        }
    }

    // Procesar acciones del formulario
    String action = request.getParameter("action");

    try {
        if (conn == null) {
            Conexion c = new Conexion();
            conn = c.conecta();
        }

        // Unirse a un curso (ahora crea una solicitud en solicitudes_cursos)
        if ("unirse".equals(action)) {
            String idCurso = request.getParameter("id_curso");

            if (idCurso != null && idProfesor > 0) {
                // Verificar si ya está inscrito
                String sqlCheckInscrito = "SELECT COUNT(*) as total FROM profesor_curso WHERE id_profesor = ? AND id_curso = ?";
                pstmt = conn.prepareStatement(sqlCheckInscrito);
                pstmt.setInt(1, idProfesor);
                pstmt.setInt(2, Integer.parseInt(idCurso));
                rs = pstmt.executeQuery();
                boolean yaInscrito = false;
                if (rs.next() && rs.getInt("total") > 0) {
                    yaInscrito = true;
                }

                // Verificar si ya hay una solicitud PENDIENTE para este curso y este tipo de acción
                // Usamos el nuevo nombre de tabla y columna
                String sqlCheckPending = "SELECT COUNT(*) as total FROM solicitudes_cursos WHERE id_profesor = ? AND id_curso = ? AND tipo_solicitud = 'UNIRSE' AND estado = 'PENDIENTE'";
                pstmt = conn.prepareStatement(sqlCheckPending);
                pstmt.setInt(1, idProfesor);
                pstmt.setInt(2, Integer.parseInt(idCurso));
                rs = pstmt.executeQuery();
                boolean solicitudPendiente = false;
                if (rs.next() && rs.getInt("total") > 0) {
                    solicitudPendiente = true;
                }

                if (yaInscrito) {
                    mensaje = "Ya estás inscrito en este curso.";
                    tipoMensaje = "warning";
                } else if (solicitudPendiente) {
                    mensaje = "Ya existe una solicitud pendiente para unirte a este curso. Espera la aprobación del administrador.";
                    tipoMensaje = "info";
                } else {
                    // Insertar la solicitud en la nueva tabla
                    String sqlInsertRequest = "INSERT INTO solicitudes_cursos (id_profesor, id_curso, tipo_solicitud, estado) VALUES (?, ?, 'UNIRSE', 'PENDIENTE')";
                    pstmt = conn.prepareStatement(sqlInsertRequest);
                    pstmt.setInt(1, idProfesor);
                    pstmt.setInt(2, Integer.parseInt(idCurso));

                    int result = pstmt.executeUpdate();
                    if (result > 0) {
                        mensaje = "Tu solicitud para unirte al curso ha sido enviada al administrador para su aprobación.";
                        tipoMensaje = "success";
                    } else {
                        mensaje = "Error al enviar la solicitud para unirte al curso.";
                        tipoMensaje = "danger";
                    }
                }
            }
        }

        // Salir de un curso (ahora crea una solicitud en solicitudes_cursos)
        if ("salir".equals(action)) {
            String idCurso = request.getParameter("id_curso");

            if (idCurso != null && idProfesor > 0) {
                // Verificar si ya hay una solicitud PENDIENTE para este curso y este tipo de acción
                // Usamos el nuevo nombre de tabla y columna
                String sqlCheckPending = "SELECT COUNT(*) as total FROM solicitudes_cursos WHERE id_profesor = ? AND id_curso = ? AND tipo_solicitud = 'SALIR' AND estado = 'PENDIENTE'";
                pstmt = conn.prepareStatement(sqlCheckPending);
                pstmt.setInt(1, idProfesor);
                pstmt.setInt(2, Integer.parseInt(idCurso));
                rs = pstmt.executeQuery();
                boolean solicitudPendiente = false;
                if (rs.next() && rs.getInt("total") > 0) {
                    solicitudPendiente = true;
                }

                if (solicitudPendiente) {
                    mensaje = "Ya existe una solicitud pendiente para salir de este curso. Espera la aprobación del administrador.";
                    tipoMensaje = "info";
                } else {
                    // Insertar la solicitud en la nueva tabla
                    String sqlInsertRequest = "INSERT INTO solicitudes_cursos (id_profesor, id_curso, tipo_solicitud, estado) VALUES (?, ?, 'SALIR', 'PENDIENTE')";
                    pstmt = conn.prepareStatement(sqlInsertRequest);
                    pstmt.setInt(1, idProfesor);
                    pstmt.setInt(2, Integer.parseInt(idCurso));

                    int result = pstmt.executeUpdate();
                    if (result > 0) {
                        mensaje = "Tu solicitud para salir del curso ha sido enviada al administrador para su aprobación.";
                        tipoMensaje = "success";
                    } else {
                        mensaje = "Error al enviar la solicitud para salir del curso.";
                        tipoMensaje = "danger";
                    }
                }
            }
        }

    } catch (Exception e) {
        mensaje = "Error de conexión: " + e.getMessage();
        tipoMensaje = "danger";
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema Universitario - Cursos</title>
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

            /* Estilos para las pestañas */
            .nav-tabs {
                border-bottom: 2px solid var(--primary-color);
            }

            .nav-tabs .nav-link {
                color: var(--primary-color);
                border: none;
                padding: 0.75rem 1.5rem;
                font-weight: 500;
            }

            .nav-tabs .nav-link.active {
                color: white;
                background-color: var(--primary-color);
                border-bottom: 2px solid var(--secondary-color);
            }

            .nav-tabs .nav-link:hover {
                border-color: transparent;
                color: var(--accent-color);
            }

            /* Estilos para las tarjetas de cursos */
            .curso-card {
                transition: transform 0.3s, box-shadow 0.3s;
                border: 1px solid #e0e0e0; /* Borde más sutil */
                border-radius: 8px;
                overflow: hidden;
                box-shadow: 0 2px 10px rgba(0,0,0,0.03); /* Sombra más sutil */
                margin-bottom: 1.5rem;
                background-color: rgba(255, 255, 255, 0.95); /* Fondo casi transparente */
            }

            .curso-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 15px rgba(0,0,0,0.08); /* Sombra más sutil al hover */
                border-color: var(--primary-color);
            }

            .curso-imagen {
                height: 180px;
                object-fit: cover;
                background-color: #f0f0f0;
            }

            .curso-imagen-placeholder {
                height: 180px;
                display: flex;
                align-items: center;
                justify-content: center;
                background-color: #f0f0f0;
                color: var(--primary-color);
            }

            .curso-imagen-placeholder i {
                font-size: 3rem;
            }

            .card-body {
                padding: 1.25rem;
                background-color: transparent; /* Fondo transparente */
            }

            .card-title {
                color: var(--primary-color);
                margin-bottom: 0.75rem;
                font-weight: 600;
                opacity: 0.9; /* Ligeramente transparente */
            }

            .badge {
                padding: 0.35em 0.65em;
                font-weight: 500;
                margin-right: 0.5rem;
                border: 1px solid #ddd; /* Borde sutil */
            }

            .badge-primary {
                background-color: transparent; /* Fondo transparente */
                color: var(--primary-color); /* Texto en color primario */
                border: 1px solid var(--primary-color); /* Borde del color primario */
            }

            .badge-creditos {
                background-color: rgba(255, 255, 255, 0.9); /* Fondo blanco semi-transparente */
                color: var(--dark-color); /* Texto oscuro */
                border: 1px solid #ddd; /* Borde gris claro */
            }

            .btn-outline-danger {
                color: var(--accent-color);
                border-color: var(--accent-color);
            }

            .btn-outline-danger:hover {
                background-color: var(--accent-color);
                color: white;
            }

            .btn-primary {
                background-color: transparent; /* Fondo transparente */
                border: 2px solid var(--primary-color); /* Borde del color primario */
                color: var(--primary-color); /* Texto del color primario */
                transition: all 0.3s ease;
            }
            .btn-primary-white {
                background-color: white;
                border: 2px solid #e0e0e0;
                color: var(--dark-color);
                transition: all 0.3s ease;
            }

            .btn-primary-white:hover {
                background-color: #f8f9fa;
                border-color: var(--primary-color);
                color: var(--primary-color);
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            }

            .alert {
                border-radius: 8px;
                padding: 1rem 1.5rem;
            }

            .alert-success {
                background-color: #e8f5e9;
                color: #2e7d32;
                border-left: 4px solid #2e7d32;
            }

            .alert-danger {
                background-color: #ffebee;
                color: #c62828;
                border-left: 4px solid #c62828;
            }

            .alert-warning {
                background-color: #fff8e1;
                color: #f57f17;
                border-left: 4px solid #f57f17;
            }

            .alert-info { /* Added for info messages */
                background-color: #e3f2fd;
                color: #2196f3;
                border-left: 4px solid #2196f3;
            }

            .profesor-info {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-left: 4px solid var(--secondary-color);
            }

            .profesor-info h4 {
                color: var(--primary-color);
                margin-bottom: 0.5rem;
            }

            .profesor-info .text-success {
                color: var(--secondary-color);
                font-size: 2rem;
                font-weight: bold;
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

            @media (max-width: 768px) {
                .container {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    padding: 1rem 0;
                }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="logo">Sistema Universitario</div>
            <div class="user-info">
                <p class="user-name"><%= nombreProfesor%></p>
                <p><%= email%></p>
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
                    <li><a href="cursos_profesor.jsp" class="active">Cursos</a></li>
                    <li><a href="salones_profesor.jsp">Clases</a></li> 
                    <li><a href="horarios_profesor.jsp">Horarios</a></li> 
                    <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                    <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                    <li><a href="nota_profesor.jsp">Notas</a></li>
                </ul>
            </div>

            <div class="main-content">
                <div class="welcome-section">
                    <h1>Gestión de Cursos</h1>
                    <p>Bienvenido al módulo de cursos. Aquí puede ver los cursos asignados y unirse a nuevos cursos disponibles.</p>
                </div>

                <% if (!mensaje.isEmpty()) {%>
                <div class="alert alert-<%= tipoMensaje%>">
                    <%= mensaje%>
                </div>
                <% }%>

                <div class="profesor-info">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h4><i class="bi bi-person-circle"></i> <%= nombreProfesor%></h4>
                            <p><i class="bi bi-building"></i> Facultad: <strong><%= facultadProfesor%></strong></p>
                            <small><%= email%></small>
                        </div>
                        <div style="text-align: right;">
                            <%
                                int totalCursosAsignados = 0;
                                try {
                                    if (conn == null) {
                                        Conexion c = new Conexion();
                                        conn = c.conecta();
                                    }
                                    String sqlCount = "SELECT COUNT(*) as total FROM profesor_curso WHERE id_profesor = ?";
                                    pstmt = conn.prepareStatement(sqlCount);
                                    pstmt.setInt(1, idProfesor);
                                    rs = pstmt.executeQuery();
                                    if (rs.next()) {
                                        totalCursosAsignados = rs.getInt("total");
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            %>
                            <h2 class="text-success"><%= totalCursosAsignados%></h2>
                            <small>Cursos Asignados</small>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 2rem;">
                    <ul class="nav nav-tabs" id="cursosTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="mis-cursos-tab" data-bs-toggle="tab"
                                    data-bs-target="#mis-cursos" type="button" role="tab">
                                Mis Cursos
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="disponibles-tab" data-bs-toggle="tab"
                                    data-bs-target="#disponibles" type="button" role="tab">
                                Cursos Disponibles
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content" id="cursosTabsContent">
                        <div class="tab-pane fade show active" id="mis-cursos" role="tabpanel">
                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 1.5rem;">
                                <%
                                    try {
                                        if (conn == null) {
                                            Conexion c = new Conexion();
                                            conn = c.conecta();
                                        }
                                        String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso, c.creditos, "
                                                + "c.imagen, c.tipo_imagen, pc.fecha_asignacion, "
                                                + "(SELECT estado FROM solicitudes_cursos cr WHERE cr.id_profesor = pc.id_profesor AND cr.id_curso = pc.id_curso AND cr.tipo_solicitud = 'SALIR' ORDER BY fecha_solicitud DESC LIMIT 1) as pending_leave_status "
                                                + "FROM cursos c "
                                                + "JOIN profesor_curso pc ON c.id_curso = pc.id_curso "
                                                + "WHERE pc.id_profesor = ? "
                                                + "ORDER BY c.nombre_curso";
                                        pstmt = conn.prepareStatement(sql);
                                        pstmt.setInt(1, idProfesor);
                                        rs = pstmt.executeQuery();

                                        boolean tieneCursos = false;
                                        while (rs.next()) {
                                            tieneCursos = true;
                                            int idCurso = rs.getInt("id_curso");
                                            String nombreCurso = rs.getString("nombre_curso");
                                            String codigoCurso = rs.getString("codigo_curso");
                                            int creditos = rs.getInt("creditos");
                                            byte[] imagen = rs.getBytes("imagen");
                                            String tipoImagen = rs.getString("tipo_imagen");
                                            String pendingLeaveStatus = rs.getString("pending_leave_status"); // Obtener el estado pendiente de solicitud de salida

                                            String imagenBase64 = "";
                                            if (imagen != null && imagen.length > 0) {
                                                imagenBase64 = "data:" + tipoImagen + ";base64," + Base64.getEncoder().encodeToString(imagen);
                                            }
                                %>
                                <div class="curso-card">
                                    <% if (!imagenBase64.isEmpty()) {%>
                                    <img src="<%= imagenBase64%>" class="curso-imagen" alt="<%= nombreCurso%>">
                                    <% } else { %>
                                    <div class="curso-imagen-placeholder">
                                        <i class="bi bi-book"></i>
                                    </div>
                                    <% }%>
                                    <div class="card-body">
                                        <h5 class="card-title"><%= nombreCurso%></h5>
                                        <p>
                                            <span class="badge badge-primary"><%= codigoCurso%></span>
                                            <span class="badge badge-creditos"><%= creditos%> créditos</span>
                                        </p>
                                        <div style="margin-top: 1rem;">
                                            <% if ("PENDIENTE".equals(pendingLeaveStatus)) { %>
                                            <button class="btn btn-outline-danger" disabled>
                                                Solicitud de salida pendiente
                                            </button>
                                            <% } else {%>
                                            <a href="?action=salir&id_curso=<%= idCurso%>"
                                               class="btn btn-outline-danger"
                                               onclick="return confirm('¿Estás seguro de solicitar salir del curso: <%= nombreCurso%>? Esto requerirá la aprobación del administrador.')">
                                                Solicitar Salir del Curso
                                            </a>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                <%
                                    }

                                    if (!tieneCursos) {
                                %>
                                <div style="grid-column: 1 / -1; text-align: center; padding: 3rem 0;">
                                    <i class="bi bi-book" style="font-size: 3rem; color: #ccc;"></i>
                                    <h4 style="color: #666; margin-top: 1rem;">No tienes cursos asignados</h4>
                                    <p style="color: #999;">Ve a la pestaña "Cursos Disponibles" para unirte a cursos</p>
                                </div>
                                <%
                                    }
                                } catch (Exception e) {
                                %>
                                <div style="grid-column: 1 / -1; background-color: #ffebee; color: #c62828; padding: 1rem; border-radius: 8px; border-left: 4px solid #c62828;">
                                    Error: <%= e.getMessage()%>
                                </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>

                        <div class="tab-pane fade" id="disponibles" role="tabpanel">
                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 1.5rem;">
                                <%
                                    try {
                                        if (conn == null) {
                                            Conexion c = new Conexion();
                                            conn = c.conecta();
                                        }

                                        // Consulta para cursos disponibles, excluyendo los ya asignados y aquellos con solicitudes de unión pendientes
                                        String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso, c.creditos, "
                                                + "c.imagen, c.tipo_imagen, car.nombre_carrera, "
                                                + "(SELECT estado FROM solicitudes_cursos cr WHERE cr.id_profesor = p.id_profesor AND cr.id_curso = c.id_curso AND cr.tipo_solicitud = 'UNIRSE' ORDER BY fecha_solicitud DESC LIMIT 1) as pending_join_status "
                                                + "FROM cursos c "
                                                + "INNER JOIN carreras car ON c.id_carrera = car.id_carrera "
                                                + "INNER JOIN facultades f ON car.id_facultad = f.id_facultad "
                                                + "INNER JOIN profesores p ON p.id_facultad = f.id_facultad "
                                                + "WHERE p.id_profesor = ? "
                                                + "AND c.id_curso NOT IN ("
                                                + "    SELECT pc.id_curso FROM profesor_curso pc WHERE pc.id_profesor = ?"
                                                + ") "
                                                + "ORDER BY c.nombre_curso";

                                        pstmt = conn.prepareStatement(sql);
                                        pstmt.setInt(1, idProfesor);
                                        pstmt.setInt(2, idProfesor);
                                        rs = pstmt.executeQuery();

                                        boolean hayDisponibles = false;
                                        while (rs.next()) {
                                            hayDisponibles = true;
                                            int idCurso = rs.getInt("id_curso");
                                            String nombreCurso = rs.getString("nombre_curso");
                                            String codigoCurso = rs.getString("codigo_curso");
                                            int creditos = rs.getInt("creditos");
                                            String nombreCarrera = rs.getString("nombre_carrera");
                                            byte[] imagen = rs.getBytes("imagen");
                                            String tipoImagen = rs.getString("tipo_imagen");
                                            String pendingJoinStatus = rs.getString("pending_join_status"); // Obtener el estado pendiente de solicitud de unión

                                            String imagenBase64 = "";
                                            if (imagen != null && imagen.length > 0) {
                                                imagenBase64 = "data:" + tipoImagen + ";base64," + Base64.getEncoder().encodeToString(imagen);
                                            }
                                %>
                                <div class="curso-card">
                                    <% if (!imagenBase64.isEmpty()) {%>
                                    <img src="<%= imagenBase64%>" class="curso-imagen" alt="<%= nombreCurso%>">
                                    <% } else { %>
                                    <div class="curso-imagen-placeholder">
                                        <i class="bi bi-book"></i>
                                    </div>
                                    <% }%>
                                    <div class="card-body">
                                        <h5 class="card-title"><%= nombreCurso%></h5>
                                        <p class="text-muted" style="font-size: 0.9em; margin-bottom: 0.5rem;">
                                            <i class="bi bi-building"></i> <%= nombreCarrera%>
                                        </p>
                                        <p>
                                            <span class="badge badge-primary"><%= codigoCurso%></span>
                                            <span class="badge badge-creditos"><%= creditos%> créditos</span>
                                        </p>
                                        <div style="margin-top: 1rem;">
                                            <% if ("PENDIENTE".equals(pendingJoinStatus)) { %>
                                            <button class="btn btn-primary" disabled>
                                                Solicitud de unión pendiente
                                            </button>
                                            <% } else {%>
                                            <a href="?action=unirse&id_curso=<%= idCurso%>"
                                               class="btn btn-primary"
                                               onclick="return confirm('¿Estás seguro de solicitar unirte al curso: <%= nombreCurso%>? Esto requerirá la aprobación del administrador.')">
                                                Solicitar Unirse al Curso
                                            </a>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                <%
                                    }

                                    if (!hayDisponibles) {
                                %>
                                <div style="grid-column: 1 / -1; text-align: center; padding: 3rem 0;">
                                    <i class="bi bi-check-circle" style="font-size: 3rem; color: #4caf50;"></i>
                                    <h4 style="color: #666; margin-top: 1rem;">¡Estás inscrito en todos los cursos disponibles!</h4>
                                    <p style="color: #999;">No hay más cursos de tu facultad disponibles para unirse</p>
                                </div>
                                <%
                                    }
                                } catch (Exception e) {
                                %>
                                <div style="grid-column: 1 / -1; background-color: #ffebee; color: #c62828; padding: 1rem; border-radius: 8px; border-left: 4px solid #c62828;">
                                    <strong>Error:</strong> <%= e.getMessage()%>
                                </div>
                                <%
                                    } finally {
                                        try {
                                            if (rs != null) {
                                                rs.close();
                                            }
                                            if (pstmt != null) {
                                                pstmt.close();
                                            }
                                            if (conn != null) {
                                                conn.close();
                                            }
                                        } catch (SQLException e) {
                                            e.printStackTrace();
                                        }
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>