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

    // Obtener cursos del profesor
    List<Map<String, Object>> cursos = new ArrayList<>();
    Connection con = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/bduni", "root", "");
        
        String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo FROM cursos c WHERE c.id_profesor = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> curso = new HashMap<>();
            curso.put("id_curso", rs.getInt("id_curso"));
            curso.put("nombre_curso", rs.getString("nombre_curso"));
            curso.put("codigo", rs.getString("codigo"));
            cursos.add(curso);
        }
        
        rs.close();
        ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (con != null) con.close();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consultar Notas - Sistema Universitario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #002366;
            --secondary-color: #FFD700;
            --accent-color: #800000;
            --light-color: #F5F5F5;
            --dark-color: #333333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-color);
            color: var(--dark-color);
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--secondary-color);
        }

        .user-info {
            color: var(--secondary-color);
        }

        .sidebar {
            background-color: var(--primary-color);
            min-height: calc(100vh - 76px);
            padding: 0;
        }

        .sidebar .nav-link {
            color: white;
            padding: 0.8rem 1.5rem;
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
            font-weight: bold;
            color: white;
        }

        .main-content {
            padding: 2rem;
        }

        .page-header {
            background: linear-gradient(135deg, var(--accent-color), var(--primary-color));
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }

        .form-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-top: 4px solid var(--accent-color);
        }

        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-primary:hover {
            background-color: var(--accent-color);
            border-color: var(--accent-color);
        }

        .btn-outline-primary {
            color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .btn-outline-primary:hover {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }

        .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(255, 215, 0, 0.25);
        }

        .table-hover tbody tr:hover {
            background-color: rgba(128, 0, 0, 0.05);
        }

        .nota-excelente {
            background-color: #d4edda;
            color: #155724;
            font-weight: bold;
        }

        .nota-buena {
            background-color: #d1ecf1;
            color: #0c5460;
            font-weight: bold;
        }

        .nota-regular {
            background-color: #fff3cd;
            color: #856404;
            font-weight: bold;
        }

        .nota-deficiente {
            background-color: #f8d7da;
            color: #721c24;
            font-weight: bold;
        }

        .estadisticas-card {
            border-left: 4px solid var(--secondary-color);
        }

        .stat-icon {
            font-size: 2rem;
            color: var(--primary-color);
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="container-fluid">
            <div class="row align-items-center">
                <div class="col">
                    <div class="logo">
                        <i class="fas fa-university me-2"></i>Sistema Universitario
                    </div>
                </div>
                <div class="col-auto">
                    <div class="user-info text-end">
                        <div class="fw-bold"><%= nombreProfesor %></div>
                        <small><%= emailProfesor %></small>
                        <div><small><%= facultadProfesor %></small></div>
                        <form action="logout.jsp" method="post" class="d-inline">
                            <button type="submit" class="btn btn-outline-light btn-sm mt-1">
                                <i class="fas fa-sign-out-alt me-1"></i>Cerrar sesión
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 sidebar p-0">
                <nav class="nav flex-column">
                    <a class="nav-link" href="home_profesor.jsp">
                        <i class="fas fa-home me-2"></i>Inicio
                    </a>
                    <a class="nav-link" href="facultad_profesor.jsp">
                        <i class="fas fa-building me-2"></i>Facultades
                    </a>
                    <a class="nav-link" href="cursos_profesor.jsp">
                        <i class="fas fa-book me-2"></i>Cursos
                    </a>
                    <a class="nav-link" href="salones.jsp">
                        <i class="fas fa-door-open me-2"></i>Salones
                    </a>
                    <a class="nav-link" href="horarios.jsp">
                        <i class="fas fa-calendar me-2"></i>Horarios
                    </a>
                    <a class="nav-link" href="asistencia.jsp">
                        <i class="fas fa-user-check me-2"></i>Asistencia
                    </a>
                    <a class="nav-link" href="mensaje.jsp">
                        <i class="fas fa-envelope me-2"></i>Mensajería
                    </a>
                    <a class="nav-link active" href="nota.jsp">
                        <i class="fas fa-clipboard-list me-2"></i>Notas
                    </a>
                </nav>
            </div>

            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 main-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div class="row align-items-center">
                        <div class="col">
                            <h1 class="mb-0">
                                <i class="fas fa-search me-3"></i>Consultar Notas
                            </h1>
                            <p class="mb-0 mt-2">Revise las calificaciones registradas por curso o estudiante</p>
                        </div>
                        <div class="col-auto">
                            <a href="nota.jsp" class="btn btn-outline-light">
                                <i class="fas fa-arrow-left me-2"></i>Volver
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Filtros de Búsqueda -->
                <div class="card form-card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-filter me-2"></i>Filtros de Búsqueda
                        </h5>
                    </div>
                    <div class="card-body">
                        <form id="filtrosForm">
                            <div class="row">
                                <div class="col-md-4">
                                    <label for="curso" class="form-label">Curso</label>
                                    <select class="form-select" id="curso" name="curso">
                                        <option value="">Todos los cursos</option>
                                        <% for (Map<String, Object> curso : cursos) { %>
                                            <option value="<%= curso.get("id_curso") %>">
                                                <%= curso.get("codigo") %> - <%= curso.get("nombre_curso") %>
                                            </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label for="evaluacion" class="form-label">Tipo de Evaluación</label>
                                    <select class="form-select" id="evaluacion" name="evaluacion">
                                        <option value="">Todas las evaluaciones</option>
                                        <option value="examen_parcial">Examen Parcial</option>
                                        <option value="examen_final">Examen Final</option>
                                        <option value="practica">Práctica</option>
                                        <option value="tarea">Tarea</option>
                                        <option value="participacion">Participación</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label for="estudiante" class="form-label">Buscar Estudiante</label>
                                    <input type="text" class="form-control" id="estudiante" name="estudiante" 
                                           placeholder="Código o nombre del estudiante">
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-md-4">
                                    <label for="fecha_desde" class="form-label">Desde</label>
                                    <input type="date" class="form-control" id="fecha_desde" name="fecha_desde">
                                </div>
                                <div class="col-md-4">
                                    <label for="fecha_hasta" class="form-label">Hasta</label>
                                    <input type="date" class="form-control" id="fecha_hasta" name="fecha_hasta">
                                </div>
                                <div class="col-md-4">
                                    <label for="nota_minima" class="form-label">Nota Mínima</label>
                                    <input type="number" class="form-control" id="nota_minima" name="nota_minima" 
                                           min="0" max="20" step="0.1" placeholder="0.0">
                                </div>
                            </div>
                            <div class="mt-3 d-flex gap-2">
                                <button type="button" class="btn btn-primary" onclick="buscarNotas()">
                                    <i class="fas fa-search me-2"></i>Buscar
                                </button>
                                <button type="button" class="btn btn-outline-secondary" onclick="limpiarFiltros()">
                                    <i class="fas fa-eraser me-2"></i>Limpiar
                                </button>
                                <button type="button" class="btn btn-success" onclick="exportarExcel()">
                                    <i class="fas fa-file-excel me-2"></i>Exportar Excel
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Estadísticas -->
                <div id="estadisticasContainer" style="display: none;">
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="card estadisticas-card">
                                <div class="card-body text-center">
                                    <div class="stat-icon">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <h4 class="mt-2" id="totalEstudiantes">0</h4>
                                    <p class="text-muted mb-0">Total Estudiantes</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card estadisticas-card">
                                <div class="card-body text-center">
                                    <div class="stat-icon text-success">
                                        <i class="fas fa-trophy"></i>
                                    </div>
                                    <h4 class="mt-2 text-success" id="promedio">0.0</h4>
                                    <p class="text-muted mb-0">Promedio General</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card estadisticas-card">
                                <div class="card-body text-center">
                                    <div class="stat-icon text-info">
                                        <i class="fas fa-chart-line"></i>
                                    </div>
                                    <h4 class="mt-2 text-info" id="notaMaxima">0.0</h4>
                                    <p class="text-muted mb-0">Nota Máxima</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card estadisticas-card">
                                <div class="card-body text-center">
                                    <div class="stat-icon text-warning">
                                        <i class="fas fa-chart-bar"></i>
                                    </div>
                                    <h4 class="mt-2 text-warning" id="aprobados">0</h4>
                                    <p class="text-muted mb-0">Aprobados</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Resultados -->
                <div id="resultadosContainer" style="display: none;">
                    <div class="card form-card">
                        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-list me-2"></i>Resultados de la Búsqueda
                            </h5>
                            <span class="badge bg-light text-dark" id="totalResultados">0 resultados</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="table-primary">
                                        <tr>
                                            <th>Fecha</th>
                                            <th>Curso</th>
                                            <th>Estudiante</th>
                                            <th>Código</th>
                                            <th>Evaluación</th>
                                            <th>Nota</th>
                                            <th>Peso</th>
                                            <th>Observaciones</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody id="resultadosTableBody">
                                        <!-- Los resultados se cargarán aquí dinámicamente -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal para Editar Nota -->
                <div class="modal fade" id="editarNotaModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title">
                                    <i class="fas fa-edit me-2"></i>Editar Nota
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <form id="editarNotaForm">
                                    <input type="hidden" id="edit_id_nota" name="id_nota">
                                    <div class="mb-3">
                                        <label class="form-label">Estudiante</label>
                                        <input type="text" class="form-control" id="edit_estudiante" readonly>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Evaluación</label>
                                        <input type="text" class="form-control" id="edit_evaluacion" readonly>
                                    </div>
                                    <div class="mb-3">
                                        <label for="edit_nota" class="form-label">Nota (0-20)</label>
                                        <input type="number" class="form-control" id="edit_nota" name="nota" 
                                               min="0" max="20" step="0.1" required>
                                    </div>
                                    <div class="mb-3">
                                        <label for="edit_observaciones" class="form-label">Observaciones</label>
                                        <textarea class="form-control" id="edit_observaciones" name="observaciones" rows="3"></textarea>
                                    </div>
                                </form>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="button" class="btn btn-primary" onclick="guardarEdicion()">
                                    <i class="fas fa-save me-2"></i>Guardar Cambios
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alertas -->
                <div id="alertContainer"></div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Datos de ejemplo para la demostración
        const notasEjemplo = [
            {
                id: 1,
                fecha: '2024-03-15',
                curso: 'Programación I',
                codigo_curso: 'PROG101',
                estudiante: 'Juan Pérez García',
                codigo_estudiante: 'EST001',
                evaluacion: 'Examen Parcial',
                nota: 18.5,
                peso: 30,
                observaciones: 'Excelente desempeño'
            },
            {
                id: 2,
                fecha: '2024-03-15',
                curso: 'Programación I',
                codigo_curso: 'PROG101',
                estudiante: 'María González López',
                codigo_estudiante: 'EST002',
                evaluacion: 'Examen Parcial',
                nota: 16.0,
                peso: 30,
                observaciones: 'Buen trabajo'
            },
            {
                id: 3,
                fecha: '2024-03-20',
                curso: 'Base de Datos',
                codigo_curso: 'BD201',
                estudiante: 'Carlos Rodríguez Silva',
                codigo_estudiante: 'EST003',
                evaluacion: 'Práctica',
                nota: 14.5,
                peso: 20,
                observaciones: 'Necesita mejorar'
            },
            {
                id: 4,
                fecha: '2024-03-22',
                curso: 'Programación I',
                codigo_curso: 'PROG101',
                estudiante: 'Ana Martínez Ruiz',
                codigo_estudiante: 'EST004',
                evaluacion: 'Tarea',
                nota: 19.0,
                peso: 15,
                observaciones: 'Trabajo sobresaliente'
            },
            {
                id: 5,
                fecha: '2024-03-25',
                curso: 'Base de Datos',
                codigo_curso: 'BD201',
                estudiante: 'Luis Fernández Castro',
                codigo_estudiante: 'EST005',
                evaluacion: 'Examen Final',
                nota: 12.5,
                peso: 40,
                observaciones: 'Debe estudiar más'
            }
        ];

        function buscarNotas() {
            const curso = document.getElementById('curso').value;
            const evaluacion = document.getElementById('evaluacion').value;
            const estudiante = document.getElementById('estudiante').value;
            const fechaDesde = document.getElementById('fecha_desde').value;
            const fechaHasta = document.getElementById('fecha_hasta').value;
            const notaMinima = document.getElementById('nota_minima').value;

            // Filtrar datos según los criterios
            let resultados = notasEjemplo.filter(nota => {
                let cumple = true;
                
                if (curso && nota.codigo_curso !== document.querySelector(`option[value="${curso}"]`).textContent.split(' - ')[0]) {
                    cumple = false;
                }
                
                if (evaluacion && nota.evaluacion.toLowerCase().replace(' ', '_') !== evaluacion) {
                    cumple = false;
                }
                
                if (estudiante && !nota.estudiante.toLowerCase().includes(estudiante.toLowerCase()) && 
                    !nota.codigo_estudiante.toLowerCase().includes(estudiante.toLowerCase())) {
                    cumple = false;
                }
                
                if (fechaDesde && nota.fecha < fechaDesde) {
                    cumple = false;
                }
                
                if (fechaHasta && nota.fecha > fechaHasta) {
                    cumple = false;
                }
                
                if (notaMinima && nota.nota < parseFloat(notaMinima)) {
                    cumple = false;
                }
                
                return cumple;
            });

            mostrarResultados(resultados);
            mostrarEstadisticas(resultados);
        }

        function mostrarResultados(resultados) {
            const tbody = document.getElementById('resultadosTableBody');
            const totalResultados = document.getElementById('totalResultados');
            
            tbody.innerHTML = '';
            totalResultados.textContent = `${resultados.length} resultados`;
            
            resultados.forEach(nota => {
                const claseNota = getClaseNota(nota.nota);
                const fila = `
                    <tr>
                        <td>${formatearFecha(nota.fecha)}</td>
                        <td><strong>${nota.curso}</strong><br><small class="text-muted">${nota.codigo_curso}</small></td>
                        <td><strong>${nota.estudiante}</strong><br><small class="text-muted">${nota.codigo_estudiante}</small></td>
                        <td><span class="badge bg-primary">${nota.codigo_estudiante}</span></td>
                        <td><span class="badge bg-secondary">${nota.evaluacion}</span></td>
                        <td><span class="badge ${claseNota}">${nota.nota.toFixed(1)}</span></td>
                        <td>${nota.peso}%</td>
                        <td>${nota.observaciones || '-'}</td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="editarNota(${nota.id})" 
                                    title="Editar nota">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="eliminarNota(${nota.id})" 
                                    title="Eliminar nota">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += fila;
            });
            
            document.getElementById('resultadosContainer').style.display = 'block';
        }

        function mostrarEstadisticas(resultados) {
            if (resultados.length === 0) {
                document.getElementById('estadisticasContainer').style.display = 'none';
                return;
            }

            const totalEstudiantes = new Set(resultados.map(r => r.codigo_estudiante)).size;
            const promedio = resultados.reduce((sum, r) => sum + r.nota, 0) / resultados.length;
            const notaMaxima = Math.max(...resultados.map(r => r.nota));
            const aprobados = resultados.filter(r => r.nota >= 13).length;

            document.getElementById('totalEstudiantes').textContent = totalEstudiantes;
            document.getElementById('promedio').textContent = promedio.toFixed(1);
            document.getElementById('notaMaxima').textContent = notaMaxima.toFixed(1);
            document.getElementById('aprobados').textContent = aprobados;

            document.getElementById('estadisticasContainer').style.display = 'block';
        }

        function getClaseNota(nota) {
            if (nota >= 18) return 'bg-success';
            if (nota >= 15) return 'bg-info';
            if (nota >= 13) return 'bg-warning';
            return 'bg-danger';
        }

        function formatearFecha(fecha) {
            const d = new Date(fecha);
            return d.toLocaleDateString('es-ES');
        }

        function editarNota(id) {
            const nota = notasEjemplo.find(n => n.id === id);
            if (!nota) return;

            document.getElementById('edit_id_nota').value = nota.id;
            document.getElementById('edit_estudiante').value = nota.estudiante;
            document.getElementById('edit_evaluacion').value = nota.evaluacion;
            document.getElementById('edit_nota').value = nota.nota;
            document.getElementById('edit_observaciones').value = nota.observaciones || '';

            new bootstrap.Modal(document.getElementById('editarNotaModal')).show();
        }

        function guardarEdicion() {
            const id = document.getElementById('edit_id_nota').value;
            const nuevaNota = document.getElementById('edit_nota').value;
            const observaciones = document.getElementById('edit_observaciones').value;

            // Aquí iría la lógica para guardar en la base de datos
            mostrarAlerta('Nota actualizada correctamente', 'success');
            bootstrap.Modal.getInstance(document.getElementById('editarNotaModal')).hide();
            
            // Recargar resultados
            buscarNotas();
        }

        function eliminarNota(id) {
            if (confirm('¿Está seguro de que desea eliminar esta nota?')) {
                // Aquí iría la lógica para eliminar de la base de datos
                mostrarAlerta('Nota eliminada correctamente', 'info');
                buscarNotas();
            }
        }

        function limpiarFiltros() {
            document.getElementById('filtrosForm').reset();
            document.getElementById('resultadosContainer').style.display = 'none';
            document.getElementById('estadisticasContainer').style.display = 'none';
        }

        function exportarExcel() {
            mostrarAlerta('Exportando datos a Excel...', 'info');
            // Aquí iría la lógica para exportar a Excel
        }

        function mostrarAlerta(mensaje, tipo) {
            const alertContainer = document.getElementById('alertContainer');
            const alerta = `
                <div class="alert alert-${tipo} alert-dismissible fade show mt-3" role="alert">
                    <i class="fas fa-info-circle me-2"></i>${mensaje}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            alertContainer.innerHTML = alerta;
            
            setTimeout(() => {
                const alert = alertContainer.querySelector('.alert');
                if (alert) {
                    alert.remove();
                }
            }, 5000);
        }

        // Cargar todas las notas al inicio
        window.onload = function() {
            buscarNotas();
        };
    </script>
</body>
</html>