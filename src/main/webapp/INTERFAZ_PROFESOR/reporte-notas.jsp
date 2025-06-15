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

    // --- Variables para los datos del profesor (se asume que se obtienen de sesión o se re-consultan si es necesario) ---
    // Para simplificar, aquí solo usaremos el idProfesor para las consultas de reporte.
    // Si necesitas mostrar el nombre, DNI, etc. del profesor en esta página, deberías consultar esos datos aquí también,
    // o pasarlos como atributos de sesión desde el login o home_profesor.jsp.
    int idProfesor = 0; // Se inicializa a 0, se obtendrá de la BD.

    // --- Variables para las tarjetas informativas ---
    double promedioGeneral = 0.0;
    double porcentajeAprobados = 0.0;
    double notaMaxima = 0.0;
    int estudiantesPendientes = 0;

    // --- Variables para los gráficos ---
    List<String> nombresCursosNotas = new ArrayList<>();
    List<Double> promediosNotas = new ArrayList<>();
    int totalAprobadosChart = 0;
    int totalDesaprobadosChart = 0;
    int totalPendientesChart = 0;

    // --- Lista para la tabla de detalle de calificaciones ---
    List<Map<String, String>> notasDetalleList = new ArrayList<>();

    Connection conn = null;

    try {
        Conexion c = new Conexion();
        conn = c.conecta();

        // --- 1. Obtener id_profesor (y otros datos si se desean mostrar en la cabecera) ---
        PreparedStatement pstmtProfesor = null;
        ResultSet rsProfesor = null;
        try {
            String sqlProfesorId = "SELECT id_profesor FROM profesores WHERE email = ?";
            pstmtProfesor = conn.prepareStatement(sqlProfesorId);
            pstmtProfesor.setString(1, email.trim());
            rsProfesor = pstmtProfesor.executeQuery();

            if (rsProfesor.next()) {
                idProfesor = rsProfesor.getInt("id_profesor");
            } else {
                // Si el profesor no se encuentra, redirigir o mostrar error
                response.sendRedirect("login.jsp?error=profesor_no_encontrado");
                return;
            }
        } finally {
            cerrarRecursos(rsProfesor, pstmtProfesor);
        }

        // --- 2. Obtener Datos para Tarjetas Informativas ---

        // Promedio General
        PreparedStatement pstmtPromedioGeneral = null;
        ResultSet rsPromedioGeneral = null;
        try {
            String sqlPromedioGeneral = "SELECT AVG(n.nota_final) AS promedio_general "
                                      + "FROM notas n "
                                      + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                      + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                      + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL";
            pstmtPromedioGeneral = conn.prepareStatement(sqlPromedioGeneral);
            pstmtPromedioGeneral.setInt(1, idProfesor);
            rsPromedioGeneral = pstmtPromedioGeneral.executeQuery();
            if (rsPromedioGeneral.next()) {
                promedioGeneral = rsPromedioGeneral.getDouble("promedio_general");
            }
        } finally {
            cerrarRecursos(rsPromedioGeneral, pstmtPromedioGeneral);
        }

        // Porcentaje de Aprobados
        PreparedStatement pstmtPorcentajeAprobados = null;
        ResultSet rsPorcentajeAprobados = null;
        try {
            String sqlPorcentajeAprobados = "SELECT "
                                          + "(SUM(CASE WHEN n.estado = 'aprobado' THEN 1 ELSE 0 END) * 100.0 / COUNT(n.id_nota)) AS porcentaje_aprobados "
                                          + "FROM notas n "
                                          + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                          + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                          + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL";
            pstmtPorcentajeAprobados = conn.prepareStatement(sqlPorcentajeAprobados);
            pstmtPorcentajeAprobados.setInt(1, idProfesor);
            rsPorcentajeAprobados = pstmtPorcentajeAprobados.executeQuery();
            if (rsPorcentajeAprobados.next()) {
                porcentajeAprobados = rsPorcentajeAprobados.getDouble("porcentaje_aprobados");
            }
        } finally {
            cerrarRecursos(rsPorcentajeAprobados, pstmtPorcentajeAprobados);
        }

        // Nota Más Alta
        PreparedStatement pstmtNotaMaxima = null;
        ResultSet rsNotaMaxima = null;
        try {
            String sqlNotaMaxima = "SELECT MAX(n.nota_final) AS nota_maxima "
                                 + "FROM notas n "
                                 + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                 + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                 + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL";
            pstmtNotaMaxima = conn.prepareStatement(sqlNotaMaxima);
            pstmtNotaMaxima.setInt(1, idProfesor);
            rsNotaMaxima = pstmtNotaMaxima.executeQuery();
            if (rsNotaMaxima.next()) {
                notaMaxima = rsNotaMaxima.getDouble("nota_maxima");
            }
        } finally {
            cerrarRecursos(rsNotaMaxima, pstmtNotaMaxima);
        }

        // Estudiantes con Notas Pendientes
        PreparedStatement pstmtEstudiantesPendientes = null;
        ResultSet rsEstudiantesPendientes = null;
        try {
            String sqlEstudiantesPendientes = "SELECT COUNT(DISTINCT i.id_alumno) AS estudiantes_pendientes "
                                            + "FROM inscripciones i "
                                            + "JOIN notas n ON i.id_inscripcion = n.id_inscripcion "
                                            + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                            + "WHERE cl.id_profesor = ? AND n.estado = 'pendiente'";
            pstmtEstudiantesPendientes = conn.prepareStatement(sqlEstudiantesPendientes);
            pstmtEstudiantesPendientes.setInt(1, idProfesor);
            rsEstudiantesPendientes = pstmtEstudiantesPendientes.executeQuery();
            if (rsEstudiantesPendientes.next()) {
                estudiantesPendientes = rsEstudiantesPendientes.getInt("estudiantes_pendientes");
            }
        } finally {
            cerrarRecursos(rsEstudiantesPendientes, pstmtEstudiantesPendientes);
        }

        // --- 3. Datos para Gráfico de Promedios por Curso (ya tenías algo similar) ---
        PreparedStatement pstmtPromediosNotas = null;
        ResultSet rsPromediosNotas = null;
        try {
            String sqlPromediosNotas = "SELECT cu.nombre_curso, AVG(n.nota_final) as promedio "
                                     + "FROM notas n "
                                     + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                     + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                     + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                     + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL "
                                     + "GROUP BY cu.nombre_curso LIMIT 5"; // Limitar para un gráfico más legible
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

        // --- 4. Datos para Gráfico de Estado de Estudiantes (Aprobados/Desaprobados/Pendientes) ---
        PreparedStatement pstmtEstadoEstudiantes = null;
        ResultSet rsEstadoEstudiantes = null;
        try {
            String sqlEstadoEstudiantes = "SELECT n.estado, COUNT(*) as count FROM notas n "
                                        + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                        + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                        + "WHERE cl.id_profesor = ? AND n.nota_final IS NOT NULL " // Considera solo con nota final para el estado
                                        + "GROUP BY n.estado";
            pstmtEstadoEstudiantes = conn.prepareStatement(sqlEstadoEstudiantes);
            pstmtEstadoEstudiantes.setInt(1, idProfesor);
            rsEstadoEstudiantes = pstmtEstadoEstudiantes.executeQuery();
            while (rsEstadoEstudiantes.next()) {
                String estado = rsEstadoEstudiantes.getString("estado");
                int count = rsEstadoEstudiantes.getInt("count");
                if ("aprobado".equalsIgnoreCase(estado)) {
                    totalAprobadosChart = count;
                } else if ("desaprobado".equalsIgnoreCase(estado)) {
                    totalDesaprobadosChart = count;
                } else if ("pendiente".equalsIgnoreCase(estado)) {
                    totalPendientesChart = count;
                }
            }
        } finally {
            cerrarRecursos(rsEstadoEstudiantes, pstmtEstadoEstudiantes);
        }

        // --- 5. Obtener Datos para la Tabla de Detalle de Calificaciones ---
        PreparedStatement pstmtNotasDetalle = null;
        ResultSet rsNotasDetalle = null;
        try {
            String sqlNotasDetalle = "SELECT a.dni, CONCAT(a.nombre, ' ', a.apellido_paterno, ' ', IFNULL(a.apellido_materno, '')) AS nombre_completo, "
                                    + "cu.nombre_curso, n.nota1, n.nota2, n.nota3, n.examen_parcial, n.examen_final, n.nota_final, n.estado "
                                    + "FROM notas n "
                                    + "JOIN inscripciones i ON n.id_inscripcion = i.id_inscripcion "
                                    + "JOIN alumnos a ON i.id_alumno = a.id_alumno "
                                    + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                    + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                    + "WHERE cl.id_profesor = ? "
                                    + "ORDER BY cu.nombre_curso, a.apellido_paterno, a.nombre";
            pstmtNotasDetalle = conn.prepareStatement(sqlNotasDetalle);
            pstmtNotasDetalle.setInt(1, idProfesor);
            rsNotasDetalle = pstmtNotasDetalle.executeQuery();
            while (rsNotasDetalle.next()) {
                Map<String, String> nota = new HashMap<>();
                nota.put("dni", rsNotasDetalle.getString("dni"));
                nota.put("nombre_completo", rsNotasDetalle.getString("nombre_completo"));
                nota.put("nombre_curso", rsNotasDetalle.getString("nombre_curso"));
                // Formatear notas a dos decimales y manejar NULOS si es necesario
                nota.put("nota1", rsNotasDetalle.getBigDecimal("nota1") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("nota1")) : "N/A");
                nota.put("nota2", rsNotasDetalle.getBigDecimal("nota2") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("nota2")) : "N/A");
                nota.put("nota3", rsNotasDetalle.getBigDecimal("nota3") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("nota3")) : "N/A");
                nota.put("examen_parcial", rsNotasDetalle.getBigDecimal("examen_parcial") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("examen_parcial")) : "N/A");
                nota.put("examen_final", rsNotasDetalle.getBigDecimal("examen_final") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("examen_final")) : "N/A");
                nota.put("nota_final", rsNotasDetalle.getBigDecimal("nota_final") != null ? String.format("%.2f", rsNotasDetalle.getBigDecimal("nota_final")) : "N/A");
                nota.put("estado", rsNotasDetalle.getString("estado"));
                notasDetalleList.add(nota);
            }
        } finally {
            cerrarRecursos(rsNotasDetalle, pstmtNotasDetalle);
        }

    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        response.sendRedirect("error.jsp?message=Error_interno_del_servidor_al_cargar_reporte_de_notas");
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
    <title>Reporte de Notas | UNI</title>
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

        /* Stats Cards - New Styles */
        .stat-card {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-bottom: 4px solid var(--primary-color); /* Updated for consistency */
            transition: transform 0.3s ease-in-out;
            min-height: 150px; /* Ensure cards have similar height */
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
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
            background-color: rgba(0, 35, 102, 0.05);
        }

        /* Charts - Ajustes para visualización */
        .chart-container {
            position: relative;
            height: 350px;
            width: 100%;
            margin: auto;
            padding: 1rem;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .chart-container canvas {
            max-width: 100%;
            max-height: 100%;
        }

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

            .chart-container {
                height: 300px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name">Profesor</p> <%-- Puedes poner el nombre del profesor aquí si lo pasas en la sesión --%>
            <p><%= email%></p>
            <p>Facultad de Ingeniería</p> <%-- Puedes poner la facultad aquí si la pasas en la sesión --%>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>

    <div class="main-wrapper">
        <div class="sidebar">
            <ul>
                <li><a href="home_profesor.jsp">Inicio</a></li>
                <li><a href="facultad_profesor.jsp">Facultades</a></li>
                <li><a href="carreras_profesor.jsp">Carreras</a></li>
                <li><a href="cursos_profesor.jsp">Cursos</a></li>
                <li><a href="salones_profesor.jsp">Clases</a></li>
                <li><a href="horarios_profesor.jsp">Horarios</a></li>
                <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                <li><a href="reporte_notas.jsp" class="active">Reporte de Notas</a></li> <%-- ENLACE A ESTA PÁGINA --%>
            </ul>
        </div>

        <div class="main-content">
            <div class="welcome-section">
                <h1>Reporte de Notas</h1>
                <p>Gestione y visualice las calificaciones y el rendimiento académico de sus estudiantes.</p>
            </div>

            <%-- Tarjetas Informativas --%>
            <div class="row mb-4">
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Promedio General</h3>
                        <div class="value"><%= String.format("%.2f", promedioGeneral) %></div>
                        <div class="description">Nota promedio de todos los cursos</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>% Aprobados</h3>
                        <div class="value"><%= String.format("%.0f%%", porcentajeAprobados) %></div>
                        <div class="description">Estudiantes con calificación aprobatoria</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Nota Más Alta</h3>
                        <div class="value"><%= String.format("%.2f", notaMaxima) %></div>
                        <div class="description">La calificación individual más alta</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Pendientes</h3>
                        <div class="value"><%= estudiantesPendientes %></div>
                        <div class="description">Estudiantes con notas pendientes</div>
                    </div>
                </div>
            </div>

            <%-- Gráficos --%>
            <div class="row mb-4">
                <div class="col-md-6 mb-3">
                    <div class="content-section h-100"> <%-- h-100 para que ocupen la misma altura --%>
                        <h3 class="section-title">Distribución de Calificaciones</h3>
                        <div class="chart-container">
                            <canvas id="notasChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 mb-3">
                    <div class="content-section h-100">
                        <h3 class="section-title">Estado de Estudiantes</h3>
                        <div class="chart-container">
                            <canvas id="estadoEstudiantesChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Tabla de Detalle de Calificaciones --%>
            <div class="content-section mb-4">
                <h3 class="section-title">Detalle de Calificaciones</h3>
                <div class="table-responsive">
                    <% if (!notasDetalleList.isEmpty()) { %>
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>DNI</th>
                                <th>Estudiante</th>
                                <th>Curso</th>
                                <th>Nota 1</th>
                                <th>Nota 2</th>
                                <th>Nota 3</th>
                                <th>Examen Parcial</th>
                                <th>Examen Final</th>
                                <th>Nota Final</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> nota : notasDetalleList) { %>
                            <tr>
                                <td><%= nota.get("dni") %></td>
                                <td><%= nota.get("nombre_completo") %></td>
                                <td><%= nota.get("nombre_curso") %></td>
                                <td><%= nota.get("nota1") %></td>
                                <td><%= nota.get("nota2") %></td>
                                <td><%= nota.get("nota3") %></td>
                                <td><%= nota.get("examen_parcial") %></td>
                                <td><%= nota.get("examen_final") %></td>
                                <td><%= nota.get("nota_final") %></td>
                                <td><%= nota.get("estado") %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <p class="text-muted">No hay calificaciones detalladas disponibles para sus cursos.</p>
                    <% } %>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // --- Gráfico de Notas Promedio por Curso ---
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

        const ctxNotas = document.getElementById('notasChart');
        if (ctxNotas) {
            new Chart(ctxNotas.getContext('2d'), {
                type: 'bar',
                data: {
                    labels: nombresCursosNotas,
                    datasets: [{
                        label: 'Promedio de Notas',
                        data: promediosNotas,
                        backgroundColor: 'rgba(0, 35, 102, 0.7)',
                        borderColor: 'rgba(0, 35, 102, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
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
                            display: false
                        }
                    }
                }
            });
        }

        // --- Gráfico de Estado de Estudiantes (Aprobados/Desaprobados/Pendientes) ---
        const totalAprobadosChart = <%= totalAprobadosChart %>;
        const totalDesaprobadosChart = <%= totalDesaprobadosChart %>;
        const totalPendientesChart = <%= totalPendientesChart %>;

        const ctxEstadoEstudiantes = document.getElementById('estadoEstudiantesChart');
        if (ctxEstadoEstudiantes) {
            new Chart(ctxEstadoEstudiantes.getContext('2d'), {
                type: 'pie',
                data: {
                    labels: ['Aprobados', 'Desaprobados', 'Pendientes'],
                    datasets: [{
                        data: [totalAprobadosChart, totalDesaprobadosChart, totalPendientesChart],
                        backgroundColor: [
                            'rgba(75, 192, 192, 0.7)',
                            'rgba(255, 99, 132, 0.7)',
                            'rgba(255, 206, 86, 0.7)'
                        ],
                        borderColor: [
                            'rgba(75, 192, 192, 1)',
                            'rgba(255, 99, 132, 1)',
                            'rgba(255, 206, 86, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Distribución del Estado de Notas'
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