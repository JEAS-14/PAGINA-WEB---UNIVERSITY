<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.ArrayList, java.util.HashMap, java.util.List, java.util.Map" %>
<%@ page session="true" %>

<%!
    // Método para cerrar recursos de BD
    private static void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
            /* Ignorar */ }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
            /* Ignorar */ }
    }
%>

<%
    // --- Obtener información de la sesión ---
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // --- Variables para los datos del profesor ---
    String nombreCompleto = "Usuario";
    String dni = "No disponible";
    String facultad = "Facultad no especificada";
    String telefono = "No registrado";
    String ultimoAcceso = "Ahora";

    int totalCursos = 0;
    int cursosActivos = 0;
    int totalAlumnos = 0;

    // --- Listas para las tablas ---
    List<Map<String, String>> cursosList = new ArrayList<>();
    List<Map<String, String>> alumnosList = new ArrayList<>();

    // --- Datos para gráficos ---
    List<String> nombresCursosNotas = new ArrayList<>();
    List<Double> promediosNotas = new ArrayList<>();
    int totalPresentes = 0;
    int totalAusentes = 0;
    int totalTardanzas = 0;

    Connection conn = null;

    try {
        Conexion c = new Conexion();
        conn = c.conecta();

        // --- 1. Obtener Datos Principales del Profesor ---
        PreparedStatement pstmtProfesor = null;
        ResultSet rsProfesor = null;
        int idProfesor = 0;
        try {
            String sqlProfesor = "SELECT p.id_profesor, p.dni, p.nombre, p.apellido_paterno, "
                    + "p.apellido_materno, p.telefono, f.nombre_facultad "
                    + "FROM profesores p "
                    + "JOIN facultades f ON p.id_facultad = f.id_facultad "
                    + "WHERE p.email = ?";
            pstmtProfesor = conn.prepareStatement(sqlProfesor);
            pstmtProfesor.setString(1, email.trim());
            rsProfesor = pstmtProfesor.executeQuery();

            if (rsProfesor.next()) {
                idProfesor = rsProfesor.getInt("id_profesor");
                String nombre = rsProfesor.getString("nombre") != null ? rsProfesor.getString("nombre") : "";
                String apPaterno = rsProfesor.getString("apellido_paterno") != null ? rsProfesor.getString("apellido_paterno") : "";
                String apMaterno = rsProfesor.getString("apellido_materno") != null ? rsProfesor.getString("apellido_materno") : "";

                nombreCompleto = nombre + " " + apPaterno;
                if (!apMaterno.isEmpty()) {
                    nombreCompleto += " " + apMaterno;
                }

                dni = rsProfesor.getString("dni") != null ? rsProfesor.getString("dni") : "No disponible";
                telefono = rsProfesor.getString("telefono") != null ? rsProfesor.getString("telefono") : "No registrado";
                facultad = rsProfesor.getString("nombre_facultad") != null ? rsProfesor.getString("nombre_facultad") : "Facultad no especificada";

            } else {
                response.sendRedirect("login.jsp?error=profesor_no_encontrado");
                return;
            }
        } finally {
            cerrarRecursos(rsProfesor, pstmtProfesor);
        }

        // --- 2. Obtener Estadísticas y Listas (Solo si el profesor se encontró) ---
        if (idProfesor > 0) {
            // Total Cursos Asignados
            PreparedStatement pstmtTotalCursos = null;
            ResultSet rsTotalCursos = null;
            try {
                String sqlCountCursos = "SELECT COUNT(*) AS total FROM profesor_curso WHERE id_profesor = ?";
                pstmtTotalCursos = conn.prepareStatement(sqlCountCursos);
                pstmtTotalCursos.setInt(1, idProfesor);
                rsTotalCursos = pstmtTotalCursos.executeQuery();
                if (rsTotalCursos.next()) {
                    totalCursos = rsTotalCursos.getInt("total");
                }
            } finally {
                cerrarRecursos(rsTotalCursos, pstmtTotalCursos);
            }

            // Cursos Activos
            PreparedStatement pstmtCursosActivos = null;
            ResultSet rsCursosActivos = null;
            try {
                String sqlCursosActivos = "SELECT COUNT(*) AS total FROM profesor_curso WHERE id_profesor = ? AND estado = 'activo'";
                pstmtCursosActivos = conn.prepareStatement(sqlCursosActivos);
                pstmtCursosActivos.setInt(1, idProfesor);
                rsCursosActivos = pstmtCursosActivos.executeQuery();
                if (rsCursosActivos.next()) {
                    cursosActivos = rsCursosActivos.getInt("total");
                }
            } finally {
                cerrarRecursos(rsCursosActivos, pstmtCursosActivos);
            }

            // Total Alumnos
            PreparedStatement pstmtTotalAlumnos = null;
            ResultSet rsTotalAlumnos = null;
            try {
                String sqlTotalAlumnos = "SELECT COUNT(DISTINCT i.id_alumno) AS total "
                        + "FROM inscripciones i "
                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                        + "WHERE cl.id_profesor = ? AND i.estado = 'inscrito'";
                pstmtTotalAlumnos = conn.prepareStatement(sqlTotalAlumnos);
                pstmtTotalAlumnos.setInt(1, idProfesor);
                rsTotalAlumnos = pstmtTotalAlumnos.executeQuery();
                if (rsTotalAlumnos.next()) {
                    totalAlumnos = rsTotalAlumnos.getInt("total");
                }
            } finally {
                cerrarRecursos(rsTotalAlumnos, pstmtTotalAlumnos);
            }

            // Lista de Mis Cursos
            PreparedStatement pstmtCursosList = null;
            ResultSet rsCursosList = null;
            try {
                String sqlCursosList = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso, c.creditos "
                        + "FROM cursos c "
                        + "JOIN profesor_curso pc ON c.id_curso = pc.id_curso "
                        + "WHERE pc.id_profesor = ? ORDER BY c.nombre_curso";
                pstmtCursosList = conn.prepareStatement(sqlCursosList);
                pstmtCursosList.setInt(1, idProfesor);
                rsCursosList = pstmtCursosList.executeQuery();
                while (rsCursosList.next()) {
                    Map<String, String> curso = new HashMap<>();
                    curso.put("id_curso", String.valueOf(rsCursosList.getInt("id_curso")));
                    curso.put("codigo_curso", rsCursosList.getString("codigo_curso") != null ? rsCursosList.getString("codigo_curso") : "");
                    curso.put("nombre_curso", rsCursosList.getString("nombre_curso") != null ? rsCursosList.getString("nombre_curso") : "");
                    curso.put("creditos", String.valueOf(rsCursosList.getInt("creditos")));

                    PreparedStatement pstmtAlumnosCurso = null;
                    ResultSet rsAlumnosCurso = null;
                    try {
                        String subSqlAlumnos = "SELECT COUNT(*) FROM inscripciones i JOIN clases cl ON i.id_clase = cl.id_clase WHERE cl.id_curso = ? AND i.estado = 'inscrito'";
                        pstmtAlumnosCurso = conn.prepareStatement(subSqlAlumnos);
                        pstmtAlumnosCurso.setInt(1, rsCursosList.getInt("id_curso"));
                        rsAlumnosCurso = pstmtAlumnosCurso.executeQuery();
                        if (rsAlumnosCurso.next()) {
                            curso.put("alumnos", String.valueOf(rsAlumnosCurso.getInt(1)));
                        } else {
                            curso.put("alumnos", "0");
                        }
                    } finally {
                        cerrarRecursos(rsAlumnosCurso, pstmtAlumnosCurso);
                    }
                    cursosList.add(curso);
                }
            } finally {
                cerrarRecursos(rsCursosList, pstmtCursosList);
            }

            // Lista de Alumnos Recientes
            PreparedStatement pstmtAlumnosList = null;
            ResultSet rsAlumnosList = null;
            try {
                String sqlAlumnosList = "SELECT a.id_alumno, a.nombre, a.apellido_paterno, a.apellido_materno, cu.nombre_curso "
                        + "FROM alumnos a "
                        + "JOIN inscripciones i ON a.id_alumno = i.id_alumno "
                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                        + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                        + "WHERE cl.id_profesor = ? AND i.estado = 'inscrito' "
                        + "ORDER BY i.fecha_inscripcion DESC LIMIT 5";
                pstmtAlumnosList = conn.prepareStatement(sqlAlumnosList);
                pstmtAlumnosList.setInt(1, idProfesor);
                rsAlumnosList = pstmtAlumnosList.executeQuery();
                while (rsAlumnosList.next()) {
                    Map<String, String> alumno = new HashMap<>();
                    alumno.put("id_alumno", String.valueOf(rsAlumnosList.getInt("id_alumno")));
                    String alNombre = rsAlumnosList.getString("nombre") != null ? rsAlumnosList.getString("nombre") : "";
                    String alApPaterno = rsAlumnosList.getString("apellido_paterno") != null ? rsAlumnosList.getString("apellido_paterno") : "";
                    String alApMaterno = rsAlumnosList.getString("apellido_materno") != null ? rsAlumnosList.getString("apellido_materno") : "";
                    String alNombreCompleto = alNombre + " " + alApPaterno;
                    if (!alApMaterno.isEmpty()) {
                        alNombreCompleto += " " + alApMaterno;
                    }
                    alumno.put("nombre_completo", alNombreCompleto);
                    alumno.put("nombre_curso", rsAlumnosList.getString("nombre_curso") != null ? rsAlumnosList.getString("nombre_curso") : "");
                    alumnosList.add(alumno);
                }
            } finally {
                cerrarRecursos(rsAlumnosList, pstmtAlumnosList);
            }

            // --- Lógica para datos de gráficos ---
            // Para Notas: Obtener promedios de notas por curso
            PreparedStatement pstmtPromediosNotas = null;
            ResultSet rsPromediosNotas = null;
            try {
                String sqlPromediosNotas = "SELECT cu.nombre_curso, AVG(n.nota_final) as promedio "
                        + "FROM notas n "
                        + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                        + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                        + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL "
                        + "GROUP BY cu.nombre_curso LIMIT 5";
                pstmtPromediosNotas = conn.prepareStatement(sqlPromediosNotas);
                pstmtPromediosNotas.setInt(1, idProfesor);
                rsPromediosNotas = pstmtPromediosNotas.executeQuery();
                while (rsPromediosNotas.next()) {
                    nombresCursosNotas.add(rsPromediosNotas.getString("nombre_curso") != null ? rsPromediosNotas.getString("nombre_curso") : "N/A");
                    promediosNotas.add(rsPromediosNotas.getDouble("promedio"));
                }
            } finally {
                cerrarRecursos(rsPromediosNotas, pstmtPromediosNotas);
            }

            // Para Asistencia: Contar presentes, ausentes, tardanzas
            PreparedStatement pstmtAsistencia = null;
            ResultSet rsAsistencia = null;
            try {
                String sqlAsistencia = "SELECT a.estado, COUNT(*) as count FROM asistencia a "
                        + "JOIN inscripciones i ON a.id_inscripcion = i.id_inscripcion "
                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                        + "WHERE cl.id_profesor = ? "
                        + "GROUP BY a.estado";
                pstmtAsistencia = conn.prepareStatement(sqlAsistencia);
                pstmtAsistencia.setInt(1, idProfesor);
                rsAsistencia = pstmtAsistencia.executeQuery();
                while (rsAsistencia.next()) {
                    String estadoAsistencia = rsAsistencia.getString("estado");
                    int count = rsAsistencia.getInt("count");
                    if ("presente".equalsIgnoreCase(estadoAsistencia)) {
                        totalPresentes = count;
                    } else if ("ausente".equalsIgnoreCase(estadoAsistencia)) {
                        totalAusentes = count;
                    } else if ("tardanza".equalsIgnoreCase(estadoAsistencia)) {
                        totalTardanzas = count;
                    }
                }
            } finally {
                cerrarRecursos(rsAsistencia, pstmtAsistencia);
            }
        }

        // --- Obtener la fecha actual para "Último acceso" ---
        ultimoAcceso = LocalDateTime.now().format(DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM 'de' yyyy"));

    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        response.sendRedirect("error.jsp?message=Error_interno_del_servidor");
        return;
    } finally {
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            /* Ignorar */ }
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard Profesor | UNI</title>
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
                background-color: #f9f9f9;
                color: var(--dark-color);
                /* Importante para asegurar que el body ocupe todo el alto */
                min-height: 100vh;
                display: flex; /* Usamos flexbox para que el header y el main-container se organicen */
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
                flex-shrink: 0; /* No permitir que el header se encoja */
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

            /* Cambios clave aquí para que el sidebar esté pegado a la izquierda */
            .main-wrapper { /* Nuevo contenedor para sidebar y main-content */
                display: flex;
                flex: 1; /* Esto hace que ocupe todo el espacio restante en altura */
                width: 100%; /* Asegura que ocupe todo el ancho */
            }

            .sidebar {
                width: 250px;
                background-color: var(--primary-color);
                color: white;
                padding: 1.5rem 0;
                flex-shrink: 0; /* Evita que el sidebar se encoja */
                min-height: 100%; /* Asegura que el sidebar ocupe todo el alto disponible */
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
                flex: 1; /* El contenido principal ocupa el resto del espacio */
                padding: 2rem;
                overflow-y: auto; /* Si el contenido es largo, permite desplazamiento */
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

            .profesor-info {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-left: 4px solid var(--secondary-color);
            }

            .profesor-info h3.section-title {
                color: var(--primary-color);
                margin-bottom: 1.5rem;
                font-weight: bold;
            }

            .profesor-info p {
                margin-bottom: 0.5rem;
            }

            .profesor-info strong {
                color: var(--dark-color);
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

            /* Stats Cards */
            .stat-card {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                text-align: center;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-bottom: 4px solid var(--primary-color);
                transition: transform 0.3s ease-in-out;
            }

            .stat-card:hover {
                transform: translateY(-5px);
            }

            .stat-card h3 {
                color: var(--primary-color);
                font-size: 1.1rem;
                margin-bottom: 0.5rem;
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

            /* Content Sections */
            .content-section {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-left: 4px solid var(--secondary-color);
            }

            .content-section h3.section-title {
                color: var(--primary-color);
                margin-bottom: 1.5rem;
                font-weight: bold;
            }

            /* Tables */
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
                background-color: rgba(0, 35, 102, 0.05); /* Ligeramente azul al pasar el mouse */
            }

            /* Charts - Ajustes para visualización */
            .chart-container {
                position: relative;
                height: 350px; /* Altura fija para el contenedor del gráfico */
                width: 100%;
                margin: auto;
                padding: 1rem;
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                display: flex; /* Usamos flexbox para centrar el canvas si es necesario */
                justify-content: center;
                align-items: center;
            }

            /* Aseguramos que el canvas dentro del contenedor de gráfico tenga el 100% de alto y ancho */
            .chart-container canvas {
                max-width: 100%;
                max-height: 100%;
            }


            /* Quick Actions */
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
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                border-bottom: 4px solid var(--secondary-color);
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
                color: white; /* Asegura que el texto siga siendo blanco */
            }

            @media (max-width: 768px) {
                .main-wrapper {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    min-height: auto; /* Quita el min-height en pantallas pequeñas */
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

                .chart-container {
                    height: 300px; /* Un poco menos de altura en móviles */
                }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="logo">Sistema Universitario</div>
            <div class="user-info">
                <p class="user-name"><%= nombreCompleto%></p>
                <p><%= email%></p>
                <p><%= facultad%></p>
                <form action="logout.jsp" method="post">
                    <button type="submit" class="logout-btn">Cerrar sesión</button>
                </form>
            </div>
        </div>

        <div class="main-wrapper"> 
            <div class="sidebar">
                <ul>
                    <li><a href="home_profesor.jsp">Inicio</a></li>
                    <li><a href="facultad_profesor.jsp">Facultades</a</li>
                    <li><a href="carreras_profesor.jsp">Carreras</a></li>
                    <li><a href="cursos_profesor.jsp">Cursos</a</li>
                    <li><a href="salones.jsp">Salones</a></li>
                    <li><a href="horarios.jsp">Horarios</a></li>
                    <li><a href="asistencia.jsp">Asistencia</a></li>
                    <li><a href="mensaje.jsp">Mensajería</a</li>
                    <li><a href="nota.jsp">Notas</a></li>
                </ul>
            </div>

            <div class="main-content">
                <div class="welcome-section">
                    <h1>Dashboard del Profesor</h1>
                    <p>Bienvenido a su panel de control. Aquí puede ver un resumen de sus actividades y estadísticas.</p>
                </div>

                <div class="row mb-4">
                    <div class="col-md-4 col-sm-6 mb-3">
                        <div class="stat-card">
                            <h3>Cursos Asignados</h3>
                            <div class="value"><%= totalCursos%></div>
                            <div class="description">Total de cursos a su cargo</div>
                        </div>
                    </div>
                    <div class="col-md-4 col-sm-6 mb-3">
                        <div class="stat-card">
                            <h3>Cursos Activos</h3>
                            <div class="value"><%= cursosActivos%></div>
                            <div class="description">Cursos en periodo lectivo</div>
                        </div>
                    </div>
                    <div class="col-md-4 col-sm-6 mb-3">
                        <div class="stat-card">
                            <h3>Estudiantes</h3>
                            <div class="value"><%= totalAlumnos%></div>
                            <div class="description">Alumnos matriculados</div>
                        </div>
                    </div>
                </div>

                <div class="profesor-info mb-4">
                    <h3 class="section-title">Mi Información</h3>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Nombre completo:</strong> <%= nombreCompleto%></p>
                            <p><strong>DNI:</strong> <%= dni%></p>
                            <p><strong>Facultad:</strong> <%= facultad%></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Correo electrónico:</strong> <%= email%></p>
                            <p><strong>Teléfono:</strong> <%= telefono%></p>
                            <p><strong>Último acceso:</strong> <%= ultimoAcceso%></p>
                        </div>
                    </div>
                </div>

                <div class="content-section mb-4">
                    <h3 class="section-title">Notas Promedio por Curso</h3>
                    <div class="chart-container">
                        <canvas id="notasChart"></canvas>
                    </div>
                </div>

                <div class="content-section mb-4">
                    <h3 class="section-title">Estadísticas de Asistencia</h3>
                    <div class="chart-container">
                        <canvas id="asistenciaChart"></canvas>
                    </div>
                </div>

                <div class="content-section mb-4">
                    <h3 class="section-title">Mis Cursos</h3>
                    <div class="table-responsive">
                        <% if (!cursosList.isEmpty()) { %>
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Código</th>
                                    <th>Nombre del Curso</th>
                                    <th>Créditos</th>
                                    <th>Alumnos</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, String> curso : cursosList) {%>
                                <tr>
                                    <td><%= curso.get("codigo_curso")%></td>
                                    <td><%= curso.get("nombre_curso")%></td>
                                    <td><%= curso.get("creditos")%></td>
                                    <td><%= curso.get("alumnos")%></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <p class="text-muted">No hay cursos asignados actualmente.</p>
                        <% } %>
                    </div>
                </div>

                <div class="content-section mb-4">
                    <h3 class="section-title">Alumnos Recientes</h3>
                    <div class="table-responsive">
                        <% if (!alumnosList.isEmpty()) { %>
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Nombre</th>
                                    <th>Curso</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, String> alumno : alumnosList) {%>
                                <tr>
                                    <td><%= alumno.get("id_alumno")%></td>
                                    <td><%= alumno.get("nombre_completo")%></td>
                                    <td><%= alumno.get("nombre_curso")%></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <p class="text-muted">No hay alumnos registrados recientemente.</p>
                        <% } %>
                    </div>
                </div>

                <div class="content-section">
                    <h3 class="section-title">Acciones Rápidas</h3>
                    <div class="quick-actions">
                        <div class="action-card">
                            <i class="fas fa-clipboard-check"></i>
                            <h4>Registrar Asistencia</h4>
                            <p>Registre la asistencia de sus estudiantes para la sesión de hoy</p>
                            <a href="registrar_asistencia.jsp" class="action-btn">Ir ahora</a>
                        </div>

                        <div class="action-card">
                            <i class="fas fa-edit"></i>
                            <h4>Ingresar Notas</h4>
                            <p>Ingrese las calificaciones de la última evaluación</p>
                            <a href="ingresar_notas.jsp" class="action-btn">Ir ahora</a>
                        </div>

                        <div class="action-card">
                            <i class="fas fa-calendar-alt"></i>
                            <h4>Ver Horario</h4>
                            <p>Consulte su horario de clases para esta semana</p>
                            <a href="horarios.jsp" class="action-btn">Ver horario</a>
                        </div>

                        <div class="action-card">
                            <i class="fas fa-envelope"></i>
                            <h4>Mensajes</h4>
                            <p>Revise sus mensajes y comunicados importantes</p>
                            <a href="mensajes.jsp" class="action-btn">Ver mensajes</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script> <script>
            // --- Gráfico de Notas ---
            const nombresCursosNotas = [
            <%
                    for (int i = 0; i < nombresCursosNotas.size(); i++) {
                        out.print("'" + nombresCursosNotas.get(i).replace("'", "\\'") + "'"); // Escape single quotes
                        if (i < nombresCursosNotas.size() - 1) {
                            out.print(", ");
                        }
                    }
            %>
            ];
            const promediosNotas = [
            <%
                    for (int i = 0; i < promediosNotas.size(); i++) {
                        out.print(promediosNotas.get(i));
                        if (i < promediosNotas.size() - 1) {
                            out.print(", ");
                        }
                    }
            %>
            ];

            // Asegúrate de que el elemento canvas exista antes de inicializar el gráfico
            const ctxNotas = document.getElementById('notasChart');
            if (ctxNotas) {
                new Chart(ctxNotas.getContext('2d'), {
                    type: 'bar', // Tipo de gráfico: barras
                    data: {
                        labels: nombresCursosNotas,
                        datasets: [{
                                label: 'Promedio de Notas',
                                data: promediosNotas,
                                backgroundColor: 'rgba(0, 35, 102, 0.7)', // Azul oscuro (primary-color)
                                borderColor: 'rgba(0, 35, 102, 1)',
                                borderWidth: 1
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, // Permitir que el tamaño sea flexible
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 20,
                                title: {
                                    display: true,
                                    text: 'Nota Promedio'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Curso'
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Promedio de Notas por Curso Asignado'
                            },
                            legend: {
                                display: false // No mostrar leyenda para un solo dataset
                            }
                        }
                    }
                });
            }


            // --- Gráfico de Asistencia ---
            const dataAsistencia = {
                labels: ['Presentes', 'Ausentes', 'Tardanzas'],
                datasets: [{
                        data: [<%= totalPresentes%>, <%= totalAusentes%>, <%= totalTardanzas%>],
                        backgroundColor: [
                            'rgba(75, 192, 192, 0.7)', // Verde/Azul claro
                            'rgba(255, 99, 132, 0.7)', // Rojo
                            'rgba(255, 206, 86, 0.7)'    // Amarillo
                        ],
                        borderColor: [
                            'rgba(75, 192, 192, 1)',
                            'rgba(255, 99, 132, 1)',
                            'rgba(255, 206, 86, 1)'
                        ],
                        borderWidth: 1
                    }]
            };

            const ctxAsistencia = document.getElementById('asistenciaChart');
            if (ctxAsistencia) {
                new Chart(ctxAsistencia.getContext('2d'), {
                    type: 'pie', // Tipo de gráfico: pastel
                    data: dataAsistencia,
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            title: {
                                display: true,
                                text: 'Distribución de Asistencia'
                            },
                            legend: {
                                position: 'top',
                            }
                        }
                    }
                });
            }
        </script>
    </body>
</html>