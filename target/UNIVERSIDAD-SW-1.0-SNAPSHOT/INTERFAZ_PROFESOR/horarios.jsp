<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
Object idObj = session.getAttribute("id_profesor");
int id = -1;
String nombreProfesor = "";
String emailProfesor = "";
String facultadProfesor = "";
String salonAsignado = "";
int totalClases = 0;
StringBuilder eventos = new StringBuilder("[");

if (idObj != null) {
    id = Integer.parseInt(idObj.toString());
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Conexion c = new Conexion();
                                        conn = c.conecta();
        
        // Obtener información básica del profesor
        String sqlProfesor = "SELECT p.nombre, p.apellido, p.email, f.nombre as facultad, s.nombre as salon " +
                           "FROM profesores p " +
                           "JOIN facultades f ON p.id_facultad = f.id " +
                           "LEFT JOIN salones s ON p.id_salon = s.id " +
                           "WHERE p.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlProfesor);
        pstmt.setInt(1, id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido");
            emailProfesor = rs.getString("email");
            facultadProfesor = rs.getString("facultad");
            salonAsignado = rs.getString("salon") != null ? rs.getString("salon") : "No asignado";
        }
        rs.close();
        pstmt.close();

        // Obtener horarios del profesor
        String sqlHorarios = "SELECT h.id_horario, c.nombre AS curso, c.codigo, " +
                           "h.fecha, h.hora_inicio, h.hora_fin, h.dia_semana, " +
                           "s.nombre as salon, s.capacidad " +
                           "FROM horarios h " +
                           "JOIN cursos c ON h.id_curso = c.id " +
                           "JOIN profesor_curso pc ON c.id = pc.id_curso " +
                           "JOIN profesores p ON pc.id_profesor = p.id " +
                           "LEFT JOIN salones s ON h.id_salon = s.id " +
                           "WHERE p.id_profesor = ? " +
                           "ORDER BY h.fecha, h.hora_inicio";
        
        pstmt = conn.prepareStatement(sqlHorarios);
        pstmt.setInt(1, id);
        rs = pstmt.executeQuery();

        boolean hasEvents = false;
        while (rs.next()) {
            if (hasEvents) eventos.append(",");
            
            String idHorario = rs.getString("id_horario");
            String curso = rs.getString("curso");
            String codigo = rs.getString("codigo");
            String fecha = rs.getString("fecha");
            String horaInicio = rs.getString("hora_inicio");
            String horaFin = rs.getString("hora_fin");
            String salon = rs.getString("salon");
            int capacidad = rs.getInt("capacidad");
            
            eventos.append("{")
                  .append("id:'").append(idHorario).append("',")
                  .append("title:'").append(curso).append(" (").append(codigo).append(")',")
                  .append("start:'").append(fecha).append("T").append(horaInicio).append("',")
                  .append("end:'").append(fecha).append("T").append(horaFin).append("',")
                  .append("backgroundColor:'#002366',")
                  .append("borderColor:'#FFD700',")
                  .append("extendedProps:{")
                  .append("salon:'").append(salon != null ? salon : "No asignado").append("',")
                  .append("capacidad:").append(capacidad).append(",")
                  .append("codigo:'").append(codigo).append("'")
                  .append("}")
                  .append("}");
            
            hasEvents = true;
            totalClases++;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
    
    eventos.append("]");
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema Universitario - Horarios</title>
    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/main.min.css" rel="stylesheet"/>
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
        
        .profesor-info {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-top: 4px solid var(--primary-color);
        }
        
        .stats-card {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            text-align: center;
            border-top: 4px solid var(--accent-color);
        }
        
        .stats-number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
        }
        
        #calendar {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .fc-event {
            border: none !important;
            border-radius: 8px !important;
            font-weight: 500;
            cursor: pointer;
        }
        
        .fc-event-main {
            padding: 4px 8px;
        }
        
        .fc-toolbar-title {
            color: var(--primary-color) !important;
            font-weight: bold;
        }
        
        .fc-button-primary {
            background-color: var(--primary-color) !important;
            border-color: var(--primary-color) !important;
        }
        
        .fc-button-primary:hover {
            background-color: var(--accent-color) !important;
            border-color: var(--accent-color) !important;
        }
        
        .salon-badge {
            background-color: var(--primary-color);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-block;
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
        
        .info-section {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-top: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--secondary-color);
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
            <p class="user-name"><%= nombreProfesor %></p>
            <p><%= emailProfesor %></p>
            <p><%= facultadProfesor %></p>
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
                    <li><a href="carreras_profesor.jsp">Carreras</a</li>
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
                <h1>Mis Horarios de Clase</h1>
                <p>Visualiza y gestiona tu horario de clases asignado para el semestre actual.</p>
            </div>
            
            <div class="profesor-info">
                <h3>Información del Profesor</h3>
                <p><strong>Nombre:</strong> <%= nombreProfesor %></p>
                <p><strong>Email:</strong> <%= emailProfesor %></p>
                <p><strong>Facultad:</strong> <%= facultadProfesor %></p>
                <p><strong>Salón Asignado:</strong> <span class="salon-badge"><%= salonAsignado %></span></p>
            </div>
            
            <div class="stats-card">
                <div class="stats-number"><%= totalClases %></div>
                <div>Clases Programadas</div>
            </div>
            
            <div id="calendar"></div>
            
            <div class="info-section">
                <h3><i class="bi bi-info-circle"></i> Información Importante</h3>
                <ul>
                    <li>Haz clic en cualquier evento para ver más detalles de la clase.</li>
                    <li>Puedes cambiar entre vista semanal, diaria o de lista usando los controles superiores.</li>
                    <li>Los horarios en color azul representan tus clases asignadas.</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- FullCalendar JS -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/main.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/locales/es.global.min.js"></script>
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const calendarEl = document.getElementById('calendar');
            const calendar = new FullCalendar.Calendar(calendarEl, {
                locale: 'es',
                initialView: 'timeGridWeek',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'timeGridWeek,timeGridDay,listWeek'
                },
                slotMinTime: "07:00:00",
                slotMaxTime: "22:00:00",
                height: 'auto',
                expandRows: true,
                events: <%= eventos.toString() %>,

                eventClick: function(info) {
                    const event = info.event;
                    const props = event.extendedProps;
                    
                    const modalContent = `
                        <div class="modal fade" id="eventModal" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header" style="background: var(--primary-color); color: white;">
                                        <h5 class="modal-title">
                                            <i class="bi bi-book me-2"></i>
                                            Detalles de la Clase
                                        </h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-6">
                                                <p><strong>Curso:</strong><br>${event.title}</p>
                                                <p><strong>Código:</strong><br>${props.codigo}</p>
                                            </div>
                                            <div class="col-6">
                                                <p><strong>Salón:</strong><br>${props.salon}</p>
                                                <p><strong>Capacidad:</strong><br>${props.capacidad} estudiantes</p>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-6">
                                                <p><strong>Fecha:</strong><br>${event.start.toLocaleDateString('es-ES')}</p>
                                            </div>
                                            <div class="col-6">
                                                <p><strong>Horario:</strong><br>${event.start.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'})} - ${event.end.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'})}</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    
                    const existingModal = document.getElementById('eventModal');
                    if (existingModal) {
                        existingModal.remove();
                    }
                    
                    document.body.insertAdjacentHTML('beforeend', modalContent);
                    
                    const modal = new bootstrap.Modal(document.getElementById('eventModal'));
                    modal.show();
                },

                eventDidMount: function(info) {
                    info.el.setAttribute('title', 
                        `${info.event.title}\nSalón: ${info.event.extendedProps.salon}\nHorario: ${info.event.start.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'})} - ${info.event.end.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'})}`
                    );
                },

                businessHours: {
                    daysOfWeek: [1, 2, 3, 4, 5, 6],
                    startTime: '07:00',
                    endTime: '22:00'
                },

                slotLabelFormat: {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                },

                eventTimeFormat: {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                }
            });

            calendar.render();
        });
    </script>
</body>
</html>