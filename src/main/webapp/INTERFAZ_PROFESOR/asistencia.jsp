<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<%
    Object idObj = session.getAttribute("id_profesor");

    // Se valida solo para evitar error, sin redirigir al index
    int id = -1;
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";
    
    if (idObj != null) {
        id = Integer.parseInt(idObj.toString());
    }

    // Variables para asistencia
    String salonId = request.getParameter("salon_id");
    String nombreSalon = "";
    String nombreCurso = "";
    int contador = 1;
    String fechaDisplay = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    
    // Lista de estudiantes y su asistencia
    List<Map<String, String>> estudiantes = new ArrayList<>();
    
    if (id != -1 && salonId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bd_sw", "root", "");

            // Obtener datos del profesor
            PreparedStatement psProfesor = conn.prepareStatement(
                "SELECT nombre, apellido_paterno, apellido_materno, email " +
                "FROM profesores " +
                "WHERE id_profesor = ?"
            );
            psProfesor.setInt(1, id);
            ResultSet rsProfesor = psProfesor.executeQuery();
            
            if (rsProfesor.next()) {
                nombreProfesor = rsProfesor.getString("nombre") + " " + 
                               rsProfesor.getString("apellido_paterno") + " " + 
                               (rsProfesor.getString("apellido_materno") != null ? rsProfesor.getString("apellido_materno") : "");
                emailProfesor = rsProfesor.getString("email") != null ? rsProfesor.getString("email") : "No especificado";
            }
            rsProfesor.close();
            psProfesor.close();
            
            // Obtener facultad del profesor
            try {
                PreparedStatement psFacultad = conn.prepareStatement(
                    "SELECT f.nombre_facultad " +
                    "FROM profesores p " +
                    "JOIN facultades f ON p.id_facultad = f.id_facultad " +
                    "WHERE p.id_profesor = ?"
                );
                psFacultad.setInt(1, id);
                ResultSet rsFacultad = psFacultad.executeQuery();
                
                if (rsFacultad.next()) {
                    facultadProfesor = rsFacultad.getString("nombre_facultad");
                }
                rsFacultad.close();
                psFacultad.close();
            } catch (Exception e) {
                facultadProfesor = "No asignada";
            }

            // Obtener información del salón y curso
            try {
                PreparedStatement psSalon = conn.prepareStatement(
                    "SELECT s.nombre as salon_nombre, c.nombre as curso_nombre " +
                    "FROM salones s JOIN cursos c ON s.id_curso = c.id_curso " +
                    "WHERE s.id_salon = ?"
                );
                psSalon.setString(1, salonId);
                ResultSet rsSalon = psSalon.executeQuery();
                if (rsSalon.next()) {
                    nombreSalon = rsSalon.getString("salon_nombre");
                    nombreCurso = rsSalon.getString("curso_nombre");
                }
                rsSalon.close();
                psSalon.close();
            } catch (Exception e) {
                nombreSalon = "Salón no encontrado";
                nombreCurso = "Curso no asignado";
            }

            // Obtener lista de estudiantes
            try {
                PreparedStatement psEstudiantes = conn.prepareStatement(
                    "SELECT i.id_inscripcion, e.dni, e.nombre, e.apellido_paterno, e.apellido_materno, " +
                    "a.estado, a.observaciones " +
                    "FROM inscripciones i " +
                    "JOIN estudiantes e ON i.id_estudiante = e.id_estudiante " +
                    "LEFT JOIN asistencias a ON i.id_inscripcion = a.id_inscripcion AND a.fecha = CURDATE() " +
                    "WHERE i.id_salon = ? " +
                    "ORDER BY e.apellido_paterno, e.apellido_materno, e.nombre"
                );
                psEstudiantes.setString(1, salonId);
                ResultSet rsEstudiantes = psEstudiantes.executeQuery();
                
                while (rsEstudiantes.next()) {
                    Map<String, String> estudiante = new HashMap<>();
                    estudiante.put("id_inscripcion", rsEstudiantes.getString("id_inscripcion"));
                    estudiante.put("dni", rsEstudiantes.getString("dni"));
                    estudiante.put("nombre", rsEstudiantes.getString("nombre") + " " + 
                                         rsEstudiantes.getString("apellido_paterno") + " " + 
                                         (rsEstudiantes.getString("apellido_materno") != null ? rsEstudiantes.getString("apellido_materno") : ""));
                    estudiante.put("estado", rsEstudiantes.getString("estado") != null ? rsEstudiantes.getString("estado") : "");
                    estudiante.put("observaciones", rsEstudiantes.getString("observaciones") != null ? rsEstudiantes.getString("observaciones") : "");
                    
                    estudiantes.add(estudiante);
                }
                rsEstudiantes.close();
                psEstudiantes.close();
            } catch (Exception e) {
                // Manejar error
            }

            conn.close();
        } catch (Exception e) {
            out.println("Error al cargar datos: " + e.getMessage());
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistencia - Dashboard Profesores</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #002366 0%, #800020 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .dashboard {
            display: grid;
            grid-template-columns: 280px 1fr;
            min-height: 100vh;
        }
        
        .sidebar {
            background: rgba(0, 35, 102, 0.9);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255, 255, 255, 0.2);
            color: #fff;
            padding: 20px;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }
        
        .sidebar h2 {
            font-size: 20px;
            margin-bottom: 30px;
            text-align: center;
            color: #FFD700;
            border-bottom: 2px solid rgba(255, 215, 0, 0.3);
            padding-bottom: 15px;
        }
        
        .sidebar a {
            display: block;
            color: rgba(255, 255, 255, 0.9);
            text-decoration: none;
            margin: 8px 0;
            padding: 12px 15px;
            border-radius: 8px;
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .sidebar a:hover {
            background: rgba(255, 215, 0, 0.2);
            transform: translateX(5px);
        }
        
        .sidebar a.active {
            background: rgba(255, 215, 0, 0.3);
            font-weight: bold;
            border-left: 4px solid #FFD700;
        }
        
        .main {
            padding: 30px;
            overflow-y: auto;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .professor-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .professor-avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #002366, #800020);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 32px;
            font-weight: bold;
        }
        
        .professor-details h1 {
            color: #002366;
            font-size: 28px;
            margin-bottom: 5px;
        }
        
        .professor-details p {
            color: #666;
            margin: 3px 0;
        }
        
        .attendance-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .attendance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .attendance-title {
            color: #002366;
            font-size: 22px;
            font-weight: 600;
        }
        
        .attendance-date {
            color: #666;
            font-size: 16px;
        }
        
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .attendance-table th {
            background-color: #002366;
            color: white;
            padding: 12px;
            text-align: left;
        }
        
        .attendance-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        
        .attendance-table tr:nth-child(even) {
            background-color: rgba(0, 35, 102, 0.05);
        }
        
        .attendance-table tr:hover {
            background-color: rgba(0, 35, 102, 0.1);
        }
        
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
        }
        
        .btn-presente {
            background-color: rgba(40, 167, 69, 0.2);
            color: #28a745;
        }
        
        .btn-ausente {
            background-color: rgba(220, 53, 69, 0.2);
            color: #dc3545;
        }
        
        .btn-tardanza {
            background-color: rgba(255, 193, 7, 0.2);
            color: #ffc107;
        }
        
        input[type="radio"] {
            display: none;
        }
        
        input[type="radio"]:checked + .btn-presente {
            background-color: #28a745;
            color: white;
        }
        
        input[type="radio"]:checked + .btn-ausente {
            background-color: #dc3545;
            color: white;
        }
        
        input[type="radio"]:checked + .btn-tardanza {
            background-color: #ffc107;
            color: white;
        }
        
        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #002366, #800020);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #003399, #990033);
            transform: translateY(-2px);
        }
        
        .text-center {
            text-align: center;
        }
        
        .mt-4 {
            margin-top: 20px;
        }
        
        @media (max-width: 768px) {
            .dashboard {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                position: fixed;
                top: 0;
                left: -280px;
                height: 100vh;
                z-index: 1000;
                transition: left 0.3s ease;
            }
            
            .btn-group-asistencia {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>

<div class="dashboard">
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Control de Asistencia</h2>
        <a href="home_profesor.jsp">Inicio</a>
        <a href="facultad_profesor.jsp">Facultades</a>
        <a href="carreras_profesor.jsp">Carreras</a>
        <a href="cursos_profesor.jsp">Cursos</a>
        <a href="salones.jsp">Salones</a>
        <a href="horarios.jsp">Horarios</a>
        <a href="asistencia.jsp" class="active">Asistencia</a>
        <a href="mensaje.jsp">Mensajería</a>
        <a href="nota.jsp">Notas</a>
    </div>

    <!-- Main Content -->
    <div class="main">
        <!-- Header con información del profesor -->
        <div class="header">
            <div class="professor-info">
                <div class="professor-avatar">
                    <%= nombreProfesor.length() > 0 ? String.valueOf(nombreProfesor.charAt(0)).toUpperCase() : "P" %>
                </div>
                <div class="professor-details">
                    <h1><%= nombreProfesor.length() > 0 ? nombreProfesor : "Profesor" %></h1>
                    <p><strong>Email:</strong> <%= emailProfesor %></p>
                    <p><strong>Facultad:</strong> <%= facultadProfesor %></p>
                    <p><strong>Fecha:</strong> <%= fechaDisplay %></p>
                </div>
            </div>
        </div>

        <% if (salonId != null && !estudiantes.isEmpty()) { %>
            <div class="attendance-card">
                <div class="attendance-header">
                    <h2 class="attendance-title">Registro de Asistencia - <%= nombreSalon %> (<%= nombreCurso %>)</h2>
                    <div class="attendance-date"><%= fechaDisplay %></div>
                </div>
                
                <form method="post" action="guardar_asistencia.jsp">
                    <input type="hidden" name="profesor_id" value="<%= id %>">
                    <input type="hidden" name="salon_id" value="<%= salonId %>">
                    
                    <table class="attendance-table">
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
                            <% for (Map<String, String> estudiante : estudiantes) { %>
                                <tr>
                                    <td><%= contador++ %></td>
                                    <td><%= estudiante.get("dni") %></td>
                                    <td><%= estudiante.get("nombre") %></td>
                                    <td>
                                        <div class="btn-group-asistencia">
                                            <input type="radio" id="presente_<%= estudiante.get("id_inscripcion") %>" 
                                                   name="asistencia_<%= estudiante.get("id_inscripcion") %>" 
                                                   value="presente" <%= "presente".equals(estudiante.get("estado")) ? "checked" : "" %>>
                                            <label for="presente_<%= estudiante.get("id_inscripcion") %>" 
                                                   class="btn-asistencia btn-presente">Presente</label>
                                            
                                            <input type="radio" id="ausente_<%= estudiante.get("id_inscripcion") %>" 
                                                   name="asistencia_<%= estudiante.get("id_inscripcion") %>" 
                                                   value="ausente" <%= "ausente".equals(estudiante.get("estado")) ? "checked" : "" %>>
                                            <label for="ausente_<%= estudiante.get("id_inscripcion") %>" 
                                                   class="btn-asistencia btn-ausente">Ausente</label>
                                            
                                            <input type="radio" id="tardanza_<%= estudiante.get("id_inscripcion") %>" 
                                                   name="asistencia_<%= estudiante.get("id_inscripcion") %>" 
                                                   value="tardanza" <%= "tardanza".equals(estudiante.get("estado")) ? "checked" : "" %>>
                                            <label for="tardanza_<%= estudiante.get("id_inscripcion") %>" 
                                                   class="btn-asistencia btn-tardanza">Tardanza</label>
                                        </div>
                                    </td>
                                    <td>
                                        <input type="text" class="form-control" 
                                               name="obs_<%= estudiante.get("id_inscripcion") %>" 
                                               value="<%= estudiante.get("observaciones") %>">
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <div class="text-center mt-4">
                        <button type="submit" class="btn-primary">
                            Guardar Asistencia
                        </button>
                    </div>
                </form>
            </div>
        <% } else if (salonId != null) { %>
            <div class="attendance-card">
                <div class="attendance-header">
                    <h2 class="attendance-title">No hay estudiantes registrados en este salón</h2>
                </div>
            </div>
        <% } else { %>
            <div class="attendance-card">
                <div class="attendance-header">
                    <h2 class="attendance-title">Seleccione un salón para registrar asistencia</h2>
                </div>
            </div>
        <% } %>
    </div>
</div>

</body>
</html>