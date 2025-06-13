<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page session="true" %>

<%
// Datos del usuario (de sesión o parámetros)
    Object idObj = session.getAttribute("id_profesor");
    int userId = -1;
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";
    String userRole = "profesor"; // Por defecto, se puede cambiar según necesidad

    if (idObj != null) {
        userId = Integer.parseInt(idObj.toString());

        // Conexión a la base de datos para obtener información del profesor
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/bd_sw", "root", "");

            String sql = "SELECT nombre, email, facultad FROM profesores WHERE id_profesor = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                nombreProfesor = rs.getString("nombre");
                emailProfesor = rs.getString("email");
                facultadProfesor = rs.getString("facultad");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (con != null) {
                con.close();
            }
        }
    } else {
        // Si no hay sesión de profesor, verificar si es alumno
        idObj = session.getAttribute("id_alumno");
        if (idObj != null) {
            userId = Integer.parseInt(idObj.toString());
            userRole = "alumno";

            // Aquí iría la lógica para obtener datos del alumno si es necesario
        }
    }

// Configuración de base de datos para el chat
    String jdbcURL = "jdbc:mysql://localhost:3306/sistema_universitario";
    String jdbcUsername = "usuario";
    String jdbcPassword = "contraseña";
    Connection connection = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
    } catch (Exception e) {
        out.println("Error de conexión: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema Universitario - Mensajería</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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
                padding: 0;
                display: flex;
                flex-direction: column;
            }

            /* Estilos específicos del chat */
            .chat-area {
                display: flex;
                flex: 1;
            }

            .course-sidebar {
                width: 300px;
                background-color: white;
                border-right: 1px solid #dee2e6;
                overflow-y: auto;
            }

            .chat-container {
                flex: 1;
                display: flex;
                flex-direction: column;
            }

            .chat-header {
                background-color: var(--primary-color);
                color: white;
                padding: 1rem;
            }

            .chat-messages {
                flex: 1;
                overflow-y: auto;
                padding: 1rem;
                background-color: #f8f9fa;
            }

            .message-bubble {
                max-width: 70%;
                margin-bottom: 15px;
                padding: 10px 15px;
                border-radius: 18px;
                position: relative;
            }

            .message-sent {
                background-color: var(--primary-color);
                color: white;
                margin-left: auto;
                text-align: right;
            }

            .message-received {
                background-color: white;
                border: 1px solid #e9ecef;
                margin-right: auto;
            }

            .message-time {
                font-size: 0.75em;
                opacity: 0.7;
                margin-top: 5px;
            }

            .course-list {
                padding: 1rem;
            }

            .course-item {
                cursor: pointer;
                transition: background-color 0.2s;
                padding: 0.75rem;
                border-radius: 4px;
                margin-bottom: 0.5rem;
            }

            .course-item:hover {
                background-color: #f8f9fa;
            }

            .course-item.active {
                background-color: #e3f2fd;
                border-left: 4px solid var(--primary-color);
            }

            .online-indicator {
                width: 8px;
                height: 8px;
                background-color: #28a745;
                border-radius: 50%;
                display: inline-block;
                margin-right: 5px;
            }

            .file-attachment {
                background-color: #e9ecef;
                border-radius: 8px;
                padding: 8px;
                margin-top: 5px;
                display: inline-block;
            }

            .chat-input {
                padding: 1rem;
                background-color: white;
                border-top: 1px solid #dee2e6;
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

                .chat-area {
                    flex-direction: column;
                }

                .course-sidebar {
                    width: 100%;
                    border-right: none;
                    border-bottom: 1px solid #dee2e6;
                }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="logo">Sistema Universitario</div>
            <div class="user-info">
                <p class="user-name"><%= nombreProfesor != null && !nombreProfesor.isEmpty() ? nombreProfesor : "Usuario"%></p>
                <% if (emailProfesor != null && !emailProfesor.isEmpty()) {%>
                <p><%= emailProfesor%></p>
                <% } %>
                <% if (facultadProfesor != null && !facultadProfesor.isEmpty()) {%>
                <p><%= facultadProfesor%></p>
                <% }%>
                <form action="logout.jsp" method="post">
                    <button type="submit" class="logout-btn">Cerrar sesión</button>
                </form>
            </div>
        </div>

        <div class="container">
            <div class="sidebar">
                <ul>
                    <li><a href="home_profesor.jsp">Inicio</a></li>
                    <li><a href="facultad_profesor.jsp">Facultades</a</li>
                    <li><a href="cursos_profesor.jsp">Cursos</a</li>
                    <li><a href="salones.jsp">Salones</a></li>
                    <li><a href="horarios.jsp">Horarios</a></li>
                    <li><a href="asistencia.jsp">Asistencia</a></li>
                    <li><a href="mensaje.jsp">Mensajería</a</li>
                    <li><a href="nota.jsp">Notas</a></li>
                    <li><a href="configuracion.jsp">Configuración</a></li>
                </ul>
            </div>

            <div class="main-content">
                <div class="chat-area">
                    <!-- Sidebar de cursos -->
                    <div class="course-sidebar">
                        <div class="p-3">
                            <h5 class="mb-3">
                                <i class="fas fa-chalkboard-teacher me-2"></i>
                                <%= userRole.equals("profesor") ? "Mis Cursos" : "Mis Materias"%>
                            </h5>

                            <!-- Filtro de búsqueda -->
                            <div class="mb-3">
                                <input type="text" class="form-control" id="searchCourse" placeholder="Buscar curso...">
                            </div>

                            <div class="course-list" id="courseList">
                                <%
                                    if (connection != null) {
                                        String query = "";
                                        if (userRole.equals("profesor")) {
                                            query = "SELECT DISTINCT c.id_curso, c.nombre_curso, c.codigo_curso, "
                                                    + "COUNT(DISTINCT a.id_alumno) as total_alumnos "
                                                    + "FROM cursos c "
                                                    + "LEFT JOIN alumnos a ON c.id_carrera = a.id_carrera "
                                                    + "GROUP BY c.id_curso, c.nombre_curso, c.codigo_curso";
                                        } else {
                                            query = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso "
                                                    + "FROM cursos c "
                                                    + "INNER JOIN alumnos a ON c.id_carrera = a.id_carrera "
                                                    + "WHERE a.id_alumno = " + userId;
                                        }

                                        PreparedStatement stmt = connection.prepareStatement(query);
                                        ResultSet rs = stmt.executeQuery();

                                        while (rs.next()) {
                                %>
                                <div class="course-item" onclick="selectCourse(<%=rs.getInt("id_curso")%>, '<%=rs.getString("nombre_curso")%>')">
                                    <div class="d-flex align-items-center">
                                        <div class="online-indicator"></div>
                                        <div class="flex-grow-1">
                                            <h6 class="mb-1"><%=rs.getString("nombre_curso")%></h6>
                                            <small class="text-muted"><%=rs.getString("codigo_curso")%></small>
                                            <% if (userRole.equals("profesor")) {%>
                                            <br><small class="text-primary"><%=rs.getInt("total_alumnos")%> estudiantes</small>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                <%
                                        }
                                        rs.close();
                                        stmt.close();
                                    }
                                %>
                            </div>
                        </div>
                    </div>

                    <!-- Área de chat -->
                    <div class="chat-container">
                        <!-- Header del chat -->
                        <div class="chat-header">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h5 class="mb-0" id="chatTitle">Selecciona un curso para comenzar</h5>
                                    <small id="chatSubtitle">Sistema de Mensajería Académica</small>
                                </div>
                                <div class="btn-group">
                                    <button class="btn btn-outline-light btn-sm" onclick="refreshMessages()">
                                        <i class="fas fa-sync-alt"></i>
                                    </button>
                                    <button class="btn btn-outline-light btn-sm" data-bs-toggle="modal" data-bs-target="#participantsModal">
                                        <i class="fas fa-users"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Área de mensajes -->
                        <div class="chat-messages" id="chatMessages">
                            <div class="text-center text-muted mt-5">
                                <i class="fas fa-comments fa-3x mb-3"></i>
                                <p>Selecciona un curso para ver los mensajes</p>
                            </div>
                        </div>

                        <!-- Área de envío de mensajes -->
                        <div class="chat-input">
                            <form id="messageForm" enctype="multipart/form-data">
                                <div class="input-group">
                                    <input type="file" class="form-control" id="fileAttachment" name="archivo" style="display: none;" onchange="showFileName()">
                                    <button type="button" class="btn btn-outline-secondary" onclick="document.getElementById('fileAttachment').click()">
                                        <i class="fas fa-paperclip"></i>
                                    </button>
                                    <input type="text" class="form-control" id="messageInput" name="mensaje" placeholder="Escribe tu mensaje..." required>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane"></i>
                                    </button>
                                </div>
                                <div id="fileInfo" class="mt-2" style="display: none;">
                                    <small class="text-muted">
                                        <i class="fas fa-file me-1"></i>
                                        <span id="fileName"></span>
                                        <button type="button" class="btn btn-sm btn-outline-danger ms-2" onclick="removeFile()">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </small>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de Participantes -->
        <div class="modal fade" id="participantsModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Participantes del Curso</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="participantsList">
                        <!-- Lista de participantes se carga dinámicamente -->
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
        <script>
                                            let currentCourseId = null;
                                            let userRole = '<%=userRole%>';
                                            let userId = <%=userId%>;

                                            function selectCourse(courseId, courseName) {
                                                currentCourseId = courseId;

                                                // Actualizar título
                                                document.getElementById('chatTitle').textContent = courseName;
                                                document.getElementById('chatSubtitle').textContent = 'Mensajes del curso';

                                                // Marcar curso como activo
                                                document.querySelectorAll('.course-item').forEach(item => {
                                                    item.classList.remove('active');
                                                });
                                                event.currentTarget.classList.add('active');

                                                // Cargar mensajes
                                                loadMessages(courseId);
                                            }

                                            function loadMessages(courseId) {
                                                fetch('loadMessages.jsp?courseId=' + courseId + '&userId=' + userId + '&role=' + userRole)
                                                        .then(response => response.text())
                                                        .then(html => {
                                                            document.getElementById('chatMessages').innerHTML = html;
                                                            scrollToBottom();
                                                        })
                                                        .catch(error => {
                                                            console.error('Error al cargar mensajes:', error);
                                                        });
                                            }

                                            function sendMessage() {
                                                if (!currentCourseId) {
                                                    alert('Selecciona un curso primero');
                                                    return false;
                                                }

                                                const form = document.getElementById('messageForm');
                                                const formData = new FormData(form);
                                                formData.append('courseId', currentCourseId);
                                                formData.append('userId', userId);
                                                formData.append('role', userRole);

                                                fetch('sendMessage.jsp', {
                                                    method: 'POST',
                                                    body: formData
                                                })
                                                        .then(response => response.json())
                                                        .then(data => {
                                                            if (data.success) {
                                                                document.getElementById('messageInput').value = '';
                                                                removeFile();
                                                                loadMessages(currentCourseId);
                                                            } else {
                                                                alert('Error al enviar mensaje: ' + data.message);
                                                            }
                                                        })
                                                        .catch(error => {
                                                            console.error('Error:', error);
                                                            alert('Error al enviar mensaje');
                                                        });

                                                return false;
                                            }

                                            function showFileName() {
                                                const fileInput = document.getElementById('fileAttachment');
                                                const fileInfo = document.getElementById('fileInfo');
                                                const fileName = document.getElementById('fileName');

                                                if (fileInput.files.length > 0) {
                                                    fileName.textContent = fileInput.files[0].name;
                                                    fileInfo.style.display = 'block';
                                                }
                                            }

                                            function removeFile() {
                                                document.getElementById('fileAttachment').value = '';
                                                document.getElementById('fileInfo').style.display = 'none';
                                            }

                                            function scrollToBottom() {
                                                const chatContainer = document.getElementById('chatMessages');
                                                chatContainer.scrollTop = chatContainer.scrollHeight;
                                            }

                                            function refreshMessages() {
                                                if (currentCourseId) {
                                                    loadMessages(currentCourseId);
                                                }
                                            }

                                            // Event listeners
                                            document.getElementById('messageForm').addEventListener('submit', function (e) {
                                                e.preventDefault();
                                                sendMessage();
                                            });

                                            document.getElementById('messageInput').addEventListener('keypress', function (e) {
                                                if (e.key === 'Enter' && !e.shiftKey) {
                                                    e.preventDefault();
                                                    sendMessage();
                                                }
                                            });

                                            // Búsqueda de cursos
                                            document.getElementById('searchCourse').addEventListener('input', function () {
                                                const searchTerm = this.value.toLowerCase();
                                                const courseItems = document.querySelectorAll('.course-item');

                                                courseItems.forEach(item => {
                                                    const courseName = item.querySelector('h6').textContent.toLowerCase();
                                                    const courseCode = item.querySelector('small').textContent.toLowerCase();

                                                    if (courseName.includes(searchTerm) || courseCode.includes(searchTerm)) {
                                                        item.style.display = 'block';
                                                    } else {
                                                        item.style.display = 'none';
                                                    }
                                                });
                                            });

                                            // Actualizar mensajes cada 5 segundos
                                            setInterval(function () {
                                                if (currentCourseId) {
                                                    refreshMessages();
                                                }
                                            }, 5000);
        </script>

        <%
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
    </body>
</html>