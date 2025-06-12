<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>

<%
    Object idObj = session.getAttribute("id_profesor");
    int id = -1;
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";

    if (idObj != null) {
        id = Integer.parseInt(idObj.toString());

        // Conexión a la base de datos para obtener información del profesor
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/bduni", "root", "");

            String sql = "SELECT nombre, email, facultad FROM profesores WHERE id_profesor = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                nombreProfesor = rs.getString("nombre");
                emailProfesor = rs.getString("email");
                facultadProfesor = rs.getString("facultad");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistema Universitario - Reportes de Notas</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #002366;
            --secondary-color: #FFD700;
            --accent-color: #800000;
            --light-color: #F5F5F5;
            --dark-color: #333333;
        }

        body {
            background-color: var(--light-color);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .navbar-custom {
            background-color: var(--primary-color) !important;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .navbar-brand {
            color: var(--secondary-color) !important;
            font-weight: bold;
            font-size: 1.5rem;
        }

        .navbar-text {
            color: white !important;
        }

        .user-name {
            color: var(--secondary-color) !important;
            font-weight: bold;
        }

        .sidebar {
            background-color: var(--primary-color);
            min-height: calc(100vh - 56px);
            padding: 0;
        }

        .sidebar .nav-link {
            color: white;
            padding: 1rem 1.5rem;
            border-left: 4px solid transparent;
            transition: all 0.3s;
        }

        .sidebar .nav-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 4px solid var(--secondary-color);
            color: white;
        }

        .sidebar .nav-link.active {
            background-color: rgba(255, 255, 255, 0.2);
            border-left: 4px solid var(--secondary-color);
            color: var(--secondary-color);
            font-weight: bold;
        }

        .main-content {
            padding: 2rem;
        }

        .page-header {
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            color: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .card-custom {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            margin-bottom: 2rem;
        }

        .card-custom:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .card-header-custom {
            background: linear-gradient(45deg, var(--primary-color), var(--accent-color));
            color: white;
            border-radius: 10px 10px 0 0 !important;
            border: none;
            padding: 1rem 1.5rem;
        }

        .btn-primary-custom {
            background: linear-gradient(45deg, var(--primary-color), var(--accent-color));
            border: none;
            border-radius: 8px;
            padding: 0.7rem 1.5rem;
            transition: all 0.3s;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .btn-secondary-custom {
            background-color: var(--secondary-color);
            color: var(--dark-color);
            border: none;
            border-radius: 8px;
            padding: 0.7rem 1.5rem;
            font-weight: 600;
        }

        .btn-secondary-custom:hover {
            background-color: #FFE55C;
            color: var(--dark-color);
        }

        .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 215, 0, 0.25);
        }

        .form-select:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 215, 0, 0.25);
        }

        .chart-container {
            position: relative;
            height: 400px;
            margin: 2rem 0;
        }

        .stats-card {
            background: linear-gradient(45deg, #f8f9fa, #e9ecef);
            border-left: 4px solid var(--secondary-color);
        }

        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .logout-btn {
            background-color: var(--accent-color);
            border: none;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            transition: background-color 0.3s;
        }

        .logout-btn:hover {
            background-color: #990000;
        }

        .table-hover tbody tr:hover {
            background-color: rgba(255, 215, 0, 0.1);
        }

        .badge-custom {
            background-color: var(--secondary-color);
            color: var(--dark-color);
            font-weight: 600;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-custom">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-graduation-cap me-2"></i>Sistema Universitario
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <span class="user-name"><%= nombreProfesor%></span><br>
                    <small><%= emailProfesor%> | <%= facultadProfesor%></small>
                </span>
                <form action="logout.jsp" method="post" class="d-inline">
                    <button type="submit" class="btn logout-btn">
                        <i class="fas fa-sign-out-alt me-1"></i>Cerrar sesión
                    </button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 p-0">
                <div class="sidebar">
                    <nav class="nav flex-column">
                        <a class="nav-link" href="home_profesor.jsp">
                            <i class="fas fa-home me-2"></i>Inicio
                        </a>
                        <a class="nav-link" href="facultad_profesor.jsp">
                            <i class="fas fa-university me-2"></i>Facultades
                        </a>
                        <a class="nav-link" href="cursos_profesor.jsp">
                            <i class="fas fa-book me-2"></i>Cursos
                        </a>
                        <a class="nav-link" href="salones.jsp">
                            <i class="fas fa-door-open me-2"></i>Salones
                        </a>
                        <a class="nav-link" href="horarios.jsp">
                            <i class="fas fa-clock me-2"></i>Horarios
                        </a>
                        <a class="nav-link" href="asistencia.jsp">
                            <i class="fas fa-user-check me-2"></i>Asistencia
                        </a>
                        <a class="nav-link" href="mensaje.jsp">
                            <i class="fas fa-envelope me-2"></i>Mensajería
                        </a>
                        <a class="nav-link" href="nota.jsp">
                            <i class="fas fa-clipboard-list me-2"></i>Notas
                        </a>
                        <a class="nav-link active" href="reporte-notas.jsp">
                            <i class="fas fa-chart-bar me-2"></i>Reportes de Notas
                        </a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-10">
                <div class="main-content">
                    <!-- Page Header -->
                    <div class="page-header">
                        <h1 class="mb-0">
                            <i class="fas fa-chart-bar me-3"></i>Reportes de Notas
                        </h1>
                        <p class="mb-0 mt-2">Genere reportes estadísticos y consolidados de calificaciones</p>
                    </div>

                    <!-- Filtros -->
                    <div class="card card-custom">
                        <div class="card-header card-header-custom">
                            <h5 class="mb-0">
                                <i class="fas fa-filter me-2"></i>Filtros de Búsqueda
                            </h5>
                        </div>
                        <div class="card-body">
                            <form id="filtrosForm">
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label for="curso" class="form-label">
                                                <i class="fas fa-book me-1"></i>Curso
                                            </label>
                                            <select class="form-select" id="curso" name="curso">
                                                <option value="">Todos los cursos</option>
                                                <option value="matematicas">Matemáticas</option>
                                                <option value="fisica">Física</option>
                                                <option value="quimica">Química</option>
                                                <option value="programacion">Programación</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label for="periodo" class="form-label">
                                                <i class="fas fa-calendar me-1"></i>Período
                                            </label>
                                            <select class="form-select" id="periodo" name="periodo">
                                                <option value="">Todos los períodos</option>
                                                <option value="2024-1">2024-1</option>
                                                <option value="2024-2">2024-2</option>
                                                <option value="2025-1">2025-1</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label for="tipoReporte" class="form-label">
                                                <i class="fas fa-chart-line me-1"></i>Tipo de Reporte
                                            </label>
                                            <select class="form-select" id="tipoReporte" name="tipoReporte">
                                                <option value="estadistico">Estadístico</option>
                                                <option value="consolidado">Consolidado</option>
                                                <option value="comparativo">Comparativo</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="mb-3">
                                            <label class="form-label">&nbsp;</label>
                                            <div class="d-grid">
                                                <button type="button" class="btn btn-primary-custom" onclick="generarReporte()">
                                                    <i class="fas fa-search me-2"></i>Generar Reporte
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Estadísticas Rápidas -->
                    <div class="row">
                        <div class="col-md-3">
                            <div class="card stats-card">
                                <div class="card-body text-center">
                                    <div class="stat-number">4.2</div>
                                    <div class="text-muted">Promedio General</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card stats-card">
                                <div class="card-body text-center">
                                    <div class="stat-number">89%</div>
                                    <div class="text-muted">Estudiantes Aprobados</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card stats-card">
                                <div class="card-body text-center">
                                    <div class="stat-number">4.8</div>
                                    <div class="text-muted">Nota Más Alta</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card stats-card">
                                <div class="card-body text-center">
                                    <div class="stat-number">156</div>
                                    <div class="text-muted">Total Estudiantes</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Gráficos -->
                    <div class="row">
                        <div class="col-md-8">
                            <div class="card card-custom">
                                <div class="card-header card-header-custom">
                                    <h5 class="mb-0">
                                        <i class="fas fa-chart-bar me-2"></i>Distribución de Calificaciones
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="chartDistribucion"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card card-custom">
                                <div class="card-header card-header-custom">
                                    <h5 class="mb-0">
                                        <i class="fas fa-chart-pie me-2"></i>Estado de Estudiantes
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="chartEstado"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tabla de Resultados -->
                    <div class="card card-custom">
                        <div class="card-header card-header-custom d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-table me-2"></i>Detalle de Calificaciones
                            </h5>
                            <div>
                                <button class="btn btn-secondary-custom btn-sm me-2" onclick="exportarExcel()">
                                    <i class="fas fa-file-excel me-1"></i>Excel
                                </button>
                                <button class="btn btn-secondary-custom btn-sm" onclick="exportarPDF()">
                                    <i class="fas fa-file-pdf me-1"></i>PDF
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Código</th>
                                            <th>Estudiante</th>
                                            <th>Curso</th>
                                            <th>Parcial 1</th>
                                            <th>Parcial 2</th>
                                            <th>Final</th>
                                            <th>Promedio</th>
                                            <th>Estado</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tablaResultados">
                                        <tr>
                                            <td>EST001</td>
                                            <td>Juan Pérez García</td>
                                            <td>Matemáticas I</td>
                                            <td>4.2</td>
                                            <td>4.5</td>
                                            <td>4.3</td>
                                            <td><strong>4.3</strong></td>
                                            <td><span class="badge bg-success">Aprobado</span></td>
                                        </tr>
                                        <tr>
                                            <td>EST002</td>
                                            <td>María López Ruiz</td>
                                            <td>Matemáticas I</td>
                                            <td>3.8</td>
                                            <td>4.0</td>
                                            <td>4.2</td>
                                            <td><strong>4.0</strong></td>
                                            <td><span class="badge bg-success">Aprobado</span></td>
                                        </tr>
                                        <tr>
                                            <td>EST003</td>
                                            <td>Carlos Mendoza</td>
                                            <td>Matemáticas I</td>
                                            <td>2.8</td>
                                            <td>3.2</td>
                                            <td>3.5</td>
                                            <td><strong>3.2</strong></td>
                                            <td><span class="badge bg-warning">Habilitación</span></td>
                                        </tr>
                                        <tr>
                                            <td>EST004</td>
                                            <td>Ana Rodríguez</td>
                                            <td>Matemáticas I</td>
                                            <td>4.8</td>
                                            <td>4.7</td>
                                            <td>4.9</td>
                                            <td><strong>4.8</strong></td>
                                            <td><span class="badge bg-success">Aprobado</span></td>
                                        </tr>
                                        <tr>
                                            <td>EST005</td>
                                            <td>Luis González</td>
                                            <td>Matemáticas I</td>
                                            <td>2.1</td>
                                            <td>2.5</td>
                                            <td>2.8</td>
                                            <td><strong>2.5</strong></td>
                                            <td><span class="badge bg-danger">Reprobado</span></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <script>
        // Configuración de gráficos
        const ctxDistribucion = document.getElementById('chartDistribucion').getContext('2d');
        const chartDistribucion = new Chart(ctxDistribucion, {
            type: 'bar',
            data: {
                labels: ['0.0-1.0', '1.1-2.0', '2.1-3.0', '3.1-4.0', '4.1-5.0'],
                datasets: [{
                    label: 'Número de Estudiantes',
                    data: [5, 12, 25, 78, 36],
                    backgroundColor: [
                        '#dc3545',
                        '#fd7e14',
                        '#ffc107',
                        '#28a745',
                        '#007bff'
                    ],
                    borderColor: [
                        '#dc3545',
                        '#fd7e14',
                        '#ffc107',
                        '#28a745',
                        '#007bff'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        const ctxEstado = document.getElementById('chartEstado').getContext('2d');
        const chartEstado = new Chart(ctxEstado, {
            type: 'doughnut',
            data: {
                labels: ['Aprobados', 'Habilitación', 'Reprobados'],
                datasets: [{
                    data: [139, 12, 5],
                    backgroundColor: [
                        '#28a745',
                        '#ffc107',
                        '#dc3545'
                    ],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        // Funciones
        function generarReporte() {
            // Aquí iría la lógica para generar el reporte según los filtros
            alert('Generando reporte...');
        }

        function exportarExcel() {
            alert('Exportando a Excel...');
        }

        function exportarPDF() {
            alert('Exportando a PDF...');
        }
    </script>
</body>
</html>