<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDate, java.time.format.TextStyle, java.util.Locale" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%! // Métodos auxiliares o variables globales para el JSP
    // No hay funciones auxiliares globales necesarias en este JSP, pero el bloque se mantiene.
%>

<%
    // --- Variables para la información del profesor logueado ---
    Object idObj = session.getAttribute("id_profesor");
    int idProfesor = -1; // Usamos idProfesor para ser más explícitos
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "No asignada"; // Valor por defecto
    
    if (idObj != null) {
        idProfesor = Integer.parseInt(idObj.toString());
    } else {
        // Si no hay ID de profesor en sesión, redirige al login
        response.sendRedirect(request.getContextPath() + "/Plataforma.jsp"); // Ajusta la ruta a tu página de login
        return; // Termina la ejecución del JSP
    }

    // --- Variables para la lógica de asistencia ---
    String idClaseParam = request.getParameter("id_clase"); 
    String nombreClase = "Clase No Seleccionada";
    String codigoClase = "";
    String aulaClase = "";
    String semestreClase = "";
    String anioAcademicoClase = "";
    
    String fechaActualDisplay = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    String fechaActualDB = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()); // Formato para la BD
    
    // Lista para almacenar las clases del profesor (para la vista inicial)
    List<Map<String, String>> clasesDelProfesor = new ArrayList<>();
    
    // Lista para almacenar los estudiantes de una clase específica (para la toma de asistencia)
    List<Map<String, String>> estudiantesDeClase = new ArrayList<>();
    
    // Mensajes de éxito/error después de guardar
    String mensajeFeedback = "";
    String tipoMensajeFeedback = ""; // 'success' o 'danger'

    // --- Conexión y recursos de DB ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Conexion conexionUtil = new Conexion();
        conn = conexionUtil.conecta();

        // 1. Obtener información básica del profesor (similar a horarios.jsp)
        String sqlProfesor = "SELECT p.nombre, p.apellido_paterno, p.apellido_materno, p.email, f.nombre_facultad as facultad " +
                             "FROM profesores p JOIN facultades f ON p.id_facultad = f.id_facultad " +
                             "WHERE p.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlProfesor);
        pstmt.setInt(1, idProfesor);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido_paterno") +
                             (rs.getString("apellido_materno") != null ? " " + rs.getString("apellido_materno") : "");
            emailProfesor = rs.getString("email");
            facultadProfesor = rs.getString("facultad");
        }
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();

        // --- INICIO LÓGICA DE PROCESAMIENTO POST (Guardar Asistencia) ---
        if ("POST".equalsIgnoreCase(request.getMethod()) && idClaseParam != null && !idClaseParam.isEmpty()) {
            int idClaseGuardar = Integer.parseInt(idClaseParam);
            
            // Re-verificar que esta clase pertenece al profesor logueado antes de guardar
            String sqlCheckClass = "SELECT COUNT(*) FROM clases WHERE id_clase = ? AND id_profesor = ?";
            pstmt = conn.prepareStatement(sqlCheckClass);
            pstmt.setInt(1, idClaseGuardar);
            pstmt.setInt(2, idProfesor);
            rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                mensajeFeedback = "Error: La clase seleccionada no es válida o no le pertenece.";
                tipoMensajeFeedback = "danger";
                response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/asistencia.jsp?mensaje=" + java.net.URLEncoder.encode(mensajeFeedback, "UTF-8") + "&tipo=" + tipoMensajeFeedback);
                return;
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            // Lógica para guardar/actualizar la asistencia
            int registrosAfectados = 0;
            // Necesitamos los id_inscripcion de los alumnos en esta clase para iterar
            String sqlInscripcionesClase = "SELECT id_inscripcion FROM inscripciones WHERE id_clase = ? AND estado = 'inscrito'";
            pstmt = conn.prepareStatement(sqlInscripcionesClase);
            pstmt.setInt(1, idClaseGuardar);
            rs = pstmt.executeQuery();
            
            List<String> idsInscripcionEnForm = new ArrayList<>();
            while(rs.next()) {
                idsInscripcionEnForm.add(String.valueOf(rs.getInt("id_inscripcion")));
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            String sqlInsert = "INSERT INTO asistencia (id_inscripcion, fecha, estado, observaciones) VALUES (?, ?, ?, ?)";
            String sqlUpdate = "UPDATE asistencia SET estado = ?, observaciones = ? WHERE id_inscripcion = ? AND fecha = ?";

            for (String idInscripcion : idsInscripcionEnForm) {
                String estado = request.getParameter("estado_" + idInscripcion);
                String observaciones = request.getParameter("observaciones_" + idInscripcion);
                
                if (estado == null) { // Si el radio button no fue seleccionado, asume ausente
                    estado = "ausente";
                }
                if (observaciones == null) {
                    observaciones = "";
                }

                try {
                    pstmt = conn.prepareStatement(sqlInsert);
                    pstmt.setString(1, idInscripcion);
                    pstmt.setString(2, fechaActualDB); 
                    pstmt.setString(3, estado);
                    pstmt.setString(4, observaciones.isEmpty() ? null : observaciones); // Guarda NULL si está vacío
                    pstmt.executeUpdate();
                    registrosAfectados++;
                } catch (SQLException e) {
                    // Si la inserción falla por clave duplicada (SQLState 23000 o similar para MySQL)
                    if (e.getSQLState().startsWith("23")) { 
                        pstmt = conn.prepareStatement(sqlUpdate);
                        pstmt.setString(1, estado);
                        pstmt.setString(2, observaciones.isEmpty() ? null : observaciones);
                        pstmt.setString(3, idInscripcion);
                        pstmt.setString(4, fechaActualDB);
                        int updatedRows = pstmt.executeUpdate();
                        if (updatedRows > 0) {
                            registrosAfectados++;
                        } else {
                            System.err.println("Advertencia: No se pudo actualizar la asistencia para id_inscripcion " + idInscripcion + " en la fecha " + fechaActualDB + ". Error: " + e.getMessage());
                        }
                    } else {
                        throw e; // Relanza otras excepciones SQL
                    }
                } finally {
                    if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} } // Cerrar después de cada uso
                }
            }
            mensajeFeedback = "Asistencia guardada exitosamente para " + registrosAfectados + " alumnos.";
            tipoMensajeFeedback = "success";

        } // Fin del bloque POST de procesamiento

        // Recuperar mensaje de feedback si viene de una redirección previa
        String mensajeParam = request.getParameter("mensaje");
        String tipoParam = request.getParameter("tipo");
        if (mensajeParam != null && !mensajeParam.isEmpty()) {
            mensajeFeedback = java.net.URLDecoder.decode(mensajeParam, "UTF-8");
            tipoMensajeFeedback = tipoParam != null ? tipoParam : "";
        }

        // --- INICIO LÓGICA DE VISUALIZACIÓN GET (o después de POST) ---
        // Se ejecuta siempre, ya sea GET inicial o después de un POST
        if (idClaseParam == null || idClaseParam.isEmpty()) {
            // Si no se ha seleccionado una clase, listar todas las clases del profesor
            String sqlClasesProfesor = "SELECT cl.id_clase, cu.nombre_curso, cl.seccion, cl.semestre, cl.año_academico, h.aula " +
                                       "FROM clases cl " +
                                       "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                                       "JOIN horarios h ON cl.id_horario = h.id_horario " +
                                       "WHERE cl.id_profesor = ? AND cl.estado = 'activo' " +
                                       "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso, cl.seccion";
            pstmt = conn.prepareStatement(sqlClasesProfesor);
            pstmt.setInt(1, idProfesor);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> clase = new HashMap<>();
                clase.put("id_clase", String.valueOf(rs.getInt("id_clase")));
                clase.put("nombre_curso", rs.getString("nombre_curso"));
                clase.put("seccion", rs.getString("seccion"));
                clase.put("semestre", rs.getString("semestre"));
                clase.put("anio_academico", String.valueOf(rs.getInt("año_academico")));
                clase.put("aula", rs.getString("aula"));
                clasesDelProfesor.add(clase);
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

        } else {
            // Si se ha seleccionado una clase, mostrar sus estudiantes
            int idClaseMostar = Integer.parseInt(idClaseParam); // Usar una variable diferente para evitar conflictos de nombre
            // Obtener detalles de la clase seleccionada
            String sqlDetalleClase = "SELECT cu.nombre_curso, cu.codigo_curso, cl.seccion, h.aula, cl.semestre, cl.año_academico " +
                                     "FROM clases cl " +
                                     "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                                     "JOIN horarios h ON cl.id_horario = h.id_horario " +
                                     "WHERE cl.id_clase = ? AND cl.id_profesor = ?";
            pstmt = conn.prepareStatement(sqlDetalleClase);
            pstmt.setInt(1, idClaseMostar);
            pstmt.setInt(2, idProfesor);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                nombreClase = rs.getString("nombre_curso");
                codigoClase = rs.getString("codigo_curso");
                aulaClase = rs.getString("aula");
                semestreClase = rs.getString("semestre");
                anioAcademicoClase = String.valueOf(rs.getInt("año_academico"));
            } else {
                // Si la clase no pertenece a este profesor o no existe, redirigir
                response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/asistencia.jsp");
                return;
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            // Obtener lista de estudiantes inscritos en la clase seleccionada, incluyendo su asistencia de hoy
            String sqlEstudiantes = "SELECT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, " +
                                    "i.id_inscripcion, sa.estado AS estado_asistencia, sa.observaciones " +
                                    "FROM inscripciones i " +
                                    "JOIN alumnos a ON i.id_alumno = a.id_alumno " +
                                    "LEFT JOIN asistencia sa ON i.id_inscripcion = sa.id_inscripcion AND sa.fecha = ? " + // Usar fecha actual para el LEFT JOIN
                                    "WHERE i.id_clase = ? AND i.estado = 'inscrito' " +
                                    "ORDER BY a.apellido_paterno, a.apellido_materno, a.nombre";
            pstmt = conn.prepareStatement(sqlEstudiantes);
            pstmt.setString(1, fechaActualDB); // Pasar la fecha actual a la consulta
            pstmt.setInt(2, idClaseMostar);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, String> estudiante = new HashMap<>();
                estudiante.put("id_inscripcion", String.valueOf(rs.getInt("id_inscripcion")));
                estudiante.put("dni", rs.getString("dni"));
                estudiante.put("nombre_completo", rs.getString("nombre") + " " +
                                                 rs.getString("apellido_paterno") + " " +
                                                 (rs.getString("apellido_materno") != null ? rs.getString("apellido_materno") : ""));
                estudiante.put("estado_asistencia", rs.getString("estado_asistencia") != null ? rs.getString("estado_asistencia") : "");
                estudiante.put("observaciones", rs.getString("observaciones") != null ? rs.getString("observaciones") : "");
                estudiantesDeClase.add(estudiante);
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

    } catch (Exception e) { // Captura cualquier excepción que ocurra
        System.err.println("ERROR general en asistencia.jsp: " + e.getMessage());
        e.printStackTrace();
        mensajeFeedback = "Ocurrió un error inesperado: " + e.getMessage();
        tipoMensajeFeedback = "danger";
    } finally {
        // Asegurar cierre de recursos
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistencia de Alumnos - Sistema Universitario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
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
        
        .container-fluid { /* Contenedor principal de la aplicación */
            display: flex;
            min-height: calc(100vh - 60px); /* Ajusta para el header */
            padding: 0; /* Elimina padding horizontal */
        }
        
        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 0;
            flex-shrink: 0; /* Evita que el sidebar se encoja */
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
            flex-grow: 1; /* Permite que el contenido principal ocupe el espacio restante */
            padding: 2rem; /* Mantiene el padding interno para el contenido */
            overflow-y: auto; /* Para desplazamiento si el contenido es largo */
        }
        
        .info-card { /* Tarjetas generales de información */
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--secondary-color);
        }
        
        .info-card h1, .info-card h2, .info-card h3 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1rem;
        }

        .profesor-info-card { /* Estilo específico para la info del profesor */
            border-top: 4px solid var(--primary-color);
            border-left: none; /* Anula el border-left de .info-card si aplica */
        }

        .class-list-card { /* Estilo específico para la lista de clases */
            border-top: 4px solid var(--accent-color);
            border-left: none;
        }

        .attendance-form-card { /* Estilo específico para el formulario de asistencia */
            border-top: 4px solid #28a745; /* Verde */
            border-left: none;
        }

        .table-custom {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        
        .table-custom th {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }
        
        .table-custom td {
            padding: 1rem;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }
        
        .table-custom tr:hover {
            background-color: #f8f9fa;
        }
        
        .table-custom tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .table-custom tr:nth-child(even):hover {
            background-color: #f0f0f0;
        }

        .btn-accion {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
        }
        .btn-accion:hover {
            background-color: var(--accent-color);
        }

        /* Estilos de botones de asistencia específicos (radio buttons) */
        .btn-group-asistencia {
            display: flex;
            gap: 5px;
        }
        
        .btn-asistencia {
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s;
            border: 1px solid transparent;
            text-align: center;
        }
        
        .btn-presente { background-color: rgba(40, 167, 69, 0.2); color: #28a745; }
        .btn-ausente { background-color: rgba(220, 53, 69, 0.2); color: #dc3545; }
        .btn-tardanza { background-color: rgba(255, 193, 7, 0.2); color: #ffc107; }
        .btn-justificado { background-color: rgba(0, 123, 255, 0.2); color: #007bff; } /* Añadido justificado */
        
        input[type="radio"] { display: none; }
        
        input[type="radio"]:checked + .btn-presente { background-color: #28a745; color: white; }
        input[type="radio"]:checked + .btn-ausente { background-color: #dc3545; color: white; }
        input[type="radio"]:checked + .btn-tardanza { background-color: #ffc107; color: white; }
        input[type="radio"]:checked + .btn-justificado { background-color: #007bff; color: white; } /* Añadido justificado */

        .form-control-custom { /* Para el input de observaciones */
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .btn-guardar-asistencia {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
            font-weight: 500;
        }
        .btn-guardar-asistencia:hover {
            background-color: var(--accent-color);
        }

        .no-data-message {
            text-align: center;
            padding: 2rem;
            color: #6c757d;
            font-style: italic;
        }

        .logout-btn {
            background-color: var(--accent-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .logout-btn:hover {
            background-color: #990000;
        }

        /* Mensajes de feedback */
        .alert-custom {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border: 1px solid transparent;
            border-radius: 0.25rem;
        }
        .alert-success-custom {
            color: #0f5132;
            background-color: #d1e7dd;
            border-color: #badbcc;
        }
        .alert-danger-custom {
            color: #842029;
            background-color: #f8d7da;
            border-color: #f5c2c7;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreProfesor %></p>
            <p><%= emailProfesor %></p>
            <p><%= facultadProfesor %></p>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>
    
    <div class="container-fluid">
        <div class="sidebar">
            <ul>
                <li><a href="home_profesor.jsp">Inicio</a></li>
                <li><a href="facultad_profesor.jsp">Facultades</a></li>
                <li><a href="carreras_profesor.jsp">Carreras</a></li>
                <li><a href="cursos_profesor.jsp">Cursos</a></li>
                <li><a href="salones_profesor.jsp">Clases</a></li> 
                <li><a href="horarios_profesor.jsp">Horarios</a></li> 
                <li><a href="asistencia_profesor.jsp" class="active">Asistencia</a></li> 
                <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                <li><a href="nota_profesor.jsp">Notas</a></li>
            </ul>
        </div>
        
        <div class="main-content">
            <div class="info-card">
                <h1>Registro de Asistencia</h1>
                <p>Aquí puede tomar o revisar la asistencia de sus alumnos.</p>
            </div>

            <% if (!mensajeFeedback.isEmpty()) { %>
                <div class="alert-custom alert-<%= tipoMensajeFeedback %>-custom" role="alert">
                    <%= mensajeFeedback %>
                </div>
            <% } %>

            <div class="info-card profesor-info-card">
                <h3>Información del Profesor</h3>
                <p><strong>Nombre:</strong> <%= nombreProfesor %></p>
                <p><strong>Email:</strong> <%= emailProfesor %></p>
                <p><strong>Facultad:</strong> <%= facultadProfesor %></p>
            </div>
            
            <% if (idClaseParam == null || idClaseParam.isEmpty()) { %>
                <div class="info-card class-list-card">
                    <h2>Seleccione una Clase para Tomar Asistencia</h2>
                    <% if (clasesDelProfesor.isEmpty()) { %>
                        <p class="no-data-message">No tiene clases asignadas actualmente.</p>
                    <% } else { %>
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Curso</th>
                                    <th>Sección</th>
                                    <th>Semestre</th>
                                    <th>Aula</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, String> clase : clasesDelProfesor) { %>
                                    <tr>
                                        <td><%= clase.get("nombre_curso") %> (<%= clase.get("anio_academico") %>)</td>
                                        <td><%= clase.get("seccion") %></td>
                                        <td><%= clase.get("semestre") %></td>
                                        <td><%= clase.get("aula") %></td>
                                        <td>
                                            <a href="asistencia_profesor.jsp?id_clase=<%= clase.get("id_clase") %>" class="btn-accion">
                                                Tomar Asistencia
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } %>
                </div>
            <% } else { %>
                <div class="info-card attendance-form-card">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                        <h2 class="h5 mb-0 text-primary">Asistencia de <%= nombreClase %> (<%= codigoClase %> - <%= aulaClase %>)</h2>
                        <span class="text-muted"><i class="bi bi-calendar-date"></i> Fecha: <%= fechaActualDisplay %></span>
                    </div>

                    <% if (estudiantesDeClase.isEmpty()) { %>
                        <p class="no-data-message">No hay alumnos inscritos en esta clase o la clase no fue encontrada para su profesor.</p>
                        <div class="text-center mt-4">
                            <a href="asistencia_profesor.jsp" class="btn-accion">Volver a Clases</a>
                        </div>
                    <% } else { %>
                        <form method="post" action="asistencia_profesor.jsp?id_clase=<%= idClaseParam %>"> <input type="hidden" name="fecha_asistencia_db" value="<%= fechaActualDB %>">
                            
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>DNI</th>
                                        <th>Nombre Completo</th>
                                        <th>Estado</th>
                                        <th>Observaciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% int contador = 1; %>
                                    <% for (Map<String, String> estudiante : estudiantesDeClase) { %>
                                        <tr>
                                            <td><%= contador++ %></td>
                                            <td><%= estudiante.get("dni") %></td>
                                            <td><%= estudiante.get("nombre_completo") %></td>
                                            <td>
                                                <div class="btn-group-asistencia">
                                                    <input type="radio" id="presente_<%= estudiante.get("id_inscripcion") %>" 
                                                           name="estado_<%= estudiante.get("id_inscripcion") %>" 
                                                           value="presente" <%= "presente".equals(estudiante.get("estado_asistencia")) ? "checked" : "" %>>
                                                    <label for="presente_<%= estudiante.get("id_inscripcion") %>" 
                                                           class="btn-asistencia btn-presente">P</label>
                                                    
                                                    <input type="radio" id="ausente_<%= estudiante.get("id_inscripcion") %>" 
                                                           name="estado_<%= estudiante.get("id_inscripcion") %>" 
                                                           value="ausente" <%= "ausente".equals(estudiante.get("estado_asistencia")) ? "checked" : "" %>>
                                                    <label for="ausente_<%= estudiante.get("id_inscripcion") %>" 
                                                           class="btn-asistencia btn-ausente">F</label>
                                                    
                                                    <input type="radio" id="tardanza_<%= estudiante.get("id_inscripcion") %>" 
                                                           name="estado_<%= estudiante.get("id_inscripcion") %>" 
                                                           value="tardanza" <%= "tardanza".equals(estudiante.get("estado_asistencia")) ? "checked" : "" %>>
                                                    <label for="tardanza_<%= estudiante.get("id_inscripcion") %>" 
                                                           class="btn-asistencia btn-tardanza">T</label>

                                                    <input type="radio" id="justificado_<%= estudiante.get("id_inscripcion") %>" 
                                                           name="estado_<%= estudiante.get("id_inscripcion") %>" 
                                                           value="justificado" <%= "justificado".equals(estudiante.get("estado_asistencia")) ? "checked" : "" %>>
                                                    <label for="justificado_<%= estudiante.get("id_inscripcion") %>" 
                                                           class="btn-asistencia btn-justificado">J</label>
                                                </div>
                                            </td>
                                            <td>
                                                <input type="text" class="form-control-custom" 
                                                       name="observaciones_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("observaciones") != null ? estudiante.get("observaciones") : "" %>">
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            
                            <div class="text-center mt-4">
                                <button type="submit" class="btn-guardar-asistencia">
                                    Guardar Asistencia
                                </button>
                                <a href="asistencia_profesor.jsp" class="btn-accion ms-2">Volver a Clases</a>
                            </div>
                        </form>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
</body>
</html>