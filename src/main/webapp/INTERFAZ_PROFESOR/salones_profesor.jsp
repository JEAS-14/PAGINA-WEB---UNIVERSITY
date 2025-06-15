<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

    // Variables para estadísticas
    int totalClases = 0;
    int totalAlumnos = 0; // Total de alumnos únicos inscritos en todas sus clases
    int totalCapacidadClasesActivas = 0; // Para el cálculo del porcentaje de ocupación
    int totalAlumnosEnClasesActivas = 0; // Para el cálculo del porcentaje de ocupación

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

        // --- Obtener estadísticas de clases para el profesor ---
        String sqlStats = "SELECT "
                          + "COUNT(DISTINCT cl.id_clase) as total_clases, "
                          + "COUNT(DISTINCT i.id_alumno) as total_alumnos_unicos, "
                          + "SUM(CASE WHEN cl.estado = 'activo' THEN cl.capacidad_maxima ELSE 0 END) as total_capacidad_clases_activas, "
                          + "SUM(CASE WHEN cl.estado = 'activo' THEN "
                          + "    (SELECT COUNT(*) FROM inscripciones sub_i WHERE sub_i.id_clase = cl.id_clase AND sub_i.estado = 'inscrito') "
                          + "    ELSE 0 END) as total_alumnos_en_clases_activas "
                          + "FROM clases cl "
                          + "LEFT JOIN inscripciones i ON cl.id_clase = i.id_clase " 
                          + "WHERE cl.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlStats);
        pstmt.setInt(1, idProfesor);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            totalClases = rs.getInt("total_clases");
            totalAlumnos = rs.getInt("total_alumnos_unicos");
            totalCapacidadClasesActivas = rs.getInt("total_capacidad_clases_activas");
            totalAlumnosEnClasesActivas = rs.getInt("total_alumnos_en_clases_activas");
        }
        if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
        if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }

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
    <title>Clases del Profesor - Sistema Universitario</title>
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

        .stats-grid { /* Usado para la cuadrícula de estadísticas */
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            flex: 1; /* Si no está en grid */
            text-align: center;
            border-top: 4px solid var(--accent-color);
        }

        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }

        .clases-section { /* Sección principal para la tabla de clases */
            background-color: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-color);
        }

        .clases-section h2 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1.5rem;
        }

        .clases-table { /* Tabla para listar clases */
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .clases-table th {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }

        .clases-table td {
            padding: 1rem;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }

        .clases-table tr:hover {
            background-color: #f8f9fa;
        }

        .clases-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .clases-table tr:nth-child(even):hover {
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

        /* Renombrados para clases */
        .clase-id { 
            font-weight: bold;
            color: var(--primary-color);
        }

        .clase-name {
            font-weight: 600;
            color: var(--dark-color);
        }

        /* Responsividad */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                padding: 1rem 0;
            }

            .stats-grid { /* También afectado por flex-direction: column */
                flex-direction: column;
            }

            .clases-table {
                font-size: 0.9rem;
            }

            .clases-table th,
            .clases-table td {
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
                <li><a href="salones_profesor.jsp" class="active">Clases</a></li> 
                <li><a href="horarios_profesor.jsp">Horarios</a></li> 
                <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                <li><a href="nota_profesor.jsp">Notas</a></li>
            </ul>
        </div>

        <div class="main-content">
            <div class="welcome-section">
                <h1>Mis Clases Asignadas</h1>
                <p>Consulta las clases que tienes asignadas. Esta información es solo de lectura.</p>
            </div>

            <div class="info-box">
                <h4>ℹ️ Información</h4>
                <p>Aquí puedes ver todas las clases que impartes, con detalles del curso, horario y el número de alumnos inscritos.</p>
            </div>
            
            <div class="stats-grid"> <%-- Cuadrícula de estadísticas --%>
                <div class="stat-card" style="border-top-color: var(--primary-color);">
                    <div class="stat-number"><%= totalClases %></div>
                    <div class="stat-label">Total Clases Asignadas</div>
                </div>
                <div class="stat-card" style="border-top-color: #28a745;">
                    <div class="stat-number"><%= totalAlumnos %></div>
                    <div class="stat-label">Total Alumnos</div>
                </div>
                <div class="stat-card" style="border-top-color: #fd7e14;">
                    <%
                        double porcentajeOcupacionGeneral = 0.0;
                        if (totalCapacidadClasesActivas > 0) { // Asegurarse de que no dividimos por cero
                            porcentajeOcupacionGeneral = ((double)totalAlumnosEnClasesActivas / totalCapacidadClasesActivas) * 100;
                        }
                    %>
                    <div class="stat-number"><%= String.format("%.0f%%", porcentajeOcupacionGeneral) %></div>
                    <div class="stat-label">Porcentaje Ocupación</div>
                </div>
                <div class="stat-card" style="border-top-color: #6f42c1;">
                    <div class="stat-number">N/A</div> <%-- Esta es otra métrica de ejemplo --%>
                    <div class="stat-label">Clases Llenas</div>
                </div>
            </div>

            <div class="clases-section">
                <h2>Listado de Clases - <%= nombreProfesor%></h2>

                <%
                    PreparedStatement pstmtClases = null;
                    ResultSet rsClases = null;
                    String classesLoadError = null; // Para errores específicos de esta tabla

                    try {
                        // Aseguramos que la conexión 'conn' esté abierta y válida
                        if (conn == null || conn.isClosed()) {
                            Conexion tempCon = new Conexion();
                            conn = tempCon.conecta();
                        }

                        // Solo ejecutamos la consulta si la conexión 'conn' es válida y si idProfesor es válido
                        if (conn != null && !conn.isClosed() && idProfesor != -1) { 
                            String sqlClases = "SELECT cl.id_clase, cl.seccion, cl.ciclo, cl.semestre, cl.año_academico, cl.estado AS clase_estado, cl.capacidad_maxima, "
                                               + "cu.nombre_curso, cu.codigo_curso, "
                                               + "h.dia_semana, h.hora_inicio, h.hora_fin, h.aula, "
                                               + "(SELECT COUNT(*) FROM inscripciones i WHERE i.id_clase = cl.id_clase AND i.estado = 'inscrito') as alumnos_inscritos "
                                               + "FROM clases cl "
                                               + "INNER JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                               + "INNER JOIN horarios h ON cl.id_horario = h.id_horario "
                                               + "WHERE cl.id_profesor = ? "
                                               + "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso, cl.seccion";

                            pstmtClases = conn.prepareStatement(sqlClases);
                            pstmtClases.setInt(1, idProfesor); 
                            rsClases = pstmtClases.executeQuery();

                            boolean hayClases = false;
                %>
                <table class="clases-table">
                    <thead>
                        <tr>
                            <th>Clase</th>
                            <th>Curso</th>
                            <th>Horario</th>
                            <th>Aula</th>
                            <th>Alumnos / Cap.</th>
                            <th>Estado</th>
                            <th>Acciones</th>
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
                                } else if ("finalizado".equals(estadoClase)) {
                                    badgeClass = "badge-primary";
                                } else { // inactivo
                                    badgeClass = "badge-secondary";
                                }

                                int alumnosInscritos = rsClases.getInt("alumnos_inscritos");
                                int capacidadMaxima = rsClases.getInt("capacidad_maxima");
                        %>
                        <tr>
                            <td>
                                <span class="clase-name"><%= rsClases.getString("seccion")%> - <%= rsClases.getString("ciclo")%></span>
                                <br><small class="text-muted"><%= rsClases.getString("semestre")%> / <%= rsClases.getInt("año_academico")%></small>
                            </td>
                            <td>
                                <%= rsClases.getString("nombre_curso")%>
                                <br><small class="text-muted">Código: <%= rsClases.getString("codigo_curso")%></small>
                            </td>
                            <td>
                                <%= rsClases.getString("dia_semana")%><br>
                                <%= rsClases.getTime("hora_inicio")%> - <%= rsClases.getTime("hora_fin")%>
                            </td>
                            <td>
                                <%= rsClases.getString("aula") %> </td>
                            <td><%= alumnosInscritos%> / <%= capacidadMaxima%></td>
                            <td><span class="badge <%= badgeClass%>"><%= estadoClase.toUpperCase()%></span></td>
                            <td>
                                <form action="ver_estudiantes.jsp" method="get" style="display:inline;">
                                    <input type="hidden" name="id_clase" value="<%= rsClases.getInt("id_clase") %>">
                                    <button type="submit" style="background-color: #007bff; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">
                                        Ver Estudiantes
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                            } // Cierre de while

                            if (!hayClases) {
                        %>
                        <tr>
                            <td colspan="7" class="no-data"> <%-- Colspan ajustado a 7 --%>
                                📚 No tienes clases asignadas.
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                        } else { // Si conn es nulo o está cerrado o idProfesor es -1
                            classesLoadError = "No se pudo establecer la conexión a la base de datos o el ID de profesor es inválido para cargar clases.";
                        }
                    } catch (SQLException e) {
                        classesLoadError = "Error de SQL al cargar las clases: " + e.getMessage();
                        e.printStackTrace();
                    } catch (ClassNotFoundException e) {
                        classesLoadError = "Error: No se encontró el driver JDBC de MySQL para las clases.";
                        e.printStackTrace();
                    } finally {
                        // Cierre manual y seguro de recursos de este bloque específico
                        if (pstmtClases != null) { try { pstmtClases.close(); } catch (SQLException ignore) {} }
                        if (rsClases != null) { try { rsClases.close(); } catch (SQLException ignore) {} }
                        // La conexión 'conn' (que se abrió al inicio del scriptlet) NO se cierra aquí,
                        // se cerrará una única vez al final de la página.
                    }

                    if (classesLoadError != null) {
                %>
                    <div class="no-data" style="color: red;"><%= classesLoadError %></div>
                <%
                    }
                %>
            </div>

            <%-- Botón "Solicitar agregar clase" al final del main-content --%>
            <div style="text-align: right; margin-top: 30px;">
                <form action="solicitar_clase.jsp" method="post" style="display:inline-block;">
                    <button type="submit" style="background-color: var(--primary-color); color: white; padding: 15px 25px; border: none; border-radius: 8px; cursor: pointer; font-size: 1.1rem; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
                        ➕ Solicitar agregar clase
                    </button>
                </form>
                <p style="font-size: 0.9rem; color: #666; margin-top: 10px;">Esta acción requiere la aprobación del administrador.</p>
            </div>
        </div>
    </div>

    <%
        // Cierre final de la conexión 'conn' que se abrió al inicio del scriptlet.
        // Asegura que la conexión se cierre una vez que toda la página haya terminado de usarla.
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    %>
</body>
</html>