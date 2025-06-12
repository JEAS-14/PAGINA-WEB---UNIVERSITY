<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>

<%
    // Datos del profesor
    int idProfesorLogueado = 1; // Cambiar por: (Integer)session.getAttribute("id_profesor");
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";

    // Obtener información del profesor
    try {
        String url = "jdbc:mysql://localhost:3306/bd_sw";
        String username = "root";
        String password = "";

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, username, password);

        String sqlProfesor = "SELECT CONCAT(nombre, ' ', apellido_paterno, ' ', IFNULL(apellido_materno, '')) as nombre_completo, email, f.nombre_facultad as facultad " +
                             "FROM profesores p " +
                             "LEFT JOIN facultades f ON p.id_facultad = f.id_facultad " +
                             "WHERE p.id_profesor = ?";
        PreparedStatement pstmtProf = conn.prepareStatement(sqlProfesor);
        pstmtProf.setInt(1, idProfesorLogueado);
        ResultSet rsProf = pstmtProf.executeQuery();

        if (rsProf.next()) {
            nombreProfesor = rsProf.getString("nombre_completo");
            emailProfesor = rsProf.getString("email");
            facultadProfesor = rsProf.getString("facultad") != null ? rsProf.getString("facultad") : "No asignada";
        }
        rsProf.close();
        pstmtProf.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Obtener estadísticas
    int totalSalones = 0;
    int totalAlumnos = 0;
    int salonesActivos = 0;

    try {
        String url = "jdbc:mysql://localhost:3306/bduni";
        String username = "root";
        String password = "";

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, username, password);

        // Estadísticas del profesor
        String sqlStats = "SELECT " +
                         "COUNT(*) as total_salones, " +
                         "COUNT(CASE WHEN estado = 'activo' THEN 1 END) as salones_activos " +
                         "FROM salones WHERE id_profesor = ?";
        PreparedStatement pstmtStats = conn.prepareStatement(sqlStats);
        pstmtStats.setInt(1, idProfesorLogueado);
        ResultSet rsStats = pstmtStats.executeQuery();

        if (rsStats.next()) {
            totalSalones = rsStats.getInt("total_salones");
            salonesActivos = rsStats.getInt("salones_activos");
        }

        // Total de alumnos
        String sqlAlumnos = "SELECT COUNT(DISTINCT i.id_alumno) as total_alumnos " +
                           "FROM inscripciones i " +
                           "INNER JOIN salones s ON i.id_salon = s.id_salon " +
                           "WHERE s.id_profesor = ? AND i.estado = 'activo'";
        PreparedStatement pstmtAlumnos = conn.prepareStatement(sqlAlumnos);
        pstmtAlumnos.setInt(1, idProfesorLogueado);
        ResultSet rsAlumnos = pstmtAlumnos.executeQuery();

        if (rsAlumnos.next()) {
            totalAlumnos = rsAlumnos.getInt("total_alumnos");
        }

        rsStats.close();
        pstmtStats.close();
        rsAlumnos.close();
        pstmtAlumnos.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Salones - Dashboard Profesores</title>
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card.blue {
            border-left: 5px solid #002366;
        }
        
        .stat-card.green {
            border-left: 5px solid #28a745;
        }
        
        .stat-card.orange {
            border-left: 5px solid #fd7e14;
        }
        
        .stat-card.purple {
            border-left: 5px solid #6f42c1;
        }
        
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #002366;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* Estilos específicos para los salones */
        .salon-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #002366;
        }

        .salon-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .salon-card-title {
            color: #002366;
            margin: 0;
            font-size: 22px;
        }

        .badge-status {
            font-size: 0.8rem;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
        }

        .salon-card-body {
            margin-bottom: 15px;
        }

        .salon-card-footer {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }

        .progress {
            height: 8px;
            margin-bottom: 15px;
            border-radius: 4px;
        }

        .btn-action {
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

        .btn-action:hover {
            background: linear-gradient(135deg, #003399, #990033);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: #6c757d;
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        .text-muted {
            color: #6c757d !important;
        }

        .bg-success {
            background-color: #28a745 !important;
        }

        .bg-secondary {
            background-color: #6c757d !important;
        }

        .bg-warning {
            background-color: #ffc107 !important;
        }

        .bg-primary {
            background-color: #002366 !important;
        }

        .row {
            display: flex;
            flex-wrap: wrap;
            margin-right: -15px;
            margin-left: -15px;
        }

        .col-md-6 {
            flex: 0 0 50%;
            max-width: 50%;
            padding-right: 15px;
            padding-left: 15px;
        }

        .mb-3 {
            margin-bottom: 1rem !important;
        }

        .mb-2 {
            margin-bottom: 0.5rem !important;
        }

        .mt-2 {
            margin-top: 0.5rem !important;
        }

        .small {
            font-size: 80%;
            font-weight: 400;
        }

        .filters-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .filter-group {
            display: flex;
            gap: 15px;
            align-items: center;
            margin-bottom: 15px;
        }

        .filter-label {
            font-weight: bold;
            color: #002366;
            min-width: 100px;
        }

        .form-select {
            display: block;
            width: 100%;
            padding: 0.375rem 2.25rem 0.375rem 0.75rem;
            font-size: 1rem;
            font-weight: 400;
            line-height: 1.5;
            color: #212529;
            background-color: #fff;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 16px 12px;
            border: 1px solid #ced4da;
            border-radius: 0.375rem;
            transition: border-color .15s ease-in-out,box-shadow .15s ease-in-out;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
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
            
            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }

            .filter-group {
                flex-direction: column;
                align-items: flex-start;
            }

            .salon-card-footer {
                flex-direction: column;
                gap: 10px;
            }

            .btn-action {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>

<div class="dashboard">
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Gestión de Salones</h2>
        
        <a href="home_profesor.jsp">Inicio</a>
        <a href="facultad_profesor.jsp">Facultades</a>
        <a href="carreras_profesor.jsp">Carreras</a>
        <a href="cursos_profesor.jsp">Cursos</a>
        <a href="salones.jsp" class="active">Salones</a>
        <a href="horarios.jsp">Horarios</a>
        <a href="asistencia.jsp">Asistencia</a>
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
                    <p><strong>Fecha:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></p>
                </div>
            </div>
        </div>

        <!-- Estadísticas rápidas sobre salones -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <div class="stat-number"><%= totalSalones %></div>
                <div class="stat-label">Total Salones</div>
            </div>
            <div class="stat-card green">
                <div class="stat-number"><%= salonesActivos %></div>
                <div class="stat-label">Salones Activos</div>
            </div>
            <div class="stat-card orange">
                <div class="stat-number"><%= totalAlumnos %></div>
                <div class="stat-label">Total Alumnos</div>
            </div>
            <div class="stat-card purple">
                <div class="stat-number"><%= salonesActivos > 0 ? Math.round((salonesActivos * 100.0) / totalSalones) : 0 %>%</div>
                <div class="stat-label">Salones Activos</div>
            </div>
        </div>

        <!-- Filtros -->
        <div class="filters-container">
            <h3>Filtrar Salones</h3>
            <div class="filter-group">
                <span class="filter-label">Semestre:</span>
                <select class="form-select" id="filtroSemestre" style="max-width: 200px;">
                    <option value="">Todos</option>
                    <option value="2025-I">2025-I</option>
                    <option value="2025-II">2025-II</option>
                </select>
            </div>
            <div class="filter-group">
                <span class="filter-label">Estado:</span>
                <select class="form-select" id="filtroEstado" style="max-width: 200px;">
                    <option value="">Todos</option>
                    <option value="activo">Activo</option>
                    <option value="inactivo">Inactivo</option>
                </select>
                <button class="btn-action" onclick="filtrarSalones()" style="margin-left: 10px;">
                    <i class="fas fa-search"></i> Filtrar
                </button>
            </div>
        </div>

        <!-- Lista de Salones -->
        <div id="salonesContainer">
            <%
                try {
                    String url = "jdbc:mysql://localhost:3306/bduni";
                    String username = "root";
                    String password = "";

                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(url, username, password);

                    // Solo salones del profesor logueado
                    String sqlSalones = "SELECT s.id_salon, s.nombre_salon, s.capacidad, s.estado, s.semestre, s.año_academico, " +
                                       "c.nombre_curso, c.codigo_curso, " +
                                       "h.dia_semana, h.hora_inicio, h.hora_fin, h.aula, " +
                                       "(SELECT COUNT(*) FROM inscripciones i WHERE i.id_salon = s.id_salon AND i.estado = 'activo') as alumnos_inscritos " +
                                       "FROM salones s " +
                                       "INNER JOIN cursos c ON s.id_curso = c.id_curso " +
                                       "LEFT JOIN horarios h ON s.id_horario = h.id_horario " +
                                       "WHERE s.id_profesor = ? " +
                                       "ORDER BY s.estado DESC, s.nombre_salon";

                    PreparedStatement pstmt = conn.prepareStatement(sqlSalones);
                    pstmt.setInt(1, idProfesorLogueado);
                    ResultSet rs = pstmt.executeQuery();

                    while (rs.next()) {
                        // Validación segura del estado
                        String estado = rs.getString("estado");
                        String badgeClass = (estado != null && estado.equals("activo")) ? "bg-success" : "bg-secondary";

                        // Protección contra división por cero y valores negativos
                        int capacidad = rs.getInt("capacidad");
                        int alumnosInscritos = rs.getInt("alumnos_inscritos");
                        int porcentajeOcupacion = 0;

                        if (capacidad > 0 && alumnosInscritos >= 0) {
                            porcentajeOcupacion = (int) Math.round((alumnosInscritos * 100.0) / capacidad);
                            // Limitar el porcentaje a un máximo de 100%
                            porcentajeOcupacion = Math.min(porcentajeOcupacion, 100);
                        }
            %>
            <div class="salon-card">
                <div class="salon-card-header">
                    <h3 class="salon-card-title">
                        <i class="fas fa-door-open"></i> <%= rs.getString("nombre_salon") %>
                    </h3>
                    <span class="badge-status <%= badgeClass %>">
                        <%= rs.getString("estado").toUpperCase() %>
                    </span>
                </div>

                <div class="salon-card-body">
                    <div class="mb-3">
                        <h5><i class="fas fa-book"></i> <%= rs.getString("nombre_curso") %></h5>
                        <small class="text-muted">Código: <%= rs.getString("codigo_curso") %></small>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span><i class="fas fa-users"></i> Estudiantes inscritos:</span>
                                <strong><%= rs.getInt("alumnos_inscritos") %></strong>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span><i class="fas fa-chair"></i> Capacidad:</span>
                                <strong><%= rs.getInt("capacidad") %></strong>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-2">
                                <span>Ocupación: <strong><%= porcentajeOcupacion %>%</strong></span>
                                <div class="progress">
                                    <div class="progress-bar <%= porcentajeOcupacion > 80 ? "bg-warning" : "bg-success" %>" 
                                         style="width: <%= porcentajeOcupacion %>%"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <% if (rs.getString("dia_semana") != null) { %>
                    <div class="mb-3">
                        <p class="mb-1"><i class="fas fa-calendar"></i> Horario:</p>
                        <p class="mb-0">
                            <%= rs.getString("dia_semana") %> 
                            <%= rs.getTime("hora_inicio") %> - <%= rs.getTime("hora_fin") %>
                            <% if (rs.getString("aula") != null) { %>
                            <br><i class="fas fa-map-marker-alt"></i> <%= rs.getString("aula") %>
                            <% } %>
                        </p>
                    </div>
                    <% } %>

                    <div class="mb-2">
                        <span class="badge bg-primary"><%= rs.getString("semestre") %></span>
                        <span class="badge bg-secondary"><%= rs.getInt("año_academico") %></span>
                    </div>
                </div>

                <div class="salon-card-footer">
                    <button class="btn-action" onclick="verAlumnos(<%= rs.getInt("id_salon") %>, '<%= rs.getString("nombre_salon") %>')">
                        <i class="fas fa-users"></i> Ver Estudiantes
                    </button>
                    <% if (rs.getString("estado").equals("activo")) { %>
                    <button class="btn-action" onclick="gestionarNotas(<%= rs.getInt("id_salon") %>)">
                        <i class="fas fa-clipboard-list"></i> Gestionar Notas
                    </button>
                    <% } %>
                </div>
            </div>
            <%
                    }

                    if (!rs.isBeforeFirst()) {
            %>
            <div class="salon-card" style="text-align: center; padding: 40px;">
                <i class="fas fa-chalkboard" style="font-size: 3rem; color: #6c757d; margin-bottom: 20px;"></i>
                <h4 style="color: #6c757d;">No tienes salones asignados</h4>
                <p style="color: #6c757d;">Contacta con el administrador para la asignación de salones.</p>
            </div>
            <%
                    }

                    rs.close();
                    pstmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='salon-card' style='color: #dc3545;'><i class='fas fa-exclamation-triangle'></i> Error al cargar los salones: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</div>

<!-- Modal Ver Alumnos -->
<div class="modal fade" id="modalAlumnos" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #002366, #800020); color: white;">
                <h5 class="modal-title" id="tituloModalAlumnos">
                    <i class="fas fa-users"></i> Estudiantes del Salón
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="contenidoAlumnos">
                <div style="text-align: center; padding: 30px;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-2">Cargando estudiantes...</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function verAlumnos(idSalon, nombreSalon) {
        document.getElementById('tituloModalAlumnos').innerHTML =
            '<i class="fas fa-users"></i> Estudiantes de ' + nombreSalon;

        // Mostrar modal
        const modal = new bootstrap.Modal(document.getElementById('modalAlumnos'));
        modal.show();

        // Cargar contenido
        fetch('obteneralumnos.jsp?id_salon=' + idSalon)
            .then(response => response.text())
            .then(data => {
                document.getElementById('contenidoAlumnos').innerHTML = data;
            })
            .catch(error => {
                document.getElementById('contenidoAlumnos').innerHTML =
                    '<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> Error al cargar los estudiantes: ' + error + '</div>';
            });
    }

    function gestionarNotas(idSalon) {
        window.location.href = 'gestionar_notas.jsp?id_salon=' + idSalon;
    }

    function filtrarSalones() {
        const semestre = document.getElementById('filtroSemestre').value;
        const estado = document.getElementById('filtroEstado').value;

        const cards = document.querySelectorAll('#salonesContainer .salon-card');

        cards.forEach(card => {
            let mostrar = true;

            if (semestre && !card.innerHTML.includes(semestre)) {
                mostrar = false;
            }

            if (estado) {
                const badge = card.querySelector('.badge-status');
                if (!badge || !badge.textContent.toLowerCase().includes(estado)) {
                    mostrar = false;
                }
            }

            card.style.display = mostrar ? 'block' : 'none';
        });
    }
</script>
</body>
</html>