<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>

<%
    Object idObj = session.getAttribute("id_profesor");
    int idProfesor = -1;
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";

    if (idObj != null) {
        idProfesor = Integer.parseInt(idObj.toString());

        // Conexión a la base de datos para obtener información del profesor
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sistema_universitario", "usuario", "contraseña");

            String sql = "SELECT nombre, email, facultad FROM profesores WHERE id_profesor = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idProfesor);
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
    List<Map<String, String>> cursos = new ArrayList<>();
    if (idProfesor != -1) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sistema_universitario", "usuario", "contraseña");

            String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo FROM cursos c " +
                         "INNER JOIN profesor_curso pc ON c.id_curso = pc.id_curso " +
                         "WHERE pc.id_profesor = ? ORDER BY c.nombre_curso";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idProfesor);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> curso = new HashMap<>();
                curso.put("id", rs.getString("id_curso"));
                curso.put("nombre", rs.getString("nombre_curso"));
                curso.put("codigo", rs.getString("codigo"));
                cursos.add(curso);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // Obtener notas si se ha seleccionado un curso
    String cursoSeleccionado = request.getParameter("curso");
    List<Map<String, String>> notas = new ArrayList<>();
    
    if (cursoSeleccionado != null && !cursoSeleccionado.isEmpty()) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sistema_universitario", "usuario", "contraseña");

            String sql = "SELECT e.id_estudiante, e.nombre, e.apellido, n.nota, n.tipo_evaluacion, n.fecha_registro " +
                         "FROM notas n " +
                         "INNER JOIN estudiantes e ON n.id_estudiante = e.id_estudiante " +
                         "WHERE n.id_curso = ? AND n.id_profesor = ? " +
                         "ORDER BY e.apellido, e.nombre, n.fecha_registro DESC";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(cursoSeleccionado));
            ps.setInt(2, idProfesor);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> nota = new HashMap<>();
                nota.put("idEstudiante", rs.getString("id_estudiante"));
                nota.put("nombre", rs.getString("nombre") + " " + rs.getString("apellido"));
                nota.put("nota", rs.getString("nota"));
                nota.put("tipoEvaluacion", rs.getString("tipo_evaluacion"));
                nota.put("fecha", rs.getString("fecha_registro"));
                notas.add(nota);
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
    <title>Sistema Universitario - Consulta de Notas</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Estilos personalizados -->
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
            background-color: #f8f9fa;
        }
        
        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 0;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--secondary-color);
        }
        
        .user-name {
            font-weight: bold;
            color: var(--secondary-color);
        }
        
        .sidebar {
            background-color: var(--primary-color);
            color: white;
            min-height: calc(100vh - 56px);
        }
        
        .sidebar .nav-link {
            color: white;
            padding: 0.75rem 1.5rem;
            border-left: 4px solid transparent;
        }
        
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 4px solid var(--secondary-color);
        }
        
        .card-header {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: #001a4d;
            border-color: #001a4d;
        }
        
        .btn-outline-primary {
            color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .table th {
            background-color: var(--primary-color);
            color: white;
        }
        
        .badge-evaluacion {
            background-color: var(--accent-color);
            color: white;
        }
        
        .nota-alta {
            color: #28a745;
            font-weight: bold;
        }
        
        .nota-media {
            color: #ffc107;
            font-weight: bold;
        }
        
        .nota-baja {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div class="logo">Sistema Universitario</div>
                <div class="text-end">
                    <div class="user-name"><%= nombreProfesor %></div>
                    <div><%= emailProfesor %></div>
                    <div><%= facultadProfesor %></div>
                    <form action="logout.jsp" method="post" class="mt-2">
                        <button type="submit" class="btn btn-sm btn-danger">Cerrar sesión</button>
                    </form>
                </div>
            </div>
        </div>
    </header>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="home_profesor.jsp">
                                <i class="fas fa-home me-2"></i>Inicio
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="facultad_profesor.jsp">
                                <i class="fas fa-building me-2"></i>Facultades
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="cursos_profesor.jsp">
                                <i class="fas fa-book me-2"></i>Cursos
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="salones.jsp">
                                <i class="fas fa-door-open me-2"></i>Salones
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="horarios.jsp">
                                <i class="fas fa-calendar-alt me-2"></i>Horarios
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="asistencia.jsp">
                                <i class="fas fa-clipboard-check me-2"></i>Asistencia
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="mensaje.jsp">
                                <i class="fas fa-envelope me-2"></i>Mensajería
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="nota.jsp">
                                <i class="fas fa-check-circle me-2"></i>Notas
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-check-circle me-2"></i>Consulta de Notas</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group me-2">
                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="window.print()">
                                <i class="fas fa-print me-1"></i>Imprimir
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#exportModal">
                                <i class="fas fa-file-export me-1"></i>Exportar
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Filtros -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="fas fa-filter me-2"></i>Filtros de Búsqueda
                    </div>
                    <div class="card-body">
                        <form method="get" action="consultas_notas_profesor.jsp">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="curso" class="form-label">Seleccionar Curso</label>
                                    <select class="form-select" id="curso" name="curso" required>
                                        <option value="">-- Seleccione un curso --</option>
                                        <% for (Map<String, String> curso : cursos) { %>
                                            <option value="<%= curso.get("id") %>" <%= cursoSeleccionado != null && cursoSeleccionado.equals(curso.get("id")) ? "selected" : "" %>>
                                                <%= curso.get("codigo") %> - <%= curso.get("nombre") %>
                                            </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="tipoEvaluacion" class="form-label">Tipo de Evaluación</label>
                                    <select class="form-select" id="tipoEvaluacion" name="tipoEvaluacion">
                                        <option value="">Todos</option>
                                        <option value="Parcial">Parcial</option>
                                        <option value="Final">Final</option>
                                        <option value="Trabajo">Trabajo</option>
                                        <option value="Proyecto">Proyecto</option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-search me-1"></i>Buscar
                                    </button>
                                    <button type="reset" class="btn btn-outline-secondary">
                                        <i class="fas fa-undo me-1"></i>Limpiar
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Resultados -->
                <% if (cursoSeleccionado != null && !cursoSeleccionado.isEmpty()) { %>
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>
                                <i class="fas fa-table me-2"></i>Notas Registradas
                            </div>
                            <div>
                                <button class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#agregarNotaModal">
                                    <i class="fas fa-plus me-1"></i>Agregar Nota
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <% if (notas.isEmpty()) { %>
                                <div class="alert alert-info">
                                    No se encontraron notas registradas para este curso.
                                </div>
                            <% } else { %>
                                <div class="table-responsive">
                                    <table class="table table-striped table-hover table-bordered">
                                        <thead>
                                            <tr>
                                                <th>Estudiante</th>
                                                <th>Tipo Evaluación</th>
                                                <th>Nota</th>
                                                <th>Fecha Registro</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Map<String, String> nota : notas) { 
                                                double valorNota = Double.parseDouble(nota.get("nota"));
                                                String claseNota = "";
                                                if (valorNota >= 14) {
                                                    claseNota = "nota-alta";
                                                } else if (valorNota >= 10) {
                                                    claseNota = "nota-media";
                                                } else {
                                                    claseNota = "nota-baja";
                                                }
                                            %>
                                                <tr>
                                                    <td><%= nota.get("nombre") %></td>
                                                    <td>
                                                        <span class="badge badge-evaluacion rounded-pill bg-primary">
                                                            <%= nota.get("tipoEvaluacion") %>
                                                        </span>
                                                    </td>
                                                    <td class="<%= claseNota %>"><%= nota.get("nota") %></td>
                                                    <td><%= nota.get("fecha") %></td>
                                                    <td>
                                                        <button class="btn btn-sm btn-outline-primary" 
                                                                data-bs-toggle="tooltip" 
                                                                title="Editar nota"
                                                                onclick="editarNota('<%= nota.get("idEstudiante") %>', '<%= nota.get("tipoEvaluacion") %>')">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-outline-danger" 
                                                                data-bs-toggle="tooltip" 
                                                                title="Eliminar nota"
                                                                onclick="confirmarEliminar('<%= nota.get("idEstudiante") %>', '<%= nota.get("tipoEvaluacion") %>', '<%= nota.get("nombre") %>')">
                                                            <i class="fas fa-trash-alt"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <!-- Estadísticas -->
                                <div class="row mt-4">
                                    <div class="col-md-4">
                                        <div class="card text-white bg-success mb-3">
                                            <div class="card-body">
                                                <h5 class="card-title">Promedio General</h5>
                                                <p class="card-text display-6">14.5</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card text-white bg-warning mb-3">
                                            <div class="card-body">
                                                <h5 class="card-title">Nota Más Alta</h5>
                                                <p class="card-text display-6">19.0</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card text-white bg-danger mb-3">
                                            <div class="card-body">
                                                <h5 class="card-title">Nota Más Baja</h5>
                                                <p class="card-text display-6">08.5</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </main>
        </div>
    </div>

    <!-- Modal Exportar -->
    <div class="modal fade" id="exportModal" tabindex="-1" aria-labelledby="exportModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exportModalLabel">Exportar Datos</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="exportForm">
                        <div class="mb-3">
                            <label for="exportFormat" class="form-label">Formato</label>
                            <select class="form-select" id="exportFormat">
                                <option value="excel">Excel (.xlsx)</option>
                                <option value="pdf">PDF (.pdf)</option>
                                <option value="csv">CSV (.csv)</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="exportRange" class="form-label">Rango</label>
                            <select class="form-select" id="exportRange">
                                <option value="all">Todos los registros</option>
                                <option value="current">Página actual</option>
                                <option value="selected">Seleccionados</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-primary" onclick="exportarDatos()">Exportar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Agregar Nota -->
    <div class="modal fade" id="agregarNotaModal" tabindex="-1" aria-labelledby="agregarNotaModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="agregarNotaModalLabel">Agregar Nueva Nota</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="formAgregarNota">
                        <input type="hidden" name="idCurso" value="<%= cursoSeleccionado %>">
                        <div class="mb-3">
                            <label for="estudiante" class="form-label">Estudiante</label>
                            <select class="form-select" id="estudiante" name="estudiante" required>
                                <option value="">Seleccione un estudiante</option>
                                <!-- Opciones se llenarán dinámicamente -->
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="tipoNota" class="form-label">Tipo de Evaluación</label>
                            <select class="form-select" id="tipoNota" name="tipoNota" required>
                                <option value="">Seleccione un tipo</option>
                                <option value="Parcial">Parcial</option>
                                <option value="Final">Final</option>
                                <option value="Trabajo">Trabajo</option>
                                <option value="Proyecto">Proyecto</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="valorNota" class="form-label">Nota (0-20)</label>
                            <input type="number" class="form-control" id="valorNota" name="valorNota" 
                                   min="0" max="20" step="0.1" required>
                        </div>
                        <div class="mb-3">
                            <label for="fechaNota" class="form-label">Fecha</label>
                            <input type="date" class="form-control" id="fechaNota" name="fechaNota" required>
                        </div>
                        <div class="mb-3">
                            <label for="comentario" class="form-label">Comentario (Opcional)</label>
                            <textarea class="form-control" id="comentario" name="comentario" rows="2"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-primary" onclick="guardarNota()">Guardar Nota</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Confirmación Eliminar -->
    <div class="modal fade" id="confirmarEliminarModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirmar Eliminación</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p id="mensajeEliminar">¿Está seguro que desea eliminar esta nota?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-danger" id="btnConfirmarEliminar">Eliminar</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS y dependencias -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Activar tooltips
        document.addEventListener('DOMContentLoaded', function() {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
            
            // Establecer fecha actual por defecto
            document.getElementById('fechaNota').valueAsDate = new Date();
        });
        
        // Función para confirmar eliminación
        function confirmarEliminar(idEstudiante, tipoEvaluacion, nombreEstudiante) {
            document.getElementById('mensajeEliminar').innerHTML = 
                `¿Está seguro que desea eliminar la nota de <strong>${nombreEstudiante}</strong> (${tipoEvaluacion})?`;
            
            document.getElementById('btnConfirmarEliminar').onclick = function() {
                eliminarNota(idEstudiante, tipoEvaluacion);
            };
            
            var modal = new bootstrap.Modal(document.getElementById('confirmarEliminarModal'));
            modal.show();
        }
        
        // Funciones para operaciones con notas (simuladas)
        function editarNota(idEstudiante, tipoEvaluacion) {
            alert(`Editar nota del estudiante ID: ${idEstudiante} - ${tipoEvaluacion}`);
            // Aquí iría la lógica para cargar los datos en un modal de edición
        }
        
        function eliminarNota(idEstudiante, tipoEvaluacion) {
            alert(`Nota eliminada del estudiante ID: ${idEstudiante} - ${tipoEvaluacion}`);
            // Aquí iría la lógica AJAX para eliminar la nota
            bootstrap.Modal.getInstance(document.getElementById('confirmarEliminarModal')).hide();
            // Recargar la página o actualizar la tabla
            location.reload();
        }
        
        function guardarNota() {
            alert('Nota guardada exitosamente');
            // Aquí iría la lógica AJAX para guardar la nueva nota
            bootstrap.Modal.getInstance(document.getElementById('agregarNotaModal')).hide();
            // Recargar la página o actualizar la tabla
            location.reload();
        }
        
        function exportarDatos() {
            var format = document.getElementById('exportFormat').value;
            alert(`Exportando datos en formato ${format}`);
            bootstrap.Modal.getInstance(document.getElementById('exportModal')).hide();
        }
        
        // Cargar estudiantes cuando se abre el modal de agregar nota
        document.getElementById('agregarNotaModal').addEventListener('show.bs.modal', function() {
            // Simular carga de estudiantes desde AJAX
            var selectEstudiante = document.getElementById('estudiante');
            selectEstudiante.innerHTML = '<option value="">Seleccione un estudiante</option>';
            
            // Datos de ejemplo - en una implementación real esto vendría de una consulta AJAX
            var estudiantes = [
                {id: 1, nombre: "Juan Pérez"},
                {id: 2, nombre: "María García"},
                {id: 3, nombre: "Carlos López"},
                {id: 4, nombre: "Ana Martínez"}
            ];
            
            estudiantes.forEach(function(estudiante) {
                var option = document.createElement('option');
                option.value = estudiante.id;
                option.textContent = estudiante.nombre;
                selectEstudiante.appendChild(option);
            });
        });
    </script>
</body>
</html>