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
    <title>Registrar Notas - Sistema Universitario</title>
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
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }

        .form-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-top: 4px solid var(--primary-color);
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
            background-color: rgba(0, 35, 102, 0.05);
        }

        .badge-custom {
            background-color: var(--secondary-color);
            color: var(--dark-color);
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
                                <i class="fas fa-edit me-3"></i>Registrar Notas
                            </h1>
                            <p class="mb-0 mt-2">Ingrese las calificaciones de los estudiantes</p>
                        </div>
                        <div class="col-auto">
                            <a href="nota.jsp" class="btn btn-outline-light">
                                <i class="fas fa-arrow-left me-2"></i>Volver
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Filtros -->
                <div class="card form-card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-filter me-2"></i>Seleccionar Curso y Evaluación
                        </h5>
                    </div>
                    <div class="card-body">
                        <form id="filtrosForm">
                            <div class="row">
                                <div class="col-md-6">
                                    <label for="curso" class="form-label">Curso</label>
                                    <select class="form-select" id="curso" name="curso" required>
                                        <option value="">Seleccione un curso</option>
                                        <% for (Map<String, Object> curso : cursos) { %>
                                            <option value="<%= curso.get("id_curso") %>">
                                                <%= curso.get("codigo") %> - <%= curso.get("nombre_curso") %>
                                            </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="evaluacion" class="form-label">Tipo de Evaluación</label>
                                    <select class="form-select" id="evaluacion" name="evaluacion" required>
                                        <option value="">Seleccione evaluación</option>
                                        <option value="examen_parcial">Examen Parcial</option>
                                        <option value="examen_final">Examen Final</option>
                                        <option value="practica">Práctica</option>
                                        <option value="tarea">Tarea</option>
                                        <option value="participacion">Participación</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-md-6">
                                    <label for="fecha_evaluacion" class="form-label">Fecha de Evaluación</label>
                                    <input type="date" class="form-control" id="fecha_evaluacion" name="fecha_evaluacion" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="peso" class="form-label">Peso (%)</label>
                                    <input type="number" class="form-control" id="peso" name="peso" min="1" max="100" placeholder="20" required>
                                </div>
                            </div>
                            <div class="mt-3">
                                <button type="button" class="btn btn-primary" onclick="cargarEstudiantes()">
                                    <i class="fas fa-search me-2"></i>Buscar Estudiantes
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Lista de Estudiantes para Calificar -->
                <div id="estudiantesContainer" style="display: none;">
                    <div class="card form-card">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">
                                <i class="fas fa-users me-2"></i>Estudiantes Matriculados
                            </h5>
                        </div>
                        <div class="card-body">
                            <form id="notasForm" action="procesar-notas.jsp" method="post">
                                <input type="hidden" id="curso_hidden" name="curso_id">
                                <input type="hidden" id="evaluacion_hidden" name="tipo_evaluacion">
                                <input type="hidden" id="fecha_hidden" name="fecha_evaluacion">
                                <input type="hidden" id="peso_hidden" name="peso">
                                
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="table-primary">
                                            <tr>
                                                <th>Código</th>
                                                <th>Estudiante</th>
                                                <th>Email</th>
                                                <th>Nota (0-20)</th>
                                                <th>Observaciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="estudiantesTableBody">
                                            <!-- Los estudiantes se cargarán aquí dinámicamente -->
                                        </tbody>
                                    </table>
                                </div>
                                
                                <div class="mt-4 text-center">
                                    <button type="submit" class="btn btn-success btn-lg me-3">
                                        <i class="fas fa-save me-2"></i>Guardar Notas
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary btn-lg" onclick="limpiarFormulario()">
                                        <i class="fas fa-eraser me-2"></i>Limpiar
                                    </button>
                                </div>
                            </form>
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
        function cargarEstudiantes() {
            const curso = document.getElementById('curso').value;
            const evaluacion = document.getElementById('evaluacion').value;
            const fecha = document.getElementById('fecha_evaluacion').value;
            const peso = document.getElementById('peso').value;
            
            if (!curso || !evaluacion || !fecha || !peso) {
                mostrarAlerta('Por favor complete todos los campos del filtro', 'warning');
                return;
            }
            
            // Guardar valores en campos ocultos
            document.getElementById('curso_hidden').value = curso;
            document.getElementById('evaluacion_hidden').value = evaluacion;
            document.getElementById('fecha_hidden').value = fecha;
            document.getElementById('peso_hidden').value = peso;
            
            // Simular carga de estudiantes (aquí deberías hacer una petición AJAX)
            const estudiantesEjemplo = [
                {codigo: 'EST001', nombre: 'Juan Pérez García', email: 'juan.perez@universidad.edu'},
                {codigo: 'EST002', nombre: 'María González López', email: 'maria.gonzalez@universidad.edu'},
                {codigo: 'EST003', nombre: 'Carlos Rodríguez Silva', email: 'carlos.rodriguez@universidad.edu'},
                {codigo: 'EST004', nombre: 'Ana Martínez Ruiz', email: 'ana.martinez@universidad.edu'},
                {codigo: 'EST005', nombre: 'Luis Fernández Castro', email: 'luis.fernandez@universidad.edu'}
            ];
            
            let tbody = document.getElementById('estudiantesTableBody');
            tbody.innerHTML = '';
            
            estudiantesEjemplo.forEach(estudiante => {
                let fila = `
                    <tr>
                        <td><span class="badge badge-custom">${estudiante.codigo}</span></td>
                        <td><strong>${estudiante.nombre}</strong></td>
                        <td>${estudiante.email}</td>
                        <td>
                            <input type="number" class="form-control" name="nota_${estudiante.codigo}" 
                                   min="0" max="20" step="0.1" placeholder="0.0" required>
                        </td>
                        <td>
                            <input type="text" class="form-control" name="obs_${estudiante.codigo}" 
                                   placeholder="Observaciones opcionales">
                        </td>
                    </tr>
                `;
                tbody.innerHTML += fila;
            });
            
            document.getElementById('estudiantesContainer').style.display = 'block';
            mostrarAlerta('Estudiantes cargados correctamente', 'success');
        }
        
        function limpiarFormulario() {
            document.getElementById('filtrosForm').reset();
            document.getElementById('estudiantesContainer').style.display = 'none';
            document.getElementById('alertContainer').innerHTML = '';
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
            
            // Auto-ocultar después de 5 segundos
            setTimeout(() => {
                const alert = alertContainer.querySelector('.alert');
                if (alert) {
                    alert.remove();
                }
            }, 5000);
        }
        
        // Validación del formulario
        document.getElementById('notasForm').addEventListener('submit', function(e) {
            const notas = document.querySelectorAll('input[name^="nota_"]');
            let valido = true;
            
            notas.forEach(nota => {
                const valor = parseFloat(nota.value);
                if (isNaN(valor) || valor < 0 || valor > 20) {
                    valido = false;
                    nota.classList.add('is-invalid');
                } else {
                    nota.classList.remove('is-invalid');
                }
            });
            
            if (!valido) {
                e.preventDefault();
                mostrarAlerta('Por favor ingrese notas válidas (0-20)', 'danger');
            }
        });
    </script>
</body>
</html>