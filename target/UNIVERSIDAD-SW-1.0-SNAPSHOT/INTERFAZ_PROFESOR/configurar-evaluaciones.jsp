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
    <title>Sistema Universitario - Configurar Evaluaciones</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #002366;
            --secondary-color: #FFD700;
            --accent-color: #800000;
            --light-color: #F5F5F5;
            --dark-color: #333333;
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
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

        .btn-success-custom {
            background-color: var(--success-color);
            border: none;
            border-radius: 8px;
            padding: 0.7rem 1.5rem;
        }

        .btn-danger-custom {
            background-color: var(--danger-color);
            border: none;
            border-radius: 8px;
            padding: 0.7rem 1.5rem;
        }

        .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 215, 0, 0.25);
        }

        .form-select:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 215, 0, 0.25);
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

        .evaluation-item {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            border-left: 4px solid var(--secondary-color);
            transition: all 0.3s;
        }

        .evaluation-item:hover {
            background-color: #e9ecef;
            transform: translateX(5px);
        }

        .percentage-input {
            width: 80px;
            text-align: center;
        }

        .percentage-display {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .total-percentage {
            font-size: 1.5rem;
            font-weight: bold;
            padding: 1rem;
            border-radius: 8px;
            text-align: center;
        }

        .total-valid {
            background-color: #d4edda;
            color: #155724;
            border: 2px solid #c3e6cb;
        }

        .total-invalid {
            background-color: #f8d7da;
            color: #721c24;
            border: 2px solid #f5c6cb;
        }

        .drag-handle {
            cursor: move;
            color: #6c757d;
        }

        .drag-handle:hover {
            color: var(--primary-color);
        }

        .evaluation-template {
            background: linear-gradient(45deg, #f8f9fa, #e9ecef);
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            border: 2px dashed #dee2e6;
        }

        .template-item {
            background-color: white;
            border-radius: 6px;
            padding: 0.8rem;
            margin-bottom: 0.5rem;
            border: 1px solid #dee2e6;
            cursor: pointer;
            transition: all 0.3s;
        }

        .template-item:hover {
            background-color: var(--secondary-color);
            color: var(--dark-color);
            transform: scale(1.02);
        }

        .evaluation-type-badge {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            margin-right: 0.5rem;
        }

        .badge-parcial {
            background-color: #e3f2fd;
            color: #1565c0;
        }

        .badge-final {
            background-color: #fce4ec;
            color: #c2185b;
        }

        .badge-taller {
            background-color: #f3e5f5;
            color: #7b1fa2;
        }

        .badge-proyecto {
            background-color: #e8f5e8;
            color: #388e3c;
        }

        .badge-quiz {
            background-color: #fff3e0;
            color: #f57c00;
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
                        <a class="nav-link active" href="configurar-evaluaciones.jsp">
                            <i class="fas fa-cogs me-2"></i>Configurar Evaluaciones
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
                            <i class="fas fa-cogs me-3"></i>Configurar Evaluaciones
                        </h1>
                        <p class="mb-0 mt-2">Defina los criterios y porcentajes de evaluación para sus cursos</p>
                    </div>

                    <!-- Selección de Curso -->
                    <div class="card card-custom">
                        <div class="card-header card-header-custom">
                            <h5 class="mb-0">
                                <i class="fas fa-book me-2"></i>Seleccionar Curso
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="cursoSelect" class="form-label">
                                            <i class="fas fa-graduation-cap me-1"></i>Curso
                                        </label>
                                        <select class="form-select" id="cursoSelect" onchange="cargarEvaluaciones()">
                                            <option value="">Seleccione un curso</option>
                                            <option value="matematicas1">Matemáticas I</option>
                                            <option value="fisica1">Física I</option>
                                            <option value="quimica1">Química General</option>
                                            <option value="programacion1">Programación I</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="periodoSelect" class="form-label">
                                            <i class="fas fa-calendar me-1"></i>Período Académico
                                        </label>
                                        <select class="form-select" id="periodoSelect">
                                            <option value="2025-1">2025-1</option>
                                            <option value="2024-2">2024-2</option>
                                            <option value="2024-1">2024-1</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <!-- Plantillas de Evaluación -->
                        <div class="col-md-4">
                            <div class="card card-custom">
                                <div class="card-header card-header-custom">
                                    <h5 class="mb-0">
                                        <i class="fas fa-templates me-2"></i>Plantillas
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="evaluation-template">
                                        <h6 class="mb-3">
                                            <i class="fas fa-star me-2"></i>Plantillas Predefinidas
                                        </h6>
                                        <div class="template-item" onclick="aplicarPlantilla('tradicional')">
                                            <strong>Tradicional</strong><br>
                                            <small>2 Parciales (70%) + Final (30%)</small>
                                        </div>
                                        <div class="template-item" onclick="aplicarPlantilla('continua')">
                                            <strong>Evaluación Continua</strong><br>
                                            <small>Quizzes + Talleres + Parciales</small>
                                        </div>
                                        <div class="template-item" onclick="aplicarPlantilla('proyecto')">
                                            <strong>Por Proyectos</strong><br>
                                            <small>Proyecto (60%) + Sustentación (40%)</small>
                                        </div>
                                    </div>

                                    <div class="mt-3">
                                        <h6 class="mb-3">
                                            <i class="fas fa-plus me-2"></i>Agregar Evaluación
                                        </h6>
                                        <div class="row">
                                            <div class="col-12">
                                                <div class="mb-2">
                                                    <input type="text" class="form-control" id="nombreEvaluacion" placeholder="Nombre de la evaluación">
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="mb-2">
                                                    <select class="form-select" id="tipoEvaluacion">
                                                        <option value="parcial">Parcial</option>
                                                        <option value="final">Final</option>
                                                        <option value="quiz">Quiz</option>
                                                        <option value="taller">Taller</option>
                                                        <option value="proyecto">Proyecto</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="mb-2">
                                                    <input type="number" class="form-control" id="porcentajeEvaluacion" placeholder="%" min="0" max="100">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <button class="btn btn-primary-custom btn-sm w-100" onclick="agregarEvaluacion()">
                                                    <i class="fas fa-plus me-1"></i>Agregar
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Configuración Actual -->
                        <div class="col-md-8">
                            <div class="card card-custom">
                                <div class="card-header card-header-custom d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">
                                        <i class="fas fa-list me-2"></i>Configuración de Evaluaciones
                                    </h5>
                                    <div>
                                        <button class="btn btn-secondary-custom btn-sm me-2" onclick="guardarConfiguracion()">
                                            <i class="fas fa-save me-1"></i>Guardar
                                        </button>
                                        <button class="btn btn-danger-custom btn-sm" onclick="limpiarEvaluaciones()">
                                            <i class="fas fa-trash me-1"></i>Limpiar
                                        </button>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <!-- Total de Porcentaje -->
                                    <div class="total-percentage total-valid" id="totalPorcentaje">
                                        Total: <span id="porcentajeTotal">0</span>%
                                    </div>

                                    <!-- Lista de Evaluaciones -->
                                    <div id="listaEvaluaciones">
                                        <!-- Las evaluaciones se cargarán aquí dinámicamente -->
                                    </div>

                                    <!-- Mensaje cuando no hay evaluaciones -->
                                    <div id="mensajeVacio" class="text-center py-5" style="display: none;">
                                        <i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i>
                                        <h5 class="text-muted">No hay evaluaciones configuradas</h5>
                                        <p class="text-muted">Seleccione un curso y agregue evaluaciones usando las plantillas o manualmente</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Configuraciones Adicionales -->
                            <div class="card card-custom">
                                <div class="card-header card-header-custom">
                                    <h5 class="mb-0">
                                        <i class="fas fa-sliders-h me-2"></i>Configuraciones Adicionales
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="notaMinima" class="form-label">
                                                    <i class="fas fa-chart-line me-1"></i>Nota Mínima de Aprobación
                                                </label>
                                                <input type="number" class="form-control" id="notaMinima" value="3.0" step="0.1" min="0" max="5">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="notaHabilitacion" class="form-label">
                                                    <i class="fas fa-exclamation-triangle me-1"></i>Nota Mínima para Habilitación
                                                </label>
                                                <input type="number" class="form-control" id="notaHabilitacion" value="2.0" step="0.1" min="0" max="5">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="permitirRecuperacion">
                                                <label class="form-check-label" for="permitirRecuperacion">
                                                    Permitir recuperación de notas
                                                </label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="redondeoAutomatico" checked>
                                                <label class="form-check-label" for="redondeoAutomatico">
                                                    Redondeo automático de notas
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script>
        let evaluaciones = [];
        let evaluacionCounter = 0;

        // Plantillas predefinidas
        const plantillas = {
            tradicional: [
                {nombre: 'Primer Parcial', tipo: 'parcial', porcentaje: 35},
                {nombre: 'Segundo Parcial', tipo: 'parcial', porcentaje: 35},
                {nombre: 'Examen Final', tipo: 'final', porcentaje: 30}
            ],
            continua: [
                {nombre: 'Quiz 1', tipo: 'quiz', porcentaje: 10},
                {nombre: 'Quiz 2', tipo: 'quiz', porcentaje: 10},
                {nombre: 'Taller 1', tipo: 'taller', porcentaje: 15},
                {nombre: 'Taller 2', tipo: 'taller', porcentaje: 15},
                {nombre: 'Primer Parcial', tipo: 'parcial', porcentaje: 25},
                {nombre: 'Segundo Parcial', tipo: 'parcial', porcentaje: 25}
            ],
            proyecto: [
                {nombre: 'Proyecto Final', tipo: 'proyecto', porcentaje: 60},
                {nombre: 'Sustentación', tipo: 'final', porcentaje: 40}
            ]
        };

        function cargarEvaluaciones() {
            const curso = document.getElementById('cursoSelect').value;
            if (curso) {
                // Aquí cargarías las evaluaciones desde la base de datos
                mostrarMensajeVacio();
            }
        }

        function aplicarPlantilla(tipoPlantilla) {
            if (!document.getElementById('cursoSelect').value) {
                alert('Por favor seleccione un curso primero');
                return;
            }

            evaluaciones = [];
            const plantilla = plantillas[tipoPlantilla];
            
            plantilla.forEach(eval => {
                evaluaciones.push({
                    id: ++evaluacionCounter,
                    nombre: eval.nombre,
                    tipo: eval.tipo,
                    porcentaje: eval.porcentaje
                });
            });

            actualizarListaEvaluaciones();
            calcularPorcentajeTotal();
        }

        function agregarEvaluacion() {
            const nombre = document.getElementById('nombreEvaluacion').value;
            const tipo = document.getElementById('tipoEvaluacion').value;
            const porcentaje = parseInt(document.getElementById('porcentajeEvaluacion').value);

            if (!nombre || !porcentaje) {
                alert('Por favor complete todos los campos');
                return;
            }

            if (!document.getElementById('cursoSelect').value) {
                alert('Por favor seleccione un curso primero');
                return;
            }

            evaluaciones.push({
                id: ++evaluacionCounter,
                nombre: nombre,
                tipo: tipo,
                porcentaje: porcentaje
            });

            // Limpiar campos
            document.getElementById('nombreEvaluacion').value = '';
            document.getElementById('porcentajeEvaluacion').value = '';

            actualizarListaEvaluaciones();
            calcularPorcentajeTotal();
        }

        function eliminarEvaluacion(id) {
            evaluaciones = evaluaciones.filter(eval => eval.id !== id);
            actualizarListaEvaluaciones();
            calcularPorcentajeTotal();
        }

        function editarPorcentaje(id, nuevoPorcentaje) {
            const evaluacion = evaluaciones.find(eval => eval.id === id);
            if (evaluacion) {
                evaluacion.porcentaje = parseInt(nuevoPorcentaje);
                calcularPorcentajeTotal();
            }
        }

        function actualizarListaEvaluaciones() {
            const lista = document.getElementById('listaEvaluaciones');
            const mensajeVacio = document.getElementById('mensajeVacio');

            if (evaluaciones.length === 0) {
                mostrarMensajeVacio();
                return;
            }

            mensajeVacio.style.display = 'none';
            
            let html = '';
            evaluaciones.forEach(eval => {
                const badgeClass = `badge-${eval.tipo}`;
                html += `
                    <div class="evaluation-item">
                        <div class="row align-items-center">
                            <div class="col-1">
                                <i class="fas fa-grip-vertical drag-handle"></i>
                            </div>
                            <div class="col-6">
                                <span class="evaluation-type-badge ${badgeClass}">${eval.tipo.toUpperCase()}</span>
                                <strong>${eval.nombre}</strong>
                            </div>
                            <div class="col-3">
                                <div class="input-group">
                                    <input type="number" class="form-control percentage-input" 
                                           value="${eval.porcentaje}" min="0" max="100"
                                           onchange="editarPorcentaje(${eval.id}, this.value)">
                                    <span class="input-group-text">%</span>
                                </div>
                            </div>
                            <div class="col-2 text-end">
                                <button class="btn btn-danger btn-sm" onclick="eliminarEvaluacion(${eval.id})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                `;
            });

            lista.innerHTML = html;
        }

        function calcularPorcentajeTotal() {
            const total = evaluaciones.reduce((sum, eval) => sum + eval.porcentaje, 0);
            const totalElement = document.getElementById('porcentajeTotal');
            const containerElement = document.getElementById('totalPorcentaje');
            
            totalElement.textContent = total;
            
            if (total === 100) {
                containerElement.className = 'total-percentage total-valid';
            } else {
                containerElement.className = 'total-percentage total-invalid';
            }
        }

        function mostrarMensajeVacio() {
            document.getElementById('listaEvaluaciones').innerHTML = '';
            document.getElementById('mensajeVacio').style.display = 'block';
            document.getElementById('porcentajeTotal').textContent = '0';
            document.getElementById('totalPorcentaje').className = 'total-percentage total-invalid';
        }

        function limpiarEvaluaciones() {
            if (confirm('¿Está seguro de que desea eliminar todas las evaluaciones?')) {
                evaluaciones = [];
                mostrarMensajeVacio();
            }
        }

        function guardarConfiguracion() {
            if (!document.getElementById('cursoSelect').value) {
                alert('Por favor seleccione un curso');
                return;
            }

            if (evaluaciones.length === 0) {
                alert('Por favor agregue al menos una evaluación');
                return;
            }

            const total = evaluaciones.reduce((sum, eval) => sum + eval.porcentaje, 0);
            if (total !== 100) {
                alert('El porcentaje total debe ser exactamente 100%');
                return;
            }

            // Aquí enviarías los datos al servidor
            alert('Configuración guardada exitosamente');
        }

        // Inicializar
        mostrarMensajeVacio();
    </script>
</body>
</html>