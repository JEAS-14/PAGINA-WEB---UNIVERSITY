<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.nio.charset.StandardCharsets" %> <%-- For consistent UTF-8 encoding --%>
<%@ page session="true" %>

<%!
    // Método para cerrar recursos de BD
    private static void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try { if (rs != null) { rs.close(); } } catch (SQLException e) { /* Ignorar */ }
        try { if (pstmt != null) { pstmt.close(); } } catch (SQLException e) { /* Ignorar */ }
    }

    // Helper method for manual JSON string escaping
    // This is crucial to correctly format strings for JSON, handling special characters like quotes, backslashes, newlines, etc.
    private String escapeJson(String text) {
        if (text == null) {
            return "null"; // JSON null literal
        }
        StringBuilder sb = new StringBuilder();
        sb.append("\""); // Start with a double quote
        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);
            switch (ch) {
                case '"':
                    sb.append("\\\""); // Escape double quotes
                    break;
                case '\\':
                    sb.append("\\\\"); // Escape backslashes
                    break;
                case '\b':
                    sb.append("\\b"); // Escape backspace
                    break;
                case '\f':
                    sb.append("\\f"); // Escape form feed
                    break;
                case '\n':
                    sb.append("\\n"); // Escape newline
                    break;
                case '\r':
                    sb.append("\\r"); // Escape carriage return
                    break;
                case '\t':
                    sb.append("\\t"); // Escape tab
                    break;
                // Handle control characters (00-1F) and potentially other non-ASCII characters if necessary
                default:
                    if (ch < 32 || ch > 126) { // Characters outside printable ASCII range
                        String hex = Integer.toHexString(ch);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - hex.length(); k++) {
                            sb.append('0'); // Pad with leading zeros
                        }
                        sb.append(hex.toUpperCase());
                    } else {
                        sb.append(ch);
                    }
            }
        }
        sb.append("\""); // End with a double quote
        return sb.toString();
    }
%>

<%
    // ====================================================================
    // 🧪 FORZAR SESIÓN TEMPORALMENTE PARA APODERADO (SOLO PARA TEST)
    // REMOVER ESTE BLOQUE EN PRODUCCIÓN O CUANDO EL LOGIN REAL FUNCIONE
    if (session.getAttribute("id_apoderado") == null) {
        session.setAttribute("email", "roberto.sanchez@gmail.com"); // Email de un apoderado que exista en tu BD (ID 1 en bd_sw.sql)
        session.setAttribute("rol", "apoderado");
        session.setAttribute("id_apoderado", 1);    // ID del apoderado en tu BD (ej: Roberto Carlos Sánchez Díaz)
        System.out.println("DEBUG (mensaje_apoderado): Sesión forzada para prueba.");
    }
    // ====================================================================

    // --- Obtener información de la sesión ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idApoderadoObj = session.getAttribute("id_apoderado");

    // Initialize globalErrorMessage, message, messageType at the top of the scriptlet
    String globalErrorMessage = null; 
    String message = null;
    String messageType = null; // success o danger

    if (emailSesion == null || !"apoderado".equalsIgnoreCase(rolUsuario) || idApoderadoObj == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); // Redirigir al login si no está autenticado
        return;
    }

    int idApoderado = -1;
    try {
        idApoderado = Integer.parseInt(String.valueOf(idApoderadoObj));
    } catch (NumberFormatException e) {
        // Redirigir si el ID de apoderado en sesión no es un número válido
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=" + URLEncoder.encode("ID de apoderado inválido en sesión.", StandardCharsets.UTF_8.toString()));
        return;
    }

    // --- Variables para los datos del apoderado y el hijo (para la UI) ---
    String nombreApoderado = "Apoderado Desconocido";
    String nombreHijo = "Hijo No Asignado";
    int idHijo = -1; // ID del hijo, necesario para filtrar docentes
    String emailApoderado = emailSesion; // Email en la barra superior

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try { // MAIN TRY BLOCK START
        Conexion c = new Conexion();
        conn = c.conecta(); // Intentamos conectar a la BD

        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos."); // Forzar error si la conexión falla
        }

        // --- Lógica para MANEJAR SOLICITUDES AJAX (Búsqueda de docentes) ---
        String searchTerm = request.getParameter("term");
        String requestType = request.getParameter("requestType"); // ej. "getAllTeachersOfMyChildCourses"

        // Check if this is an AJAX request for teacher data
        if (searchTerm != null || "getAllTeachersOfMyChildCourses".equals(requestType)) {
            response.setContentType("application/json;charset=UTF-8");
            StringBuilder jsonArrayBuilder = new StringBuilder(); // Use StringBuilder for manual JSON
            jsonArrayBuilder.append("["); // Start JSON array

            try { // INNER TRY BLOCK for AJAX response
                // Primero, obtener el ID del hijo del apoderado logueado
                String sqlGetHijoId = "SELECT id_alumno FROM alumno_apoderado WHERE id_apoderado = ? LIMIT 1";
                pstmt = conn.prepareStatement(sqlGetHijoId);
                pstmt.setInt(1, idApoderado);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    idHijo = rs.getInt("id_alumno");
                } 
                cerrarRecursos(rs, pstmt); // Close resources for this query

                if (idHijo != -1) { // Si se encontró un hijo
                    String sqlTeachers;
                    if ("getAllTeachersOfMyChildCourses".equals(requestType)) {
                        // Obtener todos los docentes de los cursos en los que el hijo está inscrito
                        sqlTeachers = "SELECT DISTINCT p.id_profesor, p.dni, p.nombre, p.apellido_paterno, p.apellido_materno, p.email "
                                    + "FROM profesores p "
                                    + "JOIN clases cl ON p.id_profesor = cl.id_profesor "
                                    + "JOIN inscripciones i ON cl.id_clase = i.id_clase "
                                    + "WHERE i.id_alumno = ? AND cl.estado = 'activo' " // Solo clases activas del hijo
                                    + "ORDER BY p.apellido_paterno, p.nombre";
                        pstmt = conn.prepareStatement(sqlTeachers);
                        pstmt.setInt(1, idHijo);
                        rs = pstmt.executeQuery();

                    } else { // It's a regular search by 'term'
                        if (searchTerm == null || searchTerm.trim().isEmpty() || searchTerm.trim().length() < 3) {
                            // Don't append anything to jsonArrayBuilder, it will result in "[]"
                            out.print(jsonArrayBuilder.append("]").toString()); // Send empty JSON array
                            out.flush();
                            return; // Exit here for empty/short search term
                        }
                        
                        // Search teachers by name, DNI or email, BUT ONLY those who teach the child's courses
                        sqlTeachers = "SELECT DISTINCT p.id_profesor, p.dni, p.nombre, p.apellido_paterno, p.apellido_materno, p.email "
                                    + "FROM profesores p "
                                    + "JOIN clases cl ON p.id_profesor = cl.id_profesor "
                                    + "JOIN inscripciones i ON cl.id_clase = i.id_clase "
                                    + "WHERE i.id_alumno = ? AND cl.estado = 'activo' AND ( " // Teachers of child's active courses
                                    + "    LOWER(CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', IFNULL(p.apellido_materno, ''))) LIKE LOWER(?) OR "
                                    + "    p.dni LIKE ? OR "
                                    + "    LOWER(p.email) LIKE LOWER(?) "
                                    + ") LIMIT 10"; // Limit results
                        pstmt = conn.prepareStatement(sqlTeachers);
                        String searchPattern = "%" + searchTerm.trim() + "%";
                        pstmt.setInt(1, idHijo);
                        pstmt.setString(2, searchPattern);
                        pstmt.setString(3, searchPattern);
                        pstmt.setString(4, searchPattern);
                        rs = pstmt.executeQuery();
                    }

                    boolean firstTeacher = true; // Flag for comma separation
                    while (rs.next()) {
                        if (!firstTeacher) {
                            jsonArrayBuilder.append(",");
                        }
                        jsonArrayBuilder.append("{");
                        jsonArrayBuilder.append("\"id_profesor\": ").append(rs.getInt("id_profesor")).append(",");
                        jsonArrayBuilder.append("\"dni\": ").append(escapeJson(rs.getString("dni"))).append(",");
                        
                        String nombre = rs.getString("nombre") != null ? rs.getString("nombre") : "";
                        String apPaterno = rs.getString("apellido_paterno") != null ? rs.getString("apellido_paterno") : "";
                        String apMaterno = rs.getString("apellido_materno") != null ? rs.getString("apellido_materno") : "";
                        String nombreCompleto = nombre + " " + apPaterno;
                        if (!apMaterno.isEmpty()) { nombreCompleto += " " + apMaterno; }
                        jsonArrayBuilder.append("\"nombre_completo\": ").append(escapeJson(nombreCompleto)).append(",");
                        jsonArrayBuilder.append("\"email\": ").append(escapeJson(rs.getString("email")));
                        jsonArrayBuilder.append("}");
                        firstTeacher = false;
                    }
                }

            } catch (SQLException e) { // Catch for INNER TRY BLOCK
                System.err.println("Error SQL en AJAX de mensaje_apoderado.jsp: " + e.getMessage());
                // In case of error, jsonArrayBuilder will contain "[]" or incomplete, which is valid JSON.
    }
        }

        // --- Lógica para MANEJAR SOLICITUD POST (Envío de Mensaje) ---
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String asunto = request.getParameter("asunto");
            String contenido = request.getParameter("contenido");
            String destinatariosIds = request.getParameter("destinatarios_ids");

            String[] idsArray = destinatariosIds.split(",");
            List<Integer> docentesAEnviar = new ArrayList<>();

            for (String idStr : idsArray) {
                try {
                    if (!idStr.trim().isEmpty()) {
                        docentesAEnviar.add(Integer.parseInt(idStr.trim()));
                    }
                } catch (NumberFormatException nfe) {
                    System.err.println("Advertencia: ID de docente inválido encontrado y omitido: " + idStr);
                }
            }

            String redirectURL = request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp";

            if (docentesAEnviar.isEmpty()) {
                response.sendRedirect(redirectURL + "?message=" + URLEncoder.encode("Debes seleccionar al menos un docente destinatario.", StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode("danger", StandardCharsets.UTF_8.toString()));
                return;
            }

            conn.setAutoCommit(false); // Start transaction

            String sqlInsertMensaje = "INSERT INTO mensajes (id_remitente, tipo_remitente, id_destinatario, tipo_destinatario, asunto, contenido, fecha_envio) VALUES (?, 'apoderado', ?, 'profesor', ?, ?, NOW())";
            pstmt = conn.prepareStatement(sqlInsertMensaje);

            for (Integer idDocente : docentesAEnviar) {
                pstmt.setInt(1, idApoderado); // The apoderado is the sender
                pstmt.setInt(2, idDocente);    // The teacher is the recipient
                pstmt.setString(3, asunto);
                pstmt.setString(4, contenido);
                pstmt.addBatch(); // Add to batch for efficient insertion
            }

            int[] results = pstmt.executeBatch(); // Execute all insertions
            conn.commit(); // Commit transaction

            int mensajesEnviadosCount = 0;
            for (int res : results) {
                if (res > 0) {
                    mensajesEnviadosCount++;
                }
            }

            if (mensajesEnviadosCount == docentesAEnviar.size()) {
                message = "Mensajes enviados correctamente a " + mensajesEnviadosCount + " docente(s).";
                messageType = "success";
            } else if (mensajesEnviadosCount > 0) {
                message = "Se enviaron algunos mensajes, pero no a todos los docentes (" + mensajesEnviadosCount + "/" + docentesAEnviar.size() + ").";
                messageType = "danger";
            } else {
                message = "No se pudo enviar mensajes a ningún docente.";
                messageType = "danger";
            }
            
            response.sendRedirect(redirectURL + "?message=" + URLEncoder.encode(message, StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode(messageType, StandardCharsets.UTF_8.toString()));
            return; // Important! Terminate JSP execution here for POST request

        }

        // --- Lógica para CARGAR DATOS (Initial GET request or after POST redirect) ---
        // Get child's name for the UI
        PreparedStatement pstmtHijoGet = null;
        ResultSet rsHijoGet = null;
        try {
            String sqlHijoGet = "SELECT a.nombre, a.apellido_paterno, a.apellido_materno "
                                + "FROM alumnos a JOIN alumno_apoderado aa ON a.id_alumno = aa.id_alumno "
                                + "WHERE aa.id_apoderado = ? LIMIT 1";
            pstmtHijoGet = conn.prepareStatement(sqlHijoGet);
            pstmtHijoGet.setInt(1, idApoderado);
            rsHijoGet = pstmtHijoGet.executeQuery();
            if (rsHijoGet.next()) {
                String nombre = rsHijoGet.getString("nombre") != null ? rsHijoGet.getString("nombre") : "";
                String apPaterno = rsHijoGet.getString("apellido_paterno") != null ? rsHijoGet.getString("apellido_paterno") : "";
                String apMaterno = rsHijoGet.getString("apellido_materno") != null ? rsHijoGet.getString("apellido_materno") : "";
                nombreHijo = nombre + " " + apPaterno;
                if (!apMaterno.isEmpty()) { nombreHijo += " " + apMaterno; }
            } else {
                // If no child is associated, "Hijo No Asignado" will remain
                System.err.println("Advertencia: No se encontró hijo para apoderado ID: " + idApoderado + " al cargar la página.");
            }
        } finally { cerrarRecursos(rsHijoGet, pstmtHijoGet); }

        // Load feedback messages if they come from the URL
        String paramMessage = request.getParameter("message");
        String paramType = request.getParameter("type");
        if (paramMessage != null && !paramMessage.isEmpty()) {
            message = java.net.URLDecoder.decode(paramMessage, StandardCharsets.UTF_8.toString());
            messageType = java.net.URLDecoder.decode(paramType, StandardCharsets.UTF_8.toString());
        }

    } catch (SQLException e) { // Catch for MAIN TRY BLOCK
        globalErrorMessage = "Error de base de datos: " + e.getMessage();
        System.err.println("ERROR SQL Principal en mensaje_apoderado.jsp: " + globalErrorMessage);
        e.printStackTrace();
        if (conn != null) { try { conn.rollback(); } catch (SQLException ignore) {} } // Rollback in case of principal error
    } catch (ClassNotFoundException e) { // Catch for MAIN TRY BLOCK
        // This catch block is intentionally left, even if no org.json is imported,
        // in case some other dependency or legacy code implicitly tries to load it.
        globalErrorMessage = "Error de configuración: Driver JDBC no encontrado.";
        System.err.println("ERROR ClassNotFound Principal en mensaje_apoderado.jsp: " + globalErrorMessage);
        e.printStackTrace();
    } finally { // FINALLY for MAIN TRY BLOCK
        // Ensure the main connection is ALWAYS closed
        if (conn != null) {
            try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { System.err.println("Error al cerrar conexión final: " + e.getMessage()); }
        }
    } // MAIN TRY BLOCK END
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mensajes | Dashboard Apoderado | Sistema Universitario</title>
    <link rel="icon" type="image/x-icon" href="<%= request.getContextPath() %>/img/favicon.ico">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Variables de estilo para consistencia con AdminKit */
        :root {
            --admin-dark: #222B40; /* Color oscuro para sidebar y navbar */
            --admin-light-bg: #F0F2F5; /* Fondo claro para el main content */
            --admin-card-bg: #FFFFFF; /* Fondo de las tarjetas */
            --admin-text-dark: #333333; /* Texto principal */
            --admin-text-muted: #6C757D; /* Texto secundario/gris */
            --admin-primary: #007BFF; /* Azul principal de AdminKit */
            --admin-success: #28A745; /* Verde para aprobación */
            --admin-danger: #DC3545; /* Rojo para desaprobación */
            --admin-warning: #FFC107; /* Amarillo para pendientes */
            --admin-info: #17A2B8; /* Cian para información */
            --admin-secondary-color: #6C757D; /* Un gris más oscuro para detalles */
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

        /* Sidebar */
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

        /* Contenido principal */
        .main-content {
            flex: 1;
            padding: 1.5rem;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        /* Navbar superior */
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

        /* Welcome Section */
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

        /* Content Card Styling */
        .content-section.card {
            border-radius: 0.5rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
            border-left: 4px solid var(--admin-primary); /* Default border color */
            margin-bottom: 1.5rem;
        }
        .content-section.card .card-header {
             background-color: var(--admin-card-bg); /* Keep header white */
             border-bottom: 1px solid #dee2e6; /* Light separator */
             padding-bottom: 1rem;
        }
        .content-section .section-title {
            color: var(--admin-primary);
            font-weight: 600;
            margin-bottom: 0; /* Adjusted for card-header title */
        }
        .content-section.card .card-body p.text-muted {
            font-size: 0.95rem; /* Slightly larger text for general info */
        }

        /* Form elements */
        .form-label {
            font-weight: 600;
            color: var(--admin-text-dark);
            margin-bottom: 0.5rem;
        }
        .form-control, .form-select {
            border-radius: 0.3rem;
            border-color: #dee2e6;
            padding: 0.75rem 1rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--admin-primary);
            box-shadow: 0 0 0 0.25rem rgba(0, 123, 255, 0.25);
        }
        textarea.form-control {
            min-height: 150px;
            resize: vertical;
        }

        /* Search input and results list */
        .search-input-container {
            position: relative;
            margin-bottom: 1rem;
        }
        .search-results-list {
            list-style-type: none;
            padding: 0;
            margin: 0;
            border: 1px solid #ddd;
            border-top: none;
            max-height: 200px;
            overflow-y: auto;
            background-color: var(--admin-card-bg);
            position: absolute;
            width: 100%;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            border-radius: 0 0 0.3rem 0.3rem;
        }
        .search-results-list li {
            padding: 0.8rem;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--admin-text-dark);
        }
        .search-results-list li:hover {
            background-color: var(--admin-light-bg);
        }
        .search-results-list li:last-child { border-bottom: none; }
        .search-results-list li .text-muted { font-size: 0.85rem; }

        /* Selected recipients list */
        .selected-recipients {
            list-style-type: none;
            padding: 0.75rem;
            margin-top: 0.5rem;
            border: 1px solid var(--admin-info);
            background-color: rgba(23, 162, 184, 0.1);
            border-radius: 0.5rem;
            max-height: 180px;
            overflow-y: auto;
        }
        .selected-recipients li {
            background-color: var(--admin-info);
            color: white;
            padding: 0.5rem 0.75rem;
            margin-bottom: 0.5rem;
            border-radius: 0.3rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9em;
            word-break: break-word;
        }
        .selected-recipients li:last-child { margin-bottom: 0; }
        .selected-recipients li .remove-recipient {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 1.2em;
            margin-left: 10px;
            transition: color 0.2s;
            opacity: 0.8;
        }
        .selected-recipients li .remove-recipient:hover {
            color: var(--admin-warning);
            opacity: 1;
        }
        .recipient-count {
            font-size: 0.9em;
            color: var(--admin-text-muted);
            text-align: right;
            margin-top: 0.5rem;
        }

        /* Buttons */
        .btn-primary-custom {
            background-color: var(--admin-primary);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 0.3rem;
            transition: background-color 0.2s ease, transform 0.2s ease;
        }
        .btn-primary-custom:hover {
            background-color: #0056b3;
            transform: translateY(-2px);
            color: white;
        }
        .btn-secondary-custom {
            background-color: var(--admin-secondary-color);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 0.3rem;
            transition: background-color 0.2s ease, transform 0.2s ease;
        }
        .btn-secondary-custom:hover {
            background-color: #5a6268;
            transform: translateY(-2px);
            color: white;
        }

        /* Alert messages */
        .alert-custom {
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
            border-radius: 0.375rem;
        }
        .alert-success-custom {
            background-color: rgba(40, 167, 69, 0.1);
            border-color: var(--admin-success);
            color: var(--admin-success);
        }
        .alert-danger-custom {
            background-color: rgba(220, 53, 69, 0.1);
            border-color: var(--admin-danger);
            color: var(--admin-danger);
        }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .sidebar {
                width: 220px;
            }
            .main-content {
                padding: 1rem;
            }
        }
        @media (max-width: 768px) {
            #app {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
                padding-bottom: 0.5rem;
            }
            .sidebar .nav-link {
                justify-content: center;
                padding: 0.6rem 1rem;
            }
            .sidebar .nav-link i {
                margin-right: 0.5rem;
            }
            .top-navbar {
                flex-direction: column;
                align-items: flex-start;
            }
            .top-navbar .search-bar {
                width: 100%;
                margin-bottom: 1rem;
            }
            .top-navbar .user-dropdown {
                width: 100%;
                text-align: center;
            }
            .top-navbar .user-dropdown .dropdown-toggle {
                justify-content: center;
            }
            .content-card.card {
                padding: 1.5rem 1rem;
            }
        }
        @media (max-width: 576px) {
            .main-content {
                padding: 0.75rem;
            }
            .welcome-section, .content-card.card {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div id="app">
        <nav class="sidebar">
            <div class="sidebar-header">
                <a href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/home_apoderado.jsp" class="text-white text-decoration-none">UGIC Portal</a>
            </div>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/home_apoderado.jsp"><i class="fas fa-home"></i><span> Inicio</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/cursos_apoderado.jsp"><i class="fas fa-book"></i><span> Cursos de mi hijo</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/asistencia_apoderado.jsp"><i class="fas fa-clipboard-check"></i><span> Asistencia de mi hijo</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/notas_apoderado.jsp"><i class="fas fa-percent"></i><span> Notas de mi hijo</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/pagos_apoderado.jsp"><i class="fas fa-money-bill-wave"></i><span> Pagos y Mensualidades</span></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="<%= request.getContextPath()%>/INTERFAZ_APODERADO/mensajes_apoderado.jsp"><i class="fas fa-envelope"></i><span> Mensajes</span></a>
                </li>
            </ul>
            <li class="nav-item mt-3">
                <form action="<%= request.getContextPath()%>/logout.jsp" method="post" class="d-grid gap-2">
                    <button type="submit" class="btn btn-outline-light mx-3"><i class="fas fa-sign-out-alt me-2"></i>Cerrar sesión</button>
                </form>
            </li>
        </nav>

        <div class="main-content">
            <nav class="top-navbar">
                <div class="search-bar">
                    <form class="d-flex">
                        <input class="form-control me-2" type="search" placeholder="Buscar..." aria-label="Search">
                        <button class="btn btn-outline-secondary" type="submit"><i class="fas fa-search"></i></button>
                    </form>
                </div>
                <div class="d-flex align-items-center">
                    <div class="me-3 dropdown">
                        <a class="text-dark" href="#" role="button" id="notificationsDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-bell fa-lg"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                3
                            </span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="notificationsDropdown">
                            <li><a class="dropdown-item" href="#">Nueva notificación</a></li>
                            <li><a class="dropdown-item" href="#">Recordatorio</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">Ver todas</a></li>
                        </ul>
                    </div>
                    <div class="me-3 dropdown">
                        <a class="text-dark" href="#" role="button" id="messagesDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-envelope fa-lg"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                2
                            </span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="messagesDropdown">
                            <li><a class="dropdown-item" href="#">Mensaje de Profesor X</a></li>
                            <li><a class="dropdown-item" href="#">Mensaje de Administración</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#">Ver todos</a></li>
                        </ul>
                    </div>

                    <div class="dropdown user-dropdown">
                        <a class="dropdown-toggle" href="#" role="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="https://via.placeholder.com/32" alt="Avatar"> <span class="d-none d-md-inline-block"><%= nombreApoderado%></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Perfil</a></li>
                            <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Configuración</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="<%= request.getContextPath()%>/logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Cerrar sesión</a></li>
                        </ul>
                    </div>
                </div>
            </nav>

            <div class="container-fluid">
                <div class="welcome-section">
                    <h1 class="h3 mb-3"><i class="fas fa-envelope me-2"></i>Enviar Mensaje a Docentes</h1>
                    <p class="lead">Envía un mensaje a los docentes de tu hijo/a.</p>
                </div>

                <% if (message != null) { %>
                    <div class="alert alert-<%= messageType %>-custom alert-dismissible fade show" role="alert">
                        <i class="fas <%= "success".equals(messageType) ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i>
                        <%= message %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>

                <div class="card content-section mb-4">
                    <div class="card-header">
                        <h3 class="section-title mb-0"><i class="fas fa-paper-plane me-2"></i>Nuevo Mensaje</h3>
                    </div>
                    <div class="card-body">
                        <form id="sendMessageForm" action="<%= request.getContextPath()%>/INTERFAZ_APODERADO/mensajes_apoderado.jsp" method="POST">
                            <div class="mb-3">
                                <label for="teacherSearchInput" class="form-label">Buscar Docente:</label>
                                <div class="search-input-container">
                                    <input type="text" class="form-control" id="teacherSearchInput" placeholder="Escribe nombre, DNI o email del docente">
                                    <ul id="teacherSearchResults" class="search-results-list" style="display: none;">
                                        </ul>
                                </div>
                                <small class="form-text text-muted">Empieza a escribir para buscar docentes de los cursos de tu hijo/a. Mínimo 3 caracteres.</small>
                            </div>

                            <div class="mb-3">
                                <label for="selectedRecipientsList" class="form-label">Destinatario(s) Seleccionado(s):</label>
                                <ul id="selectedRecipientsList" class="selected-recipients">
                                </ul>
                                <input type="hidden" name="destinatarios_ids" id="destinatarios_ids">
                                <p class="recipient-count text-end">0 docentes seleccionados</p>
                            </div>

                            <div class="mb-3">
                                <label for="subjectInput" class="form-label">Asunto:</label>
                                <input type="text" class="form-control" id="subjectInput" name="asunto" required maxlength="255">
                            </div>

                            <div class="mb-3">
                                <label for="contentInput" class="form-label">Contenido del Mensaje:</label>
                                <textarea class="form-control" id="contentInput" name="contenido" rows="6" required></textarea>
                            </div>

                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <button type="reset" class="btn btn-secondary-custom"><i class="fas fa-eraser me-2"></i>Limpiar</button>
                                <button type="submit" class="btn btn-primary-custom"><i class="fas fa-paper-plane me-2"></i>Enviar Mensaje</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> <%-- Include jQuery for easier AJAX --%>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const teacherSearchInput = document.getElementById('teacherSearchInput');
            const teacherSearchResults = document.getElementById('teacherSearchResults');
            const selectedRecipientsList = document.getElementById('selectedRecipientsList');
            const destinatariosIdsInput = document.getElementById('destinatarios_ids');
            const recipientCountDisplay = document.querySelector('.recipient-count');

            let selectedTeachers = new Map(); // Map to store selected teachers: id -> {id, name}

            function updateSelectedRecipientsDisplay() {
                selectedRecipientsList.innerHTML = '';
                const ids = [];
                selectedTeachers.forEach((teacher, id) => {
                    const listItem = document.createElement('li');
                    listItem.dataset.id = id;
                    listItem.innerHTML = `
                        <span>${teacher.nombre_completo} (${teacher.email})</span>
                        <button type="button" class="remove-recipient" aria-label="Eliminar destinatario">
                            <i class="fas fa-times"></i>
                        </button>
                    `;
                    selectedRecipientsList.appendChild(listItem);
                    ids.push(id);
                });
                destinatariosIdsInput.value = ids.join(',');
                recipientCountDisplay.textContent = `${selectedTeachers.size} docente(s) seleccionado(s)`;
            }

            // Remove recipient when 'X' button is clicked
            selectedRecipientsList.addEventListener('click', function (event) {
                if (event.target.closest('.remove-recipient')) {
                    const listItem = event.target.closest('li');
                    const teacherId = parseInt(listItem.dataset.id);
                    selectedTeachers.delete(teacherId);
                    updateSelectedRecipientsDisplay();
                }
            });

            let searchTimeout;
            teacherSearchInput.addEventListener('input', function () {
                const searchTerm = this.value.trim();
                clearTimeout(searchTimeout);

                if (searchTerm.length >= 3) {
                    searchTimeout = setTimeout(() => {
                        fetch(`<%= request.getContextPath()%>/INTERFAZ_APODERADO/mensajes_apoderado.jsp?term=${encodeURIComponent(searchTerm)}`)
                            .then(response => {
                                if (!response.ok) {
                                    throw new Error('Network response was not ok');
                                }
                                // Expect plain text and parse it as JSON
                                return response.text().then(text => JSON.parse(text));
                            })
                            .then(data => {
                                teacherSearchResults.innerHTML = '';
                                if (data.length > 0) {
                                    data.forEach(teacher => {
                                        // Only add to results if not already selected
                                        if (!selectedTeachers.has(teacher.id_profesor)) {
                                            const listItem = document.createElement('li');
                                            listItem.dataset.id = teacher.id_profesor;
                                            listItem.dataset.name = teacher.nombre_completo;
                                            listItem.dataset.email = teacher.email;
                                            listItem.innerHTML = `
                                                <i class="fas fa-user-tie"></i>
                                                <span>${teacher.nombre_completo} <span class="text-muted">(${teacher.email})</span></span>
                                            `;
                                            teacherSearchResults.appendChild(listItem);
                                        }
                                    });
                                    teacherSearchResults.style.display = 'block';
                                } else {
                                    teacherSearchResults.style.display = 'none';
                                }
                            })
                            .catch(error => {
                                console.error('Error fetching teachers:', error);
                                teacherSearchResults.innerHTML = '';
                                teacherSearchResults.style.display = 'none';
                            });
                    }, 300); // Debounce search
                } else {
                    teacherSearchResults.innerHTML = '';
                    teacherSearchResults.style.display = 'none';
                }
            });

            // Handle selection from search results
            teacherSearchResults.addEventListener('click', function (event) {
                const listItem = event.target.closest('li');
                if (listItem) {
                    const teacherId = parseInt(listItem.dataset.id);
                    const teacherName = listItem.dataset.name;
                    const teacherEmail = listItem.dataset.email;

                    if (!selectedTeachers.has(teacherId)) {
                        selectedTeachers.set(teacherId, {
                            id_profesor: teacherId,
                            nombre_completo: teacherName,
                            email: teacherEmail
                        });
                        updateSelectedRecipientsDisplay();
                    }
                    teacherSearchInput.value = ''; // Clear search input
                    teacherSearchResults.style.display = 'none'; // Hide results
                }
            });

            // Hide search results when clicking outside
            document.addEventListener('click', function (event) {
                if (!teacherSearchInput.contains(event.target) && !teacherSearchResults.contains(event.target)) {
                    teacherSearchResults.style.display = 'none';
                }
            });

            // Optional: Fetch all teachers on page load initially (or trigger search if input is populated)
            // You might want to pre-populate the 'selected teachers' if they are coming from a previous state.
            // If you want to show ALL teachers of the child's courses on load:
            fetch(`<%= request.getContextPath()%>/INTERFAZ_APODERADO/mensajes_apoderado.jsp?requestType=getAllTeachersOfMyChildCourses`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response for initial teacher fetch was not ok');
                    }
                    // Expect plain text and parse it as JSON
                    return response.text().then(text => JSON.parse(text));
                })
                .then(data => {
                    data.forEach(teacher => {
                        if (!selectedTeachers.has(teacher.id_profesor)) {
                            selectedTeachers.set(teacher.id_profesor, {
                                id_profesor: teacher.id_profesor,
                                nombre_completo: teacher.nombre_completo,
                                email: teacher.email
                            });
                        }
                    });
                    updateSelectedRecipientsDisplay(); // Initial display of all relevant teachers
                })
                .catch(error => console.error('Error loading all teachers for child courses:', error));
        });
    </script>
</body>
</html>