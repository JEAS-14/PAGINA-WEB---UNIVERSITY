<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.time.DayOfWeek, java.time.temporal.TemporalAdjusters" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page session="true" %>

<%!
    // Método para cerrar recursos de BD
    private static void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
            System.err.println("Error cerrando ResultSet: " + e.getMessage()); // Loguear error al cerrar
        }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
            System.err.println("Error cerrando PreparedStatement: " + e.getMessage()); // Loguear error al cerrar
        }
    }
%>

<%
    // --- Obtener información de la sesión ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idAlumnoObj = session.getAttribute("id_alumno");

    // --- Variables para los datos del alumno (Initialized with defaults) ---
    int idAlumno = -1;
    String nombreAlumno = "Alumno Desconocido";
    String dniAlumno = "N/A";
    String emailAlumno = (emailSesion != null ? emailSesion : "N/A");
    String telefonoAlumno = "N/A";
    String fechaNacimientoAlumno = "N/A";
    String direccionAlumno = "N/A";
    String carreraAlumno = "Carrera Desconocida";
    String facultadAlumno = "N/A";
    String estadoAlumno = "N/A";
    String ultimoAcceso = "N/A";

    // --- Variables para las estadísticas e información ---
    int totalCursosInscritos = 0;
    int clasesActivas = 0;
    int totalPagosPendientes = 0;

    List<Map<String, String>> cursosAlumnoDetalleList = new ArrayList<>(); // Used for detailed courses table
    List<String> nombresCursosPromedio = new ArrayList<>();
    List<Double> promediosCursos = new ArrayList<>();
    List<Map<String, String>> clasesParaCalendario = new ArrayList<>();
    List<Map<String, String>> pagosPendientesList = new ArrayList<>();

    // --- Datos para el calendario de clases ---
    LocalDate hoy = LocalDate.now();
    int anioActual = hoy.getYear();
    int mesActual = hoy.getMonthValue();
    LocalDate primerDiaMes = LocalDate.of(anioActual, mesActual, 1);
    LocalDate ultimoDiaMes = primerDiaMes.with(TemporalAdjusters.lastDayOfMonth());
    String nombreMesActual = primerDiaMes.getMonth().getDisplayName(TextStyle.FULL, new Locale("es", "ES"));

    // --- Datos para el gráfico lineal de asistencia mensual (not displayed in this JSP yet, but fetched) ---
    List<String> fechasAsistenciaMes = new ArrayList<>();
    List<Integer> presentesPorDia = new ArrayList<>();
    List<Integer> ausentesPorDia = new ArrayList<>();
    List<Integer> tardanzasPorDia = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String globalErrorMessage = null;

    try {
        // --- 1. Validar y obtener ID del Alumno de Sesión ---
        if (emailSesion == null || !"alumno".equalsIgnoreCase(rolUsuario) || idAlumnoObj == null) {
            System.out.println("DEBUG (home_alumno): Sesión inválida o rol incorrecto. Redirigiendo a login.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        try {
            idAlumno = Integer.parseInt(String.valueOf(idAlumnoObj));
            System.out.println("DEBUG (home_alumno): ID Alumno de sesión: " + idAlumno);
        } catch (NumberFormatException e) {
            System.err.println("ERROR (home_alumno): ID de alumno en sesión no es un número válido. " + e.getMessage());
            globalErrorMessage = "Error de sesión: ID de alumno inválido.";
        }

        // Si idAlumno es válido, intentar conectar y cargar datos
        if (idAlumno != -1 && globalErrorMessage == null) {
            // --- 2. Conectar a la Base de Datos ---
            Conexion c = new Conexion();
            conn = c.conecta();
            if (conn == null || conn.isClosed()) {
                throw new SQLException("No se pudo establecer conexión a la base de datos.");
            }
            System.out.println("DEBUG (home_alumno): Conexión a BD establecida.");

            // --- 3. Obtener Datos Principales del Alumno (personal e información académica) ---
            try {
                String sqlAlumno = "SELECT dni, nombre_completo, email, telefono, fecha_nacimiento, direccion, nombre_carrera, nombre_facultad, estado, ultimo_acceso " +
                                  "FROM vista_alumnos_completa WHERE id_alumno = ?";
                pstmt = conn.prepareStatement(sqlAlumno);
                pstmt.setInt(1, idAlumno);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    nombreAlumno = rs.getString("nombre_completo");
                    dniAlumno = rs.getString("dni") != null ? rs.getString("dni") : "N/A";
                    emailAlumno = rs.getString("email");
                    telefonoAlumno = rs.getString("telefono") != null ? rs.getString("telefono") : "N/A";
                    Date fechaNacimientoSql = rs.getDate("fecha_nacimiento");
                    fechaNacimientoAlumno = (fechaNacimientoSql != null ? new SimpleDateFormat("dd/MM/yyyy").format(fechaNacimientoSql) : "N/A");
                    direccionAlumno = rs.getString("direccion") != null ? rs.getString("direccion") : "N/A";
                    carreraAlumno = rs.getString("nombre_carrera") != null ? rs.getString("nombre_carrera") : "Desconocida";
                    facultadAlumno = rs.getString("nombre_facultad") != null ? rs.getString("nombre_facultad") : "Desconocida";
                    estadoAlumno = rs.getString("estado") != null ? rs.getString("estado") : "N/A";
                    Timestamp ultimoAccesoTimestamp = rs.getTimestamp("ultimo_acceso");
                    ultimoAcceso = (ultimoAccesoTimestamp != null ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(ultimoAccesoTimestamp) : "N/A");

                    session.setAttribute("nombre_alumno", nombreAlumno); // Update session attribute
                } else {
                    globalErrorMessage = "Alumno no encontrado en la base de datos. Por favor, contacte a soporte.";
                    System.err.println("ERROR (home_alumno): Alumno con ID " + idAlumno + " no encontrado en BD.");
                    session.invalidate(); // Invalidate session if student not found
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=" + java.net.URLEncoder.encode(globalErrorMessage, "UTF-8"));
                    return;
                }
            } finally { cerrarRecursos(rs, pstmt); }

            // --- 4. Obtener Cursos Detallados, Promedios y Datos de Asistencia/Calendario del Alumno ---
            if (globalErrorMessage == null) { // Only proceed if student data was found
                // a) Cursos Detallados del Alumno (para la tabla "Mis Cursos Inscritos")
                try {
                    String sqlCursosDetalle = "SELECT cu.nombre_curso, cu.codigo_curso, cu.creditos, "
                                            + "cl.seccion, cl.ciclo, cl.semestre, cl.año_academico, "
                                            + "p.nombre AS nombre_profesor, p.apellido_paterno AS apPaterno_profesor, "
                                            + "h.dia_semana, h.hora_inicio, h.hora_fin, h.aula, "
                                            + "n.nota_final, n.estado AS estado_nota "
                                            + "FROM inscripciones i "
                                            + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                            + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                            + "JOIN profesores p ON cl.id_profesor = p.id_profesor "
                                            + "JOIN horarios h ON cl.id_horario = h.id_horario "
                                            + "LEFT JOIN notas n ON i.id_inscripcion = n.id_inscripcion "
                                            + "WHERE i.id_alumno = ? AND i.estado = 'inscrito' "
                                            + "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso";

                    pstmt = conn.prepareStatement(sqlCursosDetalle);
                    pstmt.setInt(1, idAlumno);
                    rs = pstmt.executeQuery();

                    while(rs.next()) {
                        Map<String, String> cursoDetalle = new HashMap<>();
                        cursoDetalle.put("nombre_curso", rs.getString("nombre_curso"));
                        cursoDetalle.put("codigo_curso", rs.getString("codigo_curso"));
                        cursoDetalle.put("creditos", String.valueOf(rs.getInt("creditos")));
                        cursoDetalle.put("seccion", rs.getString("seccion"));
                        cursoDetalle.put("ciclo", rs.getString("ciclo"));
                        cursoDetalle.put("semestre", rs.getString("semestre"));
                        cursoDetalle.put("anio", String.valueOf(rs.getInt("año_academico"))); // Key changed to "anio" for consistency with HTML

                        String profNombre = rs.getString("nombre_profesor") != null ? rs.getString("nombre_profesor") : "";
                        String profApPaterno = rs.getString("apPaterno_profesor") != null ? rs.getString("apPaterno_profesor") : "";
                        String nombreProfesorCompleto = profNombre + " " + profApPaterno;
                        cursoDetalle.put("profesor", nombreProfesorCompleto);

                        cursoDetalle.put("dia_semana", rs.getString("dia_semana"));
                        cursoDetalle.put("hora_inicio", rs.getString("hora_inicio").substring(0, 5));
                        cursoDetalle.put("hora_fin", rs.getString("hora_fin").substring(0, 5));
                        cursoDetalle.put("aula", rs.getString("aula"));

                        double notaFinal = rs.getDouble("nota_final");
                        if (rs.wasNull()) {
                            cursoDetalle.put("nota_final", "N/A");
                            cursoDetalle.put("estado_nota", "PENDIENTE");
                        } else {
                            cursoDetalle.put("nota_final", String.format(Locale.US, "%.2f", notaFinal));
                            cursoDetalle.put("estado_nota", rs.getString("estado_nota").toUpperCase());
                        }
                        cursosAlumnoDetalleList.add(cursoDetalle);
                    }
                    totalCursosInscritos = cursosAlumnoDetalleList.size(); // Set the count
                } finally { cerrarRecursos(rs, pstmt); }

                // b) Promedios de Notas por Curso para el Gráfico
                try {
                    String sqlPromediosGrafico = "SELECT cu.nombre_curso, AVG(n.nota_final) AS promedio_nota "
                                                + "FROM inscripciones i "
                                                + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                                + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                                + "JOIN notas n ON i.id_inscripcion = n.id_inscripcion "
                                                + "WHERE i.id_alumno = ? AND n.nota_final IS NOT NULL "
                                                + "GROUP BY cu.nombre_curso ORDER BY promedio_nota DESC LIMIT 5";
                    pstmt = conn.prepareStatement(sqlPromediosGrafico);
                    pstmt.setInt(1, idAlumno);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        nombresCursosPromedio.add(rs.getString("nombre_curso"));
                        promediosCursos.add(rs.getDouble("promedio_nota"));
                    }
                } finally { cerrarRecursos(rs, pstmt); }

                // c) Clases del Alumno para el Calendario (para el mes actual)
                try {
                    String sqlClasesCalendario = "SELECT cl.id_clase, cu.nombre_curso, cl.seccion, "
                                                 + "h.dia_semana, h.hora_inicio, h.hora_fin, h.aula "
                                                 + "FROM inscripciones i "
                                                 + "JOIN clases cl ON i.id_clase = cl.id_clase "
                                                 + "JOIN cursos cu ON cl.id_curso = cu.id_curso "
                                                 + "JOIN horarios h ON cl.id_horario = h.id_horario "
                                                 + "WHERE i.id_alumno = ? AND i.estado = 'inscrito' AND cl.estado = 'activo' "
                                                 + "ORDER BY h.dia_semana, h.hora_inicio";
                    pstmt = conn.prepareStatement(sqlClasesCalendario);
                    pstmt.setInt(1, idAlumno);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        Map<String, String> clase = new HashMap<>();
                        clase.put("id_clase", String.valueOf(rs.getInt("id_clase")));
                        clase.put("nombre_curso", rs.getString("nombre_curso"));
                        clase.put("seccion", rs.getString("seccion"));
                        clase.put("dia_semana", rs.getString("dia_semana"));
                        clase.put("hora_inicio", rs.getString("hora_inicio").substring(0, 5));
                        clase.put("hora_fin", rs.getString("hora_fin").substring(0, 5));
                        clase.put("aula", rs.getString("aula"));
                        clasesParaCalendario.add(clase);
                    }
                    clasesActivas = clasesParaCalendario.size(); // Set the count
                } finally { cerrarRecursos(rs, pstmt); }

                // d) Datos para Gráfico Lineal de Asistencia del Mes (if needed, currently not displayed)
                try {
                    String sqlAsistenciaMensual = "SELECT DATE_FORMAT(a.fecha, '%Y-%m-%d') AS dia, "
                                                + "SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) AS presentes, "
                                                + "SUM(CASE WHEN a.estado = 'ausente' THEN 1 ELSE 0 END) AS ausentes, "
                                                + "SUM(CASE WHEN a.estado = 'tardanza' THEN 1 ELSE 0 END) AS tardanzas "
                                                + "FROM asistencia a "
                                                + "JOIN inscripciones i ON a.id_inscripcion = i.id_inscripcion "
                                                + "WHERE i.id_alumno = ? AND a.fecha BETWEEN ? AND ? "
                                                + "GROUP BY a.fecha ORDER BY a.fecha ASC";

                    pstmt = conn.prepareStatement(sqlAsistenciaMensual);
                    pstmt.setInt(1, idAlumno);
                    pstmt.setString(2, primerDiaMes.format(DateTimeFormatter.ISO_LOCAL_DATE)); // 'YYYY-MM-DD'
                    pstmt.setString(3, ultimoDiaMes.format(DateTimeFormatter.ISO_LOCAL_DATE)); // 'YYYY-MM-DD'
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        fechasAsistenciaMes.add(rs.getString("dia"));
                        presentesPorDia.add(rs.getInt("presentes"));
                        ausentesPorDia.add(rs.getInt("ausentes"));
                        tardanzasPorDia.add(rs.getInt("tardanzas"));
                    }
                } finally { cerrarRecursos(rs, pstmt); }

                // e) Pagos Pendientes del Alumno
                try {
                    String sqlPagosPendientes = "SELECT p.concepto, p.monto, p.fecha_vencimiento, p.estado "
                                                + "FROM pagos p "
                                                + "WHERE p.id_alumno = ? AND p.estado = 'pendiente' "
                                                + "ORDER BY p.fecha_vencimiento ASC";
                    pstmt = conn.prepareStatement(sqlPagosPendientes);
                    pstmt.setInt(1, idAlumno);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        Map<String, String> pago = new HashMap<>();
                        pago.put("concepto", rs.getString("concepto"));
                        pago.put("monto", String.format(Locale.US, "%.2f", rs.getDouble("monto")));
                        pago.put("fecha_vencimiento", new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("fecha_vencimiento")));
                        pago.put("estado", rs.getString("estado"));
                        pagosPendientesList.add(pago);
                    }
                    totalPagosPendientes = pagosPendientesList.size(); // Set the count
                } finally { cerrarRecursos(rs, pstmt); }
            }

        } // End of if (idAlumno != -1) for database operations

    } catch (SQLException e) {
        globalErrorMessage = "Error de base de datos al cargar la información: " + e.getMessage();
        System.err.println("ERROR (home_alumno) SQL Principal: " + globalErrorMessage);
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        globalErrorMessage = "Error de configuración: Driver JDBC no encontrado. Asegúrate de que el conector esté en WEB-INF/lib.";
        System.err.println("ERROR (home_alumno) DRIVER Principal: " + globalErrorMessage);
        e.printStackTrace();
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException ignore) {}
        }
    }
    String messageFromUrl = request.getParameter("message"); // Retrieve message after redirect
    String typeFromUrl = request.getParameter("type"); // Retrieve type after redirect
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Sistema Universitario</title>
    <link rel="icon" type="image/x-icon" href="<%= request.getContextPath()%>/img/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Estilos generales y variables de AdminKit (copied from previous files) */
        :root {
            --admin-dark: #222B40;
            --admin-light-bg: #F0F2F5;
            --admin-card-bg: #FFFFFF;
            --admin-text-dark: #333333;
            --admin-text-muted: #6C757D;
            --admin-primary: #007BFF;
            --admin-success: #28A745;
            --admin-danger: #DC3545;
            --admin-warning: #FFC107;
            --admin-info: #17A2B8;
            --admin-secondary-color: #6C757D;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--admin-light-bg);
            color: var(--admin-text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            overflow-x: hidden;
        }

        #app {
            display: flex;
            flex: 1;
            width: 100%;
        }

        .sidebar {
            width: 280px; background-color: var(--admin-dark); color: rgba(255,255,255,0.8); padding-top: 1rem; flex-shrink: 0;
            position: sticky; top: 0; left: 0; height: 100vh; overflow-y: auto; box-shadow: 2px 0 5px rgba(0,0,0,0.1); z-index: 1030;
        }

        .sidebar-header {
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            text-align: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--admin-primary);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .sidebar .nav-link {
            display: flex;
            align-items: center;
            padding: 0.75rem 1.5rem;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: all 0.2s ease-in-out;
            font-weight: 500;
        }

        .sidebar .nav-link i {
            margin-right: 0.75rem;
            font-size: 1.1rem;
        }

        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            color: white;
            background-color: rgba(255, 255, 255, 0.08);
            border-left: 4px solid var(--admin-primary);
            padding-left: 1.3rem;
        }

        .main-content {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .top-navbar {
            background-color: var(--admin-card-bg);
            padding: 1rem 1.5rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            margin-bottom: 1.5rem;
            border-radius: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .top-navbar .search-bar .form-control {
            border: 1px solid #e0e0e0;
            border-radius: 0.3rem;
            padding: 0.5rem 1rem;
        }

        .top-navbar .user-dropdown .dropdown-toggle {
            display: flex;
            align-items: center;
            color: var(--admin-text-dark);
            text-decoration: none;
        }
        .top-navbar .user-dropdown .dropdown-toggle img {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            margin-right: 0.5rem;
            object-fit: cover;
            border: 2px solid var(--admin-primary);
        }

        .welcome-section {
            background-color: var(--admin-card-bg);
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        }
        .welcome-section h1 {
            color: var(--admin-text-dark);
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        .welcome-section p.lead {
            color: var(--admin-text-muted);
            font-size: 1rem;
        }

        .content-section.card {
            border-radius: 0.5rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
            border-left: 4px solid var(--admin-primary);
            margin-bottom: 1.5rem;
        }
        .content-section.card .card-header {
             background-color: var(--admin-card-bg);
             border-bottom: 1px solid #dee2e6;
             padding-bottom: 1rem;
        }
        .content-section .section-title {
            color: var(--admin-primary);
            font-weight: 600;
            margin-bottom: 0;
        }
        .content-section.card .card-body p.text-muted {
            font-size: 0.95rem;
        }

        .table-responsive {
            max-height: 500px;
            overflow-y: auto;
            margin-top: 1rem;
        }
        .table {
            color: var(--admin-text-dark);
            margin-bottom: 0;
        }
        .table thead th {
            border-bottom: 2px solid var(--admin-primary);
            color: var(--admin-primary);
            font-weight: 600;
            background-color: var(--admin-light-bg);
            position: sticky;
            top: 0;
            z-index: 1;
        }
        .table tbody tr:hover {
            background-color: rgba(0, 123, 255, 0.05);
        }
        .table .badge {
            font-weight: 500;
            padding: 0.4em 0.7em;
            border-radius: 0.25rem;
        }
        .badge.bg-success { background-color: var(--admin-success) !important; }
        .badge.bg-danger { background-color: var(--admin-danger) !important; }
        .badge.bg-warning { background-color: var(--admin-warning) !important; color: var(--admin-text-dark) !important;}
        .badge.bg-info { background-color: var(--admin-info) !important; }
        .badge.bg-secondary { background-color: var(--admin-secondary-color) !important; }

        .chart-container {
            height: 300px;
            width: 100%;
            margin: auto;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 1rem;
        }
        .chart-container canvas {
            max-width: 100%;
            max-height: 100%;
        }

        .calendar-display {
            border: 1px solid #dee2e6;
            border-radius: 0.5rem;
            overflow: hidden;
            background-color: var(--admin-card-bg);
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
            padding: 1rem;
        }
        .calendar-days-header {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            text-align: center;
            background-color: var(--admin-light-bg);
            padding: 0.5rem 0;
            border-bottom: 1px solid #dee2e6;
            font-size: 0.9rem;
        }
        .calendar-days-header > div {
            padding: 0.25rem;
            color: var(--admin-primary);
        }
        .calendar-grid-dynamic {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 2px;
            text-align: center;
            padding-top: 0.5rem;
        }
        .calendar-grid-dynamic .day-cell {
            padding: 8px;
            min-height: 80px;
            border: 1px solid #f0f0f0;
            background-color: var(--admin-card-bg);
            font-size: 0.9rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            cursor: default;
        }
        .calendar-grid-dynamic .day-cell.other-month {
            background-color: var(--admin-light-bg);
            color: var(--admin-text-muted);
        }
        .calendar-grid-dynamic .day-number {
            font-weight: bold;
            font-size: 1.1em;
            margin-bottom: 5px;
            color: var(--admin-text-dark);
        }
        .calendar-grid-dynamic .day-cell.current-day {
            border: 2px solid var(--admin-primary);
            background-color: rgba(0, 123, 255, 0.1);
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
        }
        .calendar-grid-dynamic .day-cell .class-indicator {
            background-color: var(--admin-info);
            color: white;
            font-size: 0.7rem;
            padding: 2px 4px;
            border-radius: 3px;
            margin-top: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 90%;
        }
        .calendar-grid-dynamic .day-cell.has-classes {
            cursor: pointer;
        }
        .tooltip-inner {
            background-color: var(--admin-dark);
            color: white;
            max-width: 300px;
            padding: 0.75rem;
            font-size: 0.875rem;
            text-align: left;
        }
        .tooltip.bs-tooltip-auto[data-popper-placement^=top] .tooltip-arrow::before { border-top-color: var(--admin-dark); }
        .tooltip.bs-tooltip-auto[data-popper-placement^=bottom] .tooltip-arrow::before { border-bottom-color: var(--admin-dark); }
        .tooltip.bs-tooltip-auto[data-popper-placement^=left] .tooltip-arrow::before { border-left-color: var(--admin-dark); }
        .tooltip.bs-tooltip-auto[data-popper-placement^=right] .tooltip-arrow::before { border-right-color: var(--admin-dark); }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .sidebar { width: 220px; }
            .main-content { padding: 1rem; }
        }
        @media (max-width: 768px) {
            #app { flex-direction: column; }
            .sidebar {
                width: 100%; height: auto; position: relative;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1); padding-bottom: 0.5rem;
            }
            .sidebar .nav-link { justify-content: center; padding: 0.6rem 1rem;}
            .sidebar .nav-link i { margin-right: 0.5rem;}
            .top-navbar { flex-direction: column; align-items: flex-start;}
            .top-navbar .search-bar { width: 100%; margin-bottom: 1rem;}
            .top-navbar .user-dropdown { width: 100%; text-align: center;}
            .top-navbar .user-dropdown .dropdown-toggle { justify-content: center;}

            .welcome-section, .card { padding: 1rem;}
            .chart-container { height: 250px; }
        }
        @media (max-width: 576px) {
            .main-content { padding: 0.75rem; }
            .welcome-section, .card { padding: 0.75rem;}
            .calendar-grid-dynamic .day-cell { min-height: 60px; padding: 5px; font-size: 0.8rem; }
            .calendar-grid-dynamic .day-number { font-size: 1em; }
        }
    </style>
</head>
<body>
    <div id="app">
        <nav class="sidebar">
            <div class="sidebar-header">
                <a href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/home_alumno.jsp" class="text-white text-decoration-none">UGIC Portal</a>
            </div>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link active" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/home_alumno.jsp"><i class="fas fa-home"></i><span> Inicio</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/cursos_alumno.jsp"><i class="fas fa-book"></i><span> Mis Cursos</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/asistencia_alumno.jsp"><i class="fas fa-clipboard-check"></i><span> Mi Asistencia</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/notas_alumno.jsp"><i class="fas fa-percent"></i><span> Mis Notas</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/pagos_alumno.jsp"><i class="fas fa-money-bill-wave"></i><span> Mis Pagos</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/mensajes_alumno.jsp"><i class="fas fa-envelope"></i><span> Mensajes</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/perfil_alumno.jsp"><i class="fas fa-user"></i><span> Mi Perfil</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/configuracion_alumno.jsp"><i class="fas fa-cog"></i><span> Configuración</span></a>
                </li>
            </ul>
            <li class="nav-item mt-3">
                <form action="logout.jsp" method="post" class="d-grid gap-2">
                    <button type="submit" class="btn btn-outline-light mx-3"><i class="fas fa-sign-out-alt me-2"></i>Cerrar sesión</button>
                </form>
            </li>
        </nav>

        <div class="main-content">
            <nav class="top-navbar">
                <div class="search-bar">
                    <%-- Search Bar content, if any --%>
                </div>
                <div class="d-flex align-items-center">
                    <div class="me-3 dropdown">
                        <a class="text-dark" href="#" role="button" id="messagesDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-envelope fa-lg"></i>
                            <%-- You can add a badge for unread messages here if you fetch that count --%>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="messagesDropdown">
                            <li><a class="dropdown-item" href="mensajes_alumno.jsp">Ver todos</a></li>
                        </ul>
                    </div>

                    <div class="dropdown user-dropdown">
                        <a class="dropdown-toggle" href="#" role="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="https://via.placeholder.com/32" alt="Avatar"> <span class="d-none d-md-inline-block"><%= nombreAlumno%></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="perfil_alumno.jsp"><i class="fas fa-user me-2"></i>Perfil</a></li>
                            <li><a class="dropdown-item" href="configuracion_alumno.jsp"><i class="fas fa-cog me-2"></i>Configuración</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar sesión</a></li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="container-fluid">
                <div class="welcome-section">
                    <h1 class="h3 mb-3"><i class="fas fa-tachometer-alt me-2"></i>Dashboard del Alumno</h1>
                    <p class="lead">Bienvenido, <%= nombreAlumno%>. Este es tu panel de control para gestionar tu información académica.</p>
                </div>

                <% if (globalErrorMessage != null) {%>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i> <%= globalErrorMessage%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% }%>
                <% if (messageFromUrl != null && !messageFromUrl.isEmpty()) { %>
                    <div class="alert alert-<%= typeFromUrl != null ? typeFromUrl : "info" %> alert-dismissible fade show" role="alert">
                        <%= messageFromUrl %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>


                <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4 mb-4 stats-grid">
                    <div class="col">
                        <div class="card h-100 shadow-sm stat-card courses">
                            <div class="card-body">
                                <div class="icon-wrapper"><i class="fas fa-book"></i></div>
                                <h3 class="card-title">Cursos Inscritos</h3>
                                <div class="value" id="stat-cursos-inscritos"><%= totalCursosInscritos%></div>
                                <div class="description">Total de cursos matriculados</div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="card h-100 shadow-sm stat-card active-classes">
                            <div class="card-body">
                                <div class="icon-wrapper"><i class="fas fa-check-circle"></i></div>
                                <h3 class="card-title">Clases Activas</h3>
                                <div class="value" id="stat-clases-activas"><%= clasesActivas%></div>
                                <div class="description">Clases en curso actualmente</div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="card h-100 shadow-sm stat-card pending-payments">
                            <div class="card-body">
                                <div class="icon-wrapper"><i class="fas fa-money-bill-wave"></i></div>
                                <h3 class="card-title">Pagos Pendientes</h3>
                                <div class="value" id="stat-pagos-pendientes"><%= totalPagosPendientes%></div>
                                <div class="description">Mensualidades por pagar</div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="card h-100 shadow-sm stat-card student-status">
                            <div class="card-body">
                                <div class="icon-wrapper"><i class="fas fa-user-graduate"></i></div>
                                <h3 class="card-title">Mi Estado</h3>
                                <div class="value"><%= estadoAlumno.toUpperCase()%></div>
                                <div class="description">Estado académico actual</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow-sm h-100 info-section-card">
                            <div class="card-header">
                                <h3 class="section-title"><i class="fas fa-user me-2"></i>Mi Información Personal</h3>
                            </div>
                            <div class="card-body">
                                <p class="mb-1 info-detail-row"><strong>Nombre completo:</strong> <span><%= nombreAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>DNI:</strong> <span><%= dniAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Email:</strong> <span><%= emailAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Teléfono:</strong> <span><%= telefonoAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Fecha Nacimiento:</strong> <span><%= fechaNacimientoAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Dirección:</strong> <span><%= direccionAlumno%></span></p>
                                <p class="mb-0 info-detail-row"><strong>Último acceso:</strong> <span><%= ultimoAcceso%></span></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow-sm h-100 info-section-card">
                            <div class="card-header">
                                <h3 class="section-title"><i class="fas fa-university me-2"></i>Mi Información Académica</h3>
                            </div>
                            <div class="card-body">
                                <% if (idAlumno != -1) {%>
                                <p class="mb-1 info-detail-row"><strong>Carrera:</strong> <span><%= carreraAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Facultad:</strong> <span><%= facultadAlumno%></span></p>
                                <p class="mb-1 info-detail-row"><strong>Estado Académico:</strong> <span><%= estadoAlumno.toUpperCase()%></span></p>
                                <p class="mb-0 info-detail-row"><strong>Cursos Matriculados:</strong> <span><%= totalCursosInscritos%></span></p>
                                <% } else { %>
                                <p class="text-muted text-center py-3 mb-0">No se encontró información académica detallada.</p>
                                <% }%>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm mb-4 info-section-card">
                    <div class="card-header">
                        <h3 class="section-title"><i class="fas fa-book-open me-2"></i>Mis Cursos Inscritos</h3>
                        <a href="<%= request.getContextPath() %>/INTERFAZ_ALUMNO/solicitud_curso_alumno.jsp" class="btn btn-primary btn-sm float-end"><i class="fas fa-plus-circle me-1"></i>Solicitar Cursos</a>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <% if (!cursosAlumnoDetalleList.isEmpty()) { %> <%-- Changed to cursosAlumnoDetalleList --%>
                            <table class="table table-hover table-striped">
                                <thead>
                                    <tr>
                                        <th>Curso</th>
                                        <th>Sección</th>
                                        <th>Semestre</th>
                                        <th>Año</th>
                                        <th>Créditos</th>
                                        <th>Profesor</th>
                                        <th>Día</th>
                                        <th>Hora Inicio</th>
                                        <th>Hora Fin</th>
                                        <th>Aula</th>
                                        <th>Nota Final</th>
                                        <th>Estado Nota</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, String> curso : cursosAlumnoDetalleList) {%> <%-- Changed to cursosAlumnoDetalleList --%>
                                    <tr>
                                        <td><%= curso.get("nombre_curso")%></td>
                                        <td><%= curso.get("seccion")%></td>
                                        <td><%= curso.get("semestre")%></td>
                                        <td><%= curso.get("anio")%></td> <%-- Using "anio" key now --%>
                                        <td><%= curso.get("creditos")%></td>
                                        <td><%= curso.get("profesor")%></td>
                                        <td><%= curso.get("dia_semana")%></td>
                                        <td><%= curso.get("hora_inicio")%></td>
                                        <td><%= curso.get("hora_fin")%></td>
                                        <td><%= curso.get("aula")%></td>
                                        <td><%= curso.get("nota_final")%></td>
                                        <td>
                                            <%
                                                String estadoNota = curso.get("estado_nota");
                                                String badgeClass = "bg-secondary";
                                                if ("APROBADO".equalsIgnoreCase(estadoNota)) {
                                                    badgeClass = "bg-success";
                                                } else if ("DESAPROBADO".equalsIgnoreCase(estadoNota)) {
                                                    badgeClass = "bg-danger";
                                                } else if ("PENDIENTE".equalsIgnoreCase(estadoNota)) {
                                                    badgeClass = "bg-warning text-dark"; // Added text-dark for visibility
                                                }
                                            %>
                                            <span class="badge <%= badgeClass%>"><%= estadoNota%></span>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            <% } else { %>
                            <p class="text-muted text-center py-3">No estás inscrito en ningún curso actualmente.</p>
                            <% }%>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm mb-4 info-section-card">
                    <div class="card-header">
                        <h3 class="section-title"><i class="fas fa-receipt me-2"></i>Mis Pagos Pendientes</h3>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <% if (!pagosPendientesList.isEmpty()) { %>
                            <table class="table table-hover table-striped">
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
                                        <td><%= pago.get("concepto")%></td>
                                        <td>S/. <%= pago.get("monto")%></td>
                                        <td><%= pago.get("fecha_vencimiento")%></td>
                                        <td><span class="badge bg-warning text-dark"><%= pago.get("estado").toUpperCase()%></span></td>
                                        <td>
                                            <a href="#" onclick="alert('Funcionalidad de pago para <%= pago.get("concepto")%> por desarrollar.')" class="btn btn-primary btn-sm">
                                                <i class="fas fa-money-check-alt me-1"></i> Pagar
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            <% } else { %>
                            <p class="text-muted text-center py-3">No tienes pagos pendientes actualmente.</p>
                            <% }%>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="card shadow-sm h-100 calendar-widget-card">
                            <div class="card-header">
                                <h3 class="section-title mb-0"><i class="fas fa-calendar-alt me-2"></i>Calendario de Clases</h3>
                            </div>
                            <div class="card-body text-center">
                                <div class="calendar-header d-flex justify-content-between align-items-center mb-3">
                                    <button class="btn btn-sm btn-outline-primary" onclick="changeMonth(-1)"><i class="fas fa-chevron-left"></i></button>
                                    <h5><%= nombreMesActual.substring(0, 1).toUpperCase() + nombreMesActual.substring(1) %> <%= anioActual %></h5>
                                    <button class="btn btn-sm btn-outline-primary" onclick="changeMonth(1)"><i class="fas fa-chevron-right"></i></button>
                                </div>
                                <div class="calendar-grid-dynamic" id="calendarGrid">
                                    <div class="calendar-days-header">
                                        <div>Dom</div><div>Lun</div><div>Mar</div><div>Mié</div><div>Jue</div><div>Vie</div><div>Sáb</div>
                                    </div>
                                    <%
                                        // Calendar rendering logic
                                        int dayOfWeekValue = primerDiaMes.getDayOfWeek().getValue(); // 1 (Mon) to 7 (Sun)
                                        int startDayOffset = (dayOfWeekValue == 7) ? 0 : dayOfWeekValue; // 0 for Sunday, 1 for Monday...

                                        LocalDate tempDate = primerDiaMes.minusDays(startDayOffset);

                                        for (int i = 0; i < 42; i++) { // Render 6 weeks (6 * 7 days) to cover the month
                                            boolean isCurrentMonth = tempDate.getMonthValue() == mesActual && tempDate.getYear() == anioActual;
                                            boolean isToday = tempDate.isEqual(hoy);
                                            String dayCellClass = "day-cell";
                                            if (!isCurrentMonth) {
                                                dayCellClass += " other-month";
                                            }
                                            if (isToday) {
                                                dayCellClass += " current-day";
                                            }

                                            // Check for classes on this day
                                            List<Map<String, String>> classesOnThisDay = new ArrayList<>();
                                            String dayOfWeekSpanish = tempDate.getDayOfWeek().getDisplayName(TextStyle.FULL, new Locale("es", "ES"));
                                            for (Map<String, String> clase : clasesParaCalendario) {
                                                if (clase.get("dia_semana").equalsIgnoreCase(dayOfWeekSpanish)) {
                                                    classesOnThisDay.add(clase);
                                                }
                                            }

                                            if (!classesOnThisDay.isEmpty()) {
                                                dayCellClass += " has-classes";
                                            %>
                                                <div class="<%= dayCellClass %>" data-bs-toggle="tooltip" data-bs-placement="top" title="
                                                    <%
                                                        StringBuilder tooltipContent = new StringBuilder();
                                                        for (Map<String, String> clase : classesOnThisDay) {
                                                            tooltipContent.append(clase.get("nombre_curso")).append(" (").append(clase.get("seccion")).append(") - ");
                                                            tooltipContent.append(clase.get("hora_inicio")).append("-").append(clase.get("hora_fin")).append(" en ");
                                                            tooltipContent.append(clase.get("aula")).append("\n");
                                                        }
                                                        out.print(tooltipContent.toString().trim());
                                                    %>
                                                ">
                                                    <span class="day-number"><%= tempDate.getDayOfMonth() %></span>
                                                    <span class="class-indicator"><%= classesOnThisDay.size() %> clase(s)</span>
                                                </div>
                                            <%
                                            } else {
                                            %>
                                                <div class="<%= dayCellClass %>">
                                                    <span class="day-number"><%= tempDate.getDayOfMonth() %></span>
                                                </div>
                                            <%
                                            }
                                            tempDate = tempDate.plusDays(1);
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card shadow-sm h-100 digital-clock-card">
                            <div class="card-header">
                                <h3 class="section-title mb-0"><i class="fas fa-clock me-2"></i>Hora Actual</h3>
                            </div>
                            <div class="card-body d-flex flex-column justify-content-center align-items-center">
                                <div id="digitalClock" class="digital-clock" style="font-size: 3rem; font-weight: bold; color: var(--admin-primary);"></div>
                                <div id="digitalDate" class="digital-date" style="font-size: 1.2rem; color: var(--admin-text-muted);"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card shadow-sm mb-4 info-section-card">
                    <div class="card-header">
                        <h3 class="section-title"><i class="fas fa-bolt me-2"></i>Acciones Rápidas</h3>
                    </div>
                    <div class="card-body">
                        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4 quick-actions">
                            <div class="col">
                                <div class="card h-100 text-center shadow-sm card-border-primary">
                                    <div class="card-body">
                                        <i class="fas fa-clipboard-check mb-3 display-4 text-primary"></i>
                                        <h4 class="card-title h5">Ver Asistencia</h4>
                                        <p class="card-text text-muted">Consulta tu registro de asistencia.</p>
                                        <a href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/asistencia_alumno.jsp" class="btn btn-primary action-btn-custom">Ir ahora</a>
                                    </div>
                                </div>
                            </div>

                            <div class="col">
                                <div class="card h-100 text-center shadow-sm card-border-primary">
                                    <div class="card-body">
                                        <i class="fas fa-graduation-cap mb-3 display-4 text-primary"></i>
                                        <h4 class="card-title h5">Ver Notas</h4>
                                        <p class="card-text text-muted">Revisa tus calificaciones.</p>
                                        <a href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/notas_alumno.jsp" class="btn btn-primary action-btn-custom">Ir ahora</a>
                                    </div>
                                </div>
                            </div>

                            <div class="col">
                                <div class="card h-100 text-center shadow-sm card-border-primary">
                                    <div class="card-body">
                                        <i class="fas fa-money-bill-wave mb-3 display-4 text-primary"></i>
                                        <h4 class="card-title h5">Historial de Pagos</h4>
                                        <p class="card-text text-muted">Consulta tus pagos realizados y pendientes.</p>
                                        <a href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/pagos_alumno.jsp" class="btn btn-primary action-btn-custom">Ver historial</a>
                                    </div>
                                </div>
                            </div>

                            <div class="col">
                                <div class="card h-100 text-center shadow-sm card-border-primary">
                                    <div class="card-body">
                                        <i class="fas fa-envelope mb-3 display-4 text-primary"></i>
                                        <h4 class="card-title h5">Mensajes</h4>
                                        <p class="card-text text-muted">Revisa los mensajes y comunicados importantes.</p>
                                        <a href="<%= request.getContextPath()%>/INTERFAZ_ALUMNO/mensajes_alumno.jsp" class="btn btn-primary action-btn-custom">Ver mensajes</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
