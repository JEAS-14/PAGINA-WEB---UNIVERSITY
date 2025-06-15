<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page session="true" %>

<%
    // --- VALIDACIÓN DE SESIÓN ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idProfesorObj = session.getAttribute("id_profesor");

    if (emailSesion == null || !"profesor".equalsIgnoreCase(rolUsuario) || idProfesorObj == null) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
        return;
    }

    int idProfesor = -1;
    if (idProfesorObj instanceof Integer) {
        idProfesor = (Integer) idProfesorObj;
    } else {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
        return;
    }

    String nombreProfesor = (String) session.getAttribute("nombre_profesor");
    if (nombreProfesor == null || nombreProfesor.isEmpty()) {
        Conexion conTemp = null;
        Connection connTemp = null;
        PreparedStatement pstmtTemp = null;
        ResultSet rsTemp = null;
        try {
            conTemp = new Conexion();
            connTemp = conTemp.conecta();
            String sqlGetNombre = "SELECT CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', IFNULL(p.apellido_materno, '')) AS nombre_completo FROM profesores WHERE id_profesor = ?";
            pstmtTemp = connTemp.prepareStatement(sqlGetNombre);
            pstmtTemp.setInt(1, idProfesor);
            rsTemp = pstmtTemp.executeQuery();
            if (rsTemp.next()) {
                nombreProfesor = rsTemp.getString("nombre_completo");
                session.setAttribute("nombre_profesor", nombreProfesor);
            }
        } catch (SQLException | ClassNotFoundException ex) {
            System.err.println("Error al obtener nombre del profesor en enviar_mensaje_seccion.jsp: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            // Cierre correcto de recursos en este bloque
            if (rsTemp != null) { try { rsTemp.close(); } catch (SQLException ignore) {} }
            if (pstmtTemp != null) { try { pstmtTemp.close(); } catch (SQLException ignore) {} }
            if (connTemp != null) { try { connTemp.close(); } catch (SQLException ignore) {} }
        }
    }

    // --- Detectar si es una solicitud AJAX para buscar alumnos ---
    String searchTerm = request.getParameter("term");
    String requestType = request.getParameter("requestType"); // Para diferenciar entre búsqueda normal y "seleccionar todos"

    // Este bloque se ejecuta SOLAMENTE si es una llamada AJAX de búsqueda/selección.
    if (searchTerm != null || "getAllStudentsByProfessor".equals(requestType)) {
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder jsonResponse = new StringBuilder();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Conexion conUtil = new Conexion();
            conn = conUtil.conecta();

            if (conn == null || conn.isClosed()) {
                throw new SQLException("No se pudo establecer conexión a la base de datos.");
            }

            if ("getAllStudentsByProfessor".equals(requestType)) {
                // Lógica para "Seleccionar Alumnos de MIS Clases"
                String sql = "SELECT DISTINCT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, a.email "
                             + "FROM alumnos a "
                             + "INNER JOIN inscripciones i ON a.id_alumno = i.id_alumno "
                             + "INNER JOIN clases cl ON i.id_clase = cl.id_clase "
                             + "WHERE cl.id_profesor = ? AND cl.estado = 'activo' AND i.estado = 'inscrito' "
                             + "ORDER BY a.apellido_paterno, a.nombre";

                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idProfesor);
                rs = pstmt.executeQuery();

            } else { // Es una búsqueda normal por 'term'
                if (searchTerm == null || searchTerm.trim().isEmpty() || searchTerm.trim().length() < 3) {
                    jsonResponse.append("[]");
                    out.print(jsonResponse.toString());
                    return; // Termina la ejecución aquí para la búsqueda vacía/corta
                }

                // Búsqueda por nombre completo, DNI o EMAIL
                String sql = "SELECT id_alumno, dni, nombre, apellido_paterno, apellido_materno, email "
                             + "FROM alumnos "
                             + "WHERE estado = 'activo' AND ( "
                             + "    LOWER(CONCAT(nombre, ' ', apellido_paterno, ' ', IFNULL(apellido_materno, ''))) LIKE LOWER(?) OR "
                             + "    dni LIKE ? OR "
                             + "    LOWER(email) LIKE LOWER(?) "
                             + ") LIMIT 10";

                pstmt = conn.prepareStatement(sql);
                String searchPattern = "%" + searchTerm.trim() + "%";
                pstmt.setString(1, searchPattern);
                pstmt.setString(2, searchPattern);
                pstmt.setString(3, searchPattern);
                rs = pstmt.executeQuery();
            }

            jsonResponse.append("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) {
                    jsonResponse.append(",");
                }
                jsonResponse.append("{");

                int idAlumno = rs.getInt("id_alumno");
                String dni = rs.getString("dni"); // Puede ser nulo
                String nombre = rs.getString("nombre");
                String apellidoPaterno = rs.getString("apellido_paterno");
                String apellidoMaterno = rs.getString("apellido_materno"); // Puede ser nulo
                String email = rs.getString("email"); // Puede ser nulo

                String nombreCompleto = nombre + " " + apellidoPaterno;
                if (apellidoMaterno != null && !apellidoMaterno.trim().isEmpty()) {
                    nombreCompleto += " " + apellidoMaterno;
                }

                // Escapar cadenas para JSON
                String escapedNombreCompleto = nombreCompleto.replace("\\", "\\\\").replace("\"", "\\\"");
                String escapedDni = (dni != null) ? dni.replace("\\", "\\\\").replace("\"", "\\\"") : "";
                String escapedEmail = (email != null) ? email.replace("\\", "\\\\").replace("\"", "\\\"") : "";

                jsonResponse.append("\"id_alumno\":").append(idAlumno).append(",");
                jsonResponse.append("\"dni\":\"").append(escapedDni).append("\",");
                jsonResponse.append("\"nombre_completo\":\"").append(escapedNombreCompleto).append("\",");
                jsonResponse.append("\"email\":\"").append(escapedEmail).append("\"");

                jsonResponse.append("}");
                first = false;
            }
            jsonResponse.append("]");

        } catch (SQLException e) {
            System.err.println("Error SQL al obtener alumnos en enviar_mensaje_seccion.jsp (AJAX): " + e.getMessage());
            e.printStackTrace();
            jsonResponse.setLength(0);
            jsonResponse.append("[]"); // Devolver JSON vacío en caso de error
        } catch (ClassNotFoundException e) {
            System.err.println("Error ClassNotFound al obtener alumnos en enviar_mensaje_seccion.jsp (AJAX): " + e.getMessage());
            e.printStackTrace();
            jsonResponse.setLength(0);
            jsonResponse.append("[]");
        } finally {
            // Cierre correcto de recursos para la sección AJAX
            if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
        }
        out.print(jsonResponse.toString());
        out.flush();
        return; // ¡Importante! Terminar la ejecución aquí para solicitudes AJAX
    }

    // --- Si no es una solicitud AJAX, continuar con la renderización del HTML del formulario (POST o GET inicial) ---
    String mensajeExito = request.getParameter("exito");
    String mensajeError = request.getParameter("error");

    // --- Lógica para enviar el mensaje (cuando el formulario es enviado con POST) ---
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String asunto = request.getParameter("asunto");
        String contenido = request.getParameter("contenido");
        String destinatariosIds = request.getParameter("destinatarios_ids");

        String[] idsArray = destinatariosIds.split(",");
        List<Integer> alumnosAEnviar = new ArrayList<>();

        for (String idStr : idsArray) {
            try {
                if (!idStr.trim().isEmpty()) {
                    alumnosAEnviar.add(Integer.parseInt(idStr.trim()));
                }
            } catch (NumberFormatException nfe) {
                System.err.println("Advertencia: ID de alumno inválido encontrado y omitido: " + idStr);
            }
        }

        String redirectURL = "enviar_mensaje_seccion.jsp?";

        if (alumnosAEnviar.isEmpty()) {
            response.sendRedirect(redirectURL + "error=" + URLEncoder.encode("Debes seleccionar al menos un destinatario válido.", "UTF-8"));
            return;
        }

        Connection conn = null;
        PreparedStatement pstmtMensaje = null;

        try {
            Conexion conUtil = new Conexion();
            conn = conUtil.conecta();

            if (conn == null || conn.isClosed()) {
                throw new SQLException("No se pudo establecer conexión a la base de datos.");
            }

            conn.setAutoCommit(false);

            String sqlInsertMensaje = "INSERT INTO mensajes (id_remitente, tipo_remitente, id_destinatario, tipo_destinatario, asunto, contenido, fecha_envio) VALUES (?, 'profesor', ?, 'alumno', ?, ?, NOW())";
            pstmtMensaje = conn.prepareStatement(sqlInsertMensaje);

            for (Integer idAlumno : alumnosAEnviar) {
                pstmtMensaje.setInt(1, idProfesor);
                pstmtMensaje.setInt(2, idAlumno);
                pstmtMensaje.setString(3, asunto);
                pstmtMensaje.setString(4, contenido);
                pstmtMensaje.addBatch();
            }

            int[] results = pstmtMensaje.executeBatch();
            conn.commit();

            int mensajesEnviadosCount = 0;
            for (int res : results) {
                if (res > 0) {
                    mensajesEnviadosCount++;
                }
            }

            if (mensajesEnviadosCount == alumnosAEnviar.size()) {
                response.sendRedirect(redirectURL + "exito=" + URLEncoder.encode("Mensajes enviados correctamente a " + String.valueOf(mensajesEnviadosCount) + " destinatario(s).", "UTF-8"));
            } else if (mensajesEnviadosCount > 0) {
                response.sendRedirect(redirectURL + "error=" + URLEncoder.encode("Se enviaron algunos mensajes, pero no a todos los destinatarios (" + String.valueOf(mensajesEnviadosCount) + "/" + String.valueOf(alumnosAEnviar.size()) + ").", "UTF-8"));
            } else {
                response.sendRedirect(redirectURL + "error=" + URLEncoder.encode("No se pudo enviar mensajes a ningún destinatario.", "UTF-8"));
            }
            return;

        } catch (SQLException e) {
            // CORREGIDO: Sintaxis correcta para el bloque try-catch anidado para el rollback.
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace(); // Aquí el error de símbolo no encontrado para 'rbEx'
                }
            }
            System.err.println("Error de base de datos al enviar mensaje (POST): " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(redirectURL + "error=" + URLEncoder.encode("Error de base de datos al enviar mensaje: " + e.getMessage(), "UTF-8"));
            return;
        } catch (ClassNotFoundException e) {
            System.err.println("Error: No se encontró el driver JDBC de MySQL (POST): " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(redirectURL + "error=" + URLEncoder.encode("Error: No se encontró el driver JDBC de MySQL.", "UTF-8"));
            return;
        } finally {
            // Cierre correcto de recursos para la sección POST
            if (pstmtMensaje != null) { try { pstmtMensaje.close(); } catch (SQLException ignore) {} }
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignore) {} }
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enviar Mensajes - Sistema Universitario</title>
    <link rel="icon" type="image/x-icon" href="https://ejemplo.com/favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* (El CSS es el mismo que la última versión que te di para este JSP) */
        :root {
            --primary-color: #002366;
            --secondary-color: #FFD700;
            --accent-color: #800000;
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

        .section-header {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--primary-color);
        }

        .section-header h1 {
            color: var(--primary-color);
            margin-top: 0;
        }

        .message-form-container {
            background-color: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-top: 4px solid var(--accent-color);
        }

        .message-form-container h2 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--dark-color);
        }

        .form-group input[type="text"],
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
            box-sizing: border-box;
        }

        .form-group textarea {
            min-height: 150px;
            resize: vertical;
        }

        .form-actions {
            text-align: right;
            margin-top: 2rem;
        }

        .form-actions button {
            background-color: var(--primary-color);
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s ease;
        }

        .form-actions button:hover {
            background-color: #003399;
        }

        .alert {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 4px;
            font-weight: bold;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .back-button {
            display: inline-block;
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            font-size: 1rem;
            margin-top: 20px;
            transition: background-color 0.3s ease;
        }

        .back-button:hover {
            background-color: #5a6268;
        }

        /* Estilos para el buscador de alumnos y lista de seleccionados */
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
            background-color: white;
            position: absolute;
            width: 100%;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .search-results-list li {
            padding: 0.8rem;
            border-bottom: 1px solid #eee;
            cursor: pointer;
        }
        .search-results-list li:hover {
            background-color: #f0f8ff;
        }
        .search-results-list li:last-child {
            border-bottom: none;
        }

        .selected-recipients {
            list-style-type: none;
            padding: 0;
            margin-top: 10px;
            border: 1px solid #b0e0e6;
            background-color: #e0f7fa;
            border-radius: 5px;
            padding: 10px;
            max-height: 150px;
            overflow-y: auto;
        }
        .selected-recipients li {
            background-color: #cce9ed;
            padding: 8px 12px;
            margin-bottom: 5px;
            border-radius: 3px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9em;
            color: var(--primary-color);
        }
        .selected-recipients li .remove-recipient {
            background: none;
            border: none;
            color: var(--accent-color);
            cursor: pointer;
            font-size: 1.2em;
            margin-left: 10px;
            transition: color 0.2s;
        }
        .selected-recipients li .remove-recipient:hover {
            color: #cc0000;
        }
        .recipient-count {
            font-size: 0.9em;
            color: #666;
            text-align: right;
            margin-top: 5px;
        }
        .select-all-buttons {
            margin-top: 15px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .select-all-buttons button {
            background-color: #17a2b8; /* Info blue */
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: background-color 0.3s;
        }
        .select-all-buttons button:hover {
            background-color: #138496;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreProfesor != null ? nombreProfesor : ""%></p>
            <p><%= emailSesion%></p>
            <%-- Asumiendo que facultadProfesor está disponible --%>
            <%-- <p><%= facultadProfesor%></p> --%>
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
            <div class="section-header">
                <h1>Enviar Mensajes</h1>
                <p>Envía comunicaciones importantes a uno o varios estudiantes.</p>
            </div>

            <% if (mensajeExito != null) { %>
                <div class="alert alert-success">
                    <%= mensajeExito %>
                </div>
            <% } %>
            <% if (mensajeError != null) { %>
                <div class="alert alert-danger">
                    <%= mensajeError %>
                </div>
            <% } %>

            <div class="message-form-container">
                <h2>Componer Nuevo Mensaje</h2>

                <form id="mensajeForm" action="enviar_mensaje_seccion.jsp" method="post">
                    <div class="form-group">
                        <label for="alumnoSearchInput">Buscar Alumnos (Nombre, DNI o Correo):</label>
                        <div class="search-input-container">
                            <input type="text" id="alumnoSearchInput" placeholder="Escribe el nombre, DNI o correo del alumno...">
                            <ul id="alumnoSearchResults" class="search-results-list" style="display:none;">
                                </ul>
                        </div>
                    </div>

                    <div class="select-all-buttons">
                        <button type="button" id="selectAllStudentsInMyClassesBtn">
                            <i class="fas fa-users"></i> Seleccionar Alumnos de MIS Clases
                        </button>
                        <button type="button" id="clearRecipientsBtn">
                            <i class="fas fa-times-circle"></i> Limpiar Destinatarios
                        </button>
                    </div>

                    <div class="form-group">
                        <label>Destinatarios Seleccionados:</label>
                        <ul id="selectedRecipientsList" class="selected-recipients">
                            </ul>
                        <div class="recipient-count" id="recipientCount">0 destinatario(s)</div>
                        <input type="hidden" name="destinatarios_ids" id="destinatariosIds" value="">
                    </div>

                    <div class="form-group">
                        <label for="asunto">Asunto:</label>
                        <input type="text" id="asunto" name="asunto" required maxlength="200" placeholder="Ej: Recordatorio, Información Importante">
                    </div>

                    <div class="form-group">
                        <label for="contenido">Contenido del Mensaje:</label>
                        <textarea id="contenido" name="contenido" rows="10" required placeholder="Escribe aquí tu mensaje..."></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" id="enviarBtn"><i class="fas fa-paper-plane"></i> Enviar Mensaje</button>
                    </div>
                </form>
            </div>

            <a href="mensaje_profesor.jsp" class="back-button">
                <i class="fas fa-arrow-left"></i> Volver al Panel Principal de Mensajería
            </a>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const alumnoSearchInput = document.getElementById('alumnoSearchInput');
            const alumnoSearchResults = document.getElementById('alumnoSearchResults');
            const selectedRecipientsList = document.getElementById('selectedRecipientsList');
            const destinatariosIdsHidden = document.getElementById('destinatariosIds');
            const recipientCountSpan = document.getElementById('recipientCount');
            const selectAllStudentsInMyClassesBtn = document.getElementById('selectAllStudentsInMyClassesBtn');
            const clearRecipientsBtn = document.getElementById('clearRecipientsBtn');
            const mensajeForm = document.getElementById('mensajeForm');

            let selectedAlumnos = new Map(); // Mapa para almacenar {id_alumno: {nombre, dni, email}}

            function updateRecipientCount() {
                recipientCountSpan.textContent = `${selectedAlumnos.size} destinatario(s)`;
                destinatariosIdsHidden.value = Array.from(selectedAlumnos.keys()).join(',');
            }

            function addRecipient(alumno) {
                if (!selectedAlumnos.has(alumno.id_alumno)) {
                    selectedAlumnos.set(alumno.id_alumno, alumno);

                    const listItem = document.createElement('li');
                    listItem.dataset.id = alumno.id_alumno;
                    // Mostrar Nombre Completo, DNI y Email, usando 'N/A' si el valor es nulo o cadena vacía
                    // CORRECCIÓN aplicada aquí: manejo más robusto de propiedades nulas/undefined/vacías
                    const displayDni = (alumno.dni && String(alumno.dni).trim() !== '') ? alumno.dni : 'N/A';
                    const displayEmail = (alumno.email && String(alumno.email).trim() !== '') ? alumno.email : 'N/A';
                    const displayNombreCompleto = (alumno.nombre_completo && String(alumno.nombre_completo).trim() !== '') ? alumno.nombre_completo : 'N/A';

                    listItem.innerHTML = `
                        <span><i class="fas fa-user-graduate"></i> ${displayNombreCompleto} (DNI: ${displayDni}, Email: ${displayEmail})</span>
                        <button type="button" class="remove-recipient" data-id="${alumno.id_alumno}">&times;</button>
                    `;
                    selectedRecipientsList.appendChild(listItem);

                    listItem.querySelector('.remove-recipient').addEventListener('click', function() {
                        removeRecipient(parseInt(this.dataset.id));
                    });

                    updateRecipientCount();
                }
                alumnoSearchInput.value = ''; // Limpiar el input de búsqueda
                alumnoSearchResults.style.display = 'none'; // Ocultar resultados
            }

            function removeRecipient(idAlumno) {
                selectedAlumnos.delete(idAlumno);
                const listItem = selectedRecipientsList.querySelector(`li[data-id="${idAlumno}"]`);
                if (listItem) {
                    listItem.remove();
                }
                updateRecipientCount();
            }

            // Lógica de búsqueda de alumnos (AJAX al mismo JSP)
            let currentSearchTimeout = null;
            alumnoSearchInput.addEventListener('keyup', function() {
                clearTimeout(currentSearchTimeout);
                const searchTerm = this.value.trim();

                if (searchTerm.length < 3) {
                    alumnoSearchResults.innerHTML = '';
                    alumnoSearchResults.style.display = 'none';
                    return;
                }

                currentSearchTimeout = setTimeout(function() {
                    // La solicitud AJAX ahora se envía al mismo JSP, con un parámetro 'term'
                    fetch('enviar_mensaje_seccion.jsp?term=' + encodeURIComponent(searchTerm))
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Error de red o servidor: ' + response.status + ' ' + response.statusText);
                            }
                            return response.json();
                        })
                        .then(data => {
                            alumnoSearchResults.innerHTML = '';
                            if (data.length > 0) {
                                data.forEach(alumno => {
                                    const listItem = document.createElement('li');
                                    // CORRECCIÓN aplicada aquí: manejo más robusto de propiedades nulas/undefined/vacías
                                    const displayDni = (alumno.dni && String(alumno.dni).trim() !== '') ? alumno.dni : 'N/A';
                                    const displayEmail = (alumno.email && String(alumno.email).trim() !== '') ? alumno.email : 'N/A';
                                    const displayNombreCompleto = (alumno.nombre_completo && String(alumno.nombre_completo).trim() !== '') ? alumno.nombre_completo : 'N/A';

                                    listItem.innerHTML = `<i class="fas fa-user-graduate"></i> ${displayNombreCompleto} (DNI: ${displayDni}, Email: ${displayEmail})`;
                                    listItem.dataset.id = alumno.id_alumno;
                                    listItem.dataset.nombre = alumno.nombre_completo;
                                    listItem.dataset.dni = alumno.dni;
                                    listItem.dataset.email = alumno.email;
                                    listItem.addEventListener('click', function() {
                                        addRecipient({
                                            id_alumno: parseInt(this.dataset.id),
                                            nombre_completo: this.dataset.nombre,
                                            dni: this.dataset.dni,
                                            email: this.dataset.email
                                        });
                                    });
                                    alumnoSearchResults.appendChild(listItem);
                                });
                                alumnoSearchResults.style.display = 'block';
                            } else {
                                const listItem = document.createElement('li');
                                listItem.textContent = 'No se encontraron alumnos.';
                                listItem.style.fontStyle = 'italic';
                                listItem.style.color = '#888';
                                alumnoSearchResults.appendChild(listItem);
                                alumnoSearchResults.style.display = 'block';
                            }
                        })
                        .catch(error => {
                            console.error('Error al obtener datos de alumnos para el buscador:', error);
                            alumnoSearchResults.innerHTML = '<li>Error al cargar resultados. Por favor, intente de nuevo.</li>';
                            alumnoSearchResults.style.display = 'block';
                        });
                }, 300); // Retraso para evitar múltiples solicitudes
            });

            // Ocultar resultados de búsqueda al hacer clic fuera
            document.addEventListener('click', function(event) {
                if (!alumnoSearchInput.contains(event.target) && !alumnoSearchResults.contains(event.target)) {
                    alumnoSearchResults.style.display = 'none';
                }
            });

            // Botón para seleccionar todos los alumnos de las clases del profesor
            selectAllStudentsInMyClassesBtn.addEventListener('click', function() {
                if (confirm('¿Estás seguro de que quieres seleccionar a TODOS los alumnos de tus clases activas? Esto sobrescribirá la lista actual de destinatarios.')) {
                    selectedAlumnos.clear();
                    selectedRecipientsList.innerHTML = ''; // Limpiar lista visible

                    // La solicitud AJAX ahora se envía al mismo JSP, con un parámetro 'requestType'
                    fetch('enviar_mensaje_seccion.jsp?requestType=getAllStudentsByProfessor')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Network response was not ok ' + response.statusText);
                            }
                            return response.json();
                        })
                        .then(data => {
                            if (data.length > 0) {
                                data.forEach(alumno => {
                                    addRecipient(alumno); // Reutilizar la función para añadir
                                });
                                alert(`Se han añadido ${data.length} alumnos de tus clases.`);
                            } else {
                                alert('No se encontraron alumnos en tus clases activas.');
                            }
                        })
                        .catch(error => {
                            console.error('Error al seleccionar todos los alumnos del profesor:', error);
                            alert('Hubo un error al intentar seleccionar todos los alumnos. Verifique la consola para más detalles.');
                        });
                }
            });

            // Botón para limpiar todos los destinatarios
            clearRecipientsBtn.addEventListener('click', function() {
                if (confirm('¿Estás seguro de que quieres limpiar todos los destinatarios seleccionados?')) {
                    selectedAlumnos.clear();
                    selectedRecipientsList.innerHTML = '';
                    updateRecipientCount();
                }
            });

            // Validación de formulario al enviar
            mensajeForm.addEventListener('submit', function(event) {
                if (selectedAlumnos.size === 0) {
                    alert("Debes seleccionar al menos un destinatario para enviar el mensaje.");
                    event.preventDefault(); // Evitar el envío del formulario
                }
                // Si hay destinatarios, el hidden input 'destinatarios_ids' ya estará actualizado por updateRecipientCount()
            });

            // Inicializar el contador al cargar la página
            updateRecipientCount();
        });
    </script>
</body>
</html>