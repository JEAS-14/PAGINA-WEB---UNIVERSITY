<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDate, java.time.format.TextStyle, java.util.Locale" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%! // BLOQUE DE DECLARACIÓN JSP PARA MÉTODOS Y VARIABLES A NIVEL DE CLASE
    int convertirDiaSemanaANumero(String dia) {
        switch (dia.toLowerCase()) {
            case "domingo": return 0;
            case "lunes": return 1;
            case "martes": return 2;
            case "miercoles": return 3;
            case "jueves": return 4;
            case "viernes": return 5;
            case "sabado": return 6;
            default: return -1; // Valor por defecto o para manejar error
        }
    }
%>

<% // Scriptlet principal que ejecuta la lógica de la página
String nombreProfesor = "";
String emailProfesor = "";
String facultadProfesor = "";

// Salones de hoy: Se inicializa como una lista vacía
String diaHoy = LocalDate.now().getDayOfWeek().getDisplayName(TextStyle.FULL, new Locale("es")).toLowerCase();
List<String> salonesHoy = new ArrayList<>();

int totalClases = 0;
StringBuilder eventos = new StringBuilder("[");

// --- LÍNEAS DE DEPURACIÓN (Puedes quitarlas una vez que funcione) ---
System.out.println("DEBUG: Iniciando horarios_profesor.jsp");
Object idObj = session.getAttribute("id_profesor");
System.out.println("DEBUG: Valor de idObj de la sesión al inicio: " + idObj);
// --- FIN LÍNEAS DE DEPURACIÓN ---

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
PreparedStatement pstmtHorarios = null;
ResultSet rsHorarios = null;

try {
    if (idObj != null) { 
        int id = Integer.parseInt(idObj.toString());
        System.out.println("DEBUG: ID del profesor (convertido) de la sesión: " + id);
        
        Conexion c = new Conexion();
        conn = c.conecta();
        
        // Obtener información básica del profesor
        String sqlProfesor = "SELECT p.nombre, p.apellido_paterno, p.apellido_materno, p.email, f.nombre_facultad as facultad " +
                           "FROM profesores p " +
                           "JOIN facultades f ON p.id_facultad = f.id_facultad " +
                           "WHERE p.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlProfesor);
        pstmt.setInt(1, id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String nombre = rs.getString("nombre");
            String apellidoPaterno = rs.getString("apellido_paterno");
            String apellidoMaterno = rs.getString("apellido_materno");
            
            nombreProfesor = nombre + " " + apellidoPaterno + (apellidoMaterno != null ? " " + apellidoMaterno : "");
            emailProfesor = rs.getString("email");
            facultadProfesor = rs.getString("facultad");
            System.out.println("DEBUG: Información del profesor obtenida: " + nombreProfesor + ", " + emailProfesor + ", " + facultadProfesor);
        } else {
            System.out.println("DEBUG: No se encontró información para el profesor con ID: " + id);
        }
        
        // Obtener horarios de las clases asignadas al profesor
        String sqlHorarios = "SELECT cl.id_clase, cu.nombre_curso AS curso, cu.codigo_curso AS codigo, " +
                           "h.dia_semana, h.hora_inicio, h.hora_fin, h.aula AS salon_aula, " +
                           "cl.seccion, cl.capacidad_maxima AS capacidad " +
                           "FROM clases cl " +
                           "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                           "JOIN profesores p ON cl.id_profesor = p.id_profesor " +
                           "JOIN horarios h ON cl.id_horario = h.id_horario " +
                           "WHERE p.id_profesor = ? AND cl.estado = 'activo' " +
                           "ORDER BY h.dia_semana, h.hora_inicio";

        pstmtHorarios = conn.prepareStatement(sqlHorarios);
        pstmtHorarios.setInt(1, id);
        rsHorarios = pstmtHorarios.executeQuery();

        boolean hasEvents = false;
        while (rsHorarios.next()) {
            if (hasEvents) eventos.append(",");

            // Lógica: Llenar salonesHoy solo con los salones del día actual
            String diaBD = rsHorarios.getString("dia_semana").toLowerCase();
            if (diaBD.equals(diaHoy)) {
                String salon = rsHorarios.getString("salon_aula");
                if (salon != null && !salon.trim().isEmpty() && !salonesHoy.contains(salon)) {
                    salonesHoy.add(salon);
                }
            }

            String idClase = String.valueOf(rsHorarios.getInt("id_clase"));
            String curso = rsHorarios.getString("curso");
            String codigo = rsHorarios.getString("codigo");
            String diaSemana = rsHorarios.getString("dia_semana");
            String horaInicio = rsHorarios.getString("hora_inicio");
            String horaFin = rsHorarios.getString("hora_fin");
            String salon = rsHorarios.getString("salon_aula");
            int capacidad = rsHorarios.getInt("capacidad");
            String seccion = rsHorarios.getString("seccion");

            eventos.append("{")
                   .append("id:'").append(idClase).append("',")
                   .append("title:'").append(curso).append(" (").append(codigo).append(" - ").append(seccion).append(")',")
                   .append("daysOfWeek:[").append(convertirDiaSemanaANumero(diaSemana)).append("],")
                   .append("startTime:'").append(horaInicio).append("',")
                   .append("endTime:'").append(horaFin).append("',")
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
        System.out.println("DEBUG: Total de clases encontradas para FullCalendar: " + totalClases);
        
        eventos.append("]");
        
    } else { 
        System.out.println("DEBUG: idObj es NULL. No hay sesión de profesor activa o no se estableció el ID.");
        response.sendRedirect("Plataforma.jsp"); 
        return; 
    }
} catch (Exception e) { 
    System.out.println("ERROR: Excepción en el bloque try-catch principal de horarios_profesor.jsp");
    e.printStackTrace();
    out.println("<div style='color:red; text-align:center; padding:20px; background-color:#ffebeb; border:1px solid red; border-radius:5px;'>");
    out.println("<h2>Error al cargar el horario</h2>");
    out.println("<p>Ocurrió un problema al obtener los datos. Por favor, intente de nuevo más tarde o contacte al soporte técnico.</p>");
    out.println("</div>");
} finally { 
    if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
    if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
    if (rsHorarios != null) { try { rsHorarios.close(); } catch (SQLException ignore) {} }
    if (pstmtHorarios != null) { try { pstmtHorarios.close(); } catch (SQLException ignore) {} }
    if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema Universitario - Horarios</title>
    
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet"/>
    
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
        
        .container-fluid { 
            display: flex;
            min-height: calc(100vh - 60px); 
            padding: 0; /* <<< CAMBIO CLAVE: Elimina el padding horizontal del container-fluid */
        }
        
        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 0;
            flex-shrink: 0; 
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
            flex-grow: 1; 
            padding: 2rem; /* Mantiene el padding interno para el contenido */
            overflow-y: auto; 
        }
        
        .welcome-section, .profesor-info, .stats-card {
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .welcome-section {
            border-left: 4px solid var(--secondary-color); 
        }
        
        .profesor-info {
            border-top: 4px solid var(--primary-color); 
        }
        
        .stats-card {
            border-top: 4px solid var(--accent-color); 
            text-align: center;
        }

        .welcome-section h1 {
            color: var(--primary-color);
            margin-top: 0;
        }
        
        .stats-number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
        }
        
        #calendar {
            background-color: white;
            border-radius: 8px;
            padding: 0; /* Elimina el padding para que la barra se alinee */
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 2rem; 
            overflow: hidden; 
        }
        
        /* Ajustes específicos para los elementos internos de FullCalendar para alinear la barra azul */
        .fc .fc-timegrid-body,
        .fc .fc-timegrid-slots {
            padding: 0; /* Eliminar padding interno si lo tienen */
            /* margin-left: -1px; */ /* Descomentar y ajustar si el borde sigue sin alinearse perfectamente */
        }

        .fc .fc-scrollgrid {
            border-top: none; 
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
            .container-fluid {
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
    
    <div class="container-fluid">
        <div class="sidebar">
            <ul>
                <li><a href="home_profesor.jsp">Inicio</a></li>
                <li><a href="facultad_profesor.jsp">Facultades</a></li>
                <li><a href="carreras_profesor.jsp">Carreras</a></li>
                <li><a href="cursos_profesor.jsp">Cursos</a></li>
                <li><a href="salones_profesor.jsp">Clases</a></li> 
                <li><a href="horarios_profesor.jsp" class="active">Horarios</a></li> 
                <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                <li><a href="nota_profesor.jsp">Notas</a></li>
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
                <p>
                    <strong>Salones de Hoy (<%= diaHoy.substring(0, 1).toUpperCase() + diaHoy.substring(1) %>):</strong>
                    <% if (salonesHoy.isEmpty()) { %>
                        No tiene clases asignadas hoy.
                    <% } else { %>
                        <% for (String s : salonesHoy) { %>
                            <span class="badge bg-primary me-1"><%= s %></span>
                        <% } %>
                    <% } %>
                </p>
            </div>
            
            <div class="stats-card">
                <div class="stats-number"><%= totalClases %></div>
                <div>Clases Programadas</div>
            </div>
            
            <div id="calendar"></div> <div class="info-section">
                <h3><i class="bi bi-info-circle"></i> Información Importante</h3>
                <ul>
                    <li>Haz clic en cualquier evento para ver más detalles de la clase.</li>
                    <li>Puedes cambiar entre vista semanal, diaria o de lista usando los controles superiores.</li>
                    <li>Los horarios en color azul representan tus clases asignadas.</li>
                </ul>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/locales-all.global.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const calendarEl = document.getElementById('calendar');
            // Agrega esta línea para depurar el JSON de eventos
            console.log("EVENTOS JSON:", <%= eventos.toString() %>); 
            
            // Asegúrate de que calendarEl no sea null antes de inicializar FullCalendar
            if (calendarEl) {
                // ACCESO AL CONSTRUCTOR CON window.FullCalendar.Calendar
                const calendar = new window.FullCalendar.Calendar(calendarEl, {
                    locale: 'es', // Usa 'es' para español
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
                    events: <%= eventos.toString() %>, // Pasa los eventos generados por el JSP

                    eventClick: function(info) {
                        const event = info.event; 
                        const props = event.extendedProps;
                        
                        // Actualizar el contenido del modal
                        document.getElementById('modalCurso').innerText = event.title;
                        document.getElementById('modalCodigo').innerText = props.codigo;
                        document.getElementById('modalSalon').innerText = props.salon;
                        document.getElementById('modalCapacidad').innerText = props.capacidad + " estudiantes";
                        // Para eventos recurrentes semanales, info.event.start/end no siempre tienen la fecha exacta.
                        // Aquí se muestra el día de la semana que FullCalendar deriva.
                        document.getElementById('modalDia').innerText = info.event.start ? info.event.start.toLocaleDateString('es-ES', { weekday: 'long' }) : 'N/A';
                        document.getElementById('modalHorario').innerText = (info.event.start ? info.event.start.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'}) : 'N/A') + 
                                                                             ' - ' + 
                                                                             (info.event.end ? info.event.end.toLocaleTimeString('es-ES', {hour: '2-digit', 'minute':'2-digit'}) : 'N/A');

                        // Crear y mostrar el modal
                        const modal = new bootstrap.Modal(document.getElementById('eventModal'));
                        modal.show();
                    },

                    eventDidMount: function(info) {
                        // Añadir un título al evento para información al pasar el ratón (tooltip)
                        info.el.setAttribute('title', 
                            `${info.event.title}\nSalón: ${info.event.extendedProps.salon}\nHorario: ${info.event.start ? info.event.start.toLocaleTimeString('es-ES', {hour: '2-digit', minute:'2-digit'}) : 'N/A'} - ${info.event.end ? info.event.end.toLocaleTimeString('es-ES', {hour: '2-digit', 'minute':'2-digit'}) : 'N/A'}`
                        );
                    },

                    // Configuración de horas hábiles (fondo gris)
                    businessHours: {
                        daysOfWeek: [1, 2, 3, 4, 5, 6], // Lunes a Sábado
                        startTime: '07:00', 
                        endTime: '22:00' 
                    },

                    // Formato de las etiquetas de tiempo en el eje Y
                    slotLabelFormat: { 
                        hour: '2-digit', 
                        minute: '2-digit', 
                        hour12: false // Formato 24 horas
                    },

                    // Formato de tiempo mostrado en los eventos del calendario
                    eventTimeFormat: { 
                        hour: '2-digit', 
                        minute: '2-digit', 
                        hour12: false // Formato 24 horas
                    }
                }); 

                calendar.render(); // Renderiza el calendario en la página
            } else {
                console.error("El elemento con ID 'calendar' no se encontró en el DOM.");
            }
        });
    </script>

    <div class="modal fade" id="eventModal" tabindex="-1" aria-labelledby="eventModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="eventModalLabel"><i class="bi bi-book me-2"></i>Detalles de la Clase</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p><strong>Curso:</strong> <span id="modalCurso"></span></p>
                    <p><strong>Código:</strong> <span id="modalCodigo"></span></p>
                    <p><strong>Salón:</strong> <span id="modalSalon"></span></p>
                    <p><strong>Capacidad:</strong> <span id="modalCapacidad"></span></p>
                    <p><strong>Día:</strong> <span id="modalDia"></span></p>
                    <p><strong>Horario:</strong> <span id="modalHorario"></span></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>