<%-- === ARCHIVO: obtener_mis_alumnos.jsp === --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    int idSalon = Integer.parseInt(request.getParameter("id_salon"));
    // En tu sistema real, verifica que el salón pertenezca al profesor logueado
    int idProfesorLogueado = 1; // Obtener de la sesión
%>

<div class="row mb-3">
    <div class="col-md-6">
        <div class="input-group">
            <span class="input-group-text"><i class="fas fa-search"></i></span>
            <input type="text" class="form-control" id="buscarAlumno" placeholder="Buscar estudiante..." onkeyup="filtrarAlumnos()">
        </div>
    </div>
    <div class="col-md-6">
        <select class="form-select" id="filtroEstadoAlumno" onchange="filtrarAlumnos()">
            <option value="">Todos los estados</option>
            <option value="activo">Activos</option>
            <option value="inactivo">Inactivos</option>
            <option value="retirado">Retirados</option>
        </select>
    </div>
</div>

<%
    try {
        String url = "jdbc:mysql://localhost:3306/bduni";
        String username = "root";
        String password = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, username, password);
        
        // Verificar que el salón pertenece al profesor
        String sqlVerificar = "SELECT COUNT(*) as count FROM salones WHERE id_salon = ? AND id_profesor = ?";
        PreparedStatement pstmtVerif = conn.prepareStatement(sqlVerificar);
        pstmtVerif.setInt(1, idSalon);
        pstmtVerif.setInt(2, idProfesorLogueado);
        ResultSet rsVerif = pstmtVerif.executeQuery();
        
        boolean tienePermiso = false;
        if(rsVerif.next() && rsVerif.getInt("count") > 0) {
            tienePermiso = true;
        }
        rsVerif.close();
        pstmtVerif.close();
        
        if(!tienePermiso) {
%>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle"></i> No tienes permisos para ver los estudiantes de este salón.
            </div>
<%
        } else {
            // Obtener información del salón
            String sqlSalon = "SELECT s.nombre_salon, c.nombre_curso, c.codigo_curso, s.capacidad " +
                "FROM salones s INNER JOIN cursos c ON s.id_curso = c.id_curso WHERE s.id_salon = ?";
            PreparedStatement pstmtSalon = conn.prepareStatement(sqlSalon);
            pstmtSalon.setInt(1, idSalon);
            ResultSet rsSalon = pstmtSalon.executeQuery();
            
            String nombreSalon = "";
            String nombreCurso = "";
            String codigoCurso = "";
            int capacidad = 0;
            
            if(rsSalon.next()) {
                nombreSalon = rsSalon.getString("nombre_salon");
                nombreCurso = rsSalon.getString("nombre_curso");
                codigoCurso = rsSalon.getString("codigo_curso");
                capacidad = rsSalon.getInt("capacidad");
            }
            rsSalon.close();
            pstmtSalon.close();
%>

<div class="alert alert-info mb-3">
    <h6 class="mb-1"><i class="fas fa-info-circle"></i> Información del Salón</h6>
    <strong>Salón:</strong> <%= nombreSalon %> | 
    <strong>Curso:</strong> <%= codigoCurso %> - <%= nombreCurso %> | 
    <strong>Capacidad:</strong> <%= capacidad %> estudiantes
</div>

<div class="table-responsive">
    <table class="table table-hover align-middle" id="tablaAlumnos">
        <thead class="table-success">
            <tr>
                <th><i class="fas fa-hashtag"></i></th>
                <th><i class="fas fa-user"></i> Estudiante</th>
                <th><i class="fas fa-id-card"></i> Código</th>
                <th><i class="fas fa-envelope"></i> Email</th>
                <th><i class="fas fa-calendar"></i> Fecha Inscripción</th>
                <th><i class="fas fa-info-circle"></i> Estado</th>
                <th><i class="fas fa-sticky-note"></i> Observaciones</th>
                <th><i class="fas fa-cogs"></i> Acciones</th>
            </tr>
        </thead>
        <tbody>
            <%
                // Obtener alumnos inscritos en el salón
                String sqlAlumnos = "SELECT i.id_inscripcion, i.fecha_inscripcion, i.estado, i.observaciones, " +
                    "a.id_alumno, a.nombre, a.apellido_paterno, a.apellido_materno, a.codigo_alumno, a.email, a.telefono " +
                    "FROM inscripciones i " +
                    "INNER JOIN alumnos a ON i.id_alumno = a.id_alumno " +
                    "WHERE i.id_salon = ? " +
                    "ORDER BY a.apellido_paterno, a.apellido_materno, a.nombre";
                
                PreparedStatement pstmtAlumnos = conn.prepareStatement(sqlAlumnos);
                pstmtAlumnos.setInt(1, idSalon);
                ResultSet rsAlumnos = pstmtAlumnos.executeQuery();
                
                int contador = 1;
                boolean hayAlumnos = false;
                
                while(rsAlumnos.next()) {
                    hayAlumnos = true;
                    String nombreCompleto = rsAlumnos.getString("nombre") + " " + 
                        rsAlumnos.getString("apellido_paterno") + " " + 
                        (rsAlumnos.getString("apellido_materno") != null ? rsAlumnos.getString("apellido_materno") : "");
                    
                    String estadoAlumno = rsAlumnos.getString("estado");
                    String badgeClass = "";
                    String iconoEstado = "";
                    
                    switch(estadoAlumno) {
                        case "activo":
                            badgeClass = "bg-success";
                            iconoEstado = "fas fa-check-circle";
                            break;
                        case "inactivo":
                            badgeClass = "bg-warning";
                            iconoEstado = "fas fa-pause-circle";
                            break;
                        case "retirado":
                            badgeClass = "bg-danger";
                            iconoEstado = "fas fa-times-circle";
                            break;
                        case "culminado":
                            badgeClass = "bg-primary";
                            iconoEstado = "fas fa-graduation-cap";
                            break;
                        default:
                            badgeClass = "bg-secondary";
                            iconoEstado = "fas fa-question-circle";
                    }
                    
                    SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
                    String fechaInscripcion = formatter.format(rsAlumnos.getTimestamp("fecha_inscripcion"));
            %>
                    <tr class="fila-alumno" data-nombre="<%= nombreCompleto.toLowerCase() %>" data-estado="<%= estadoAlumno %>">
                        <td class="fw-bold text-muted"><%= contador++ %></td>
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="avatar-circle bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-2" 
                                     style="width: 35px; height: 35px; font-size: 14px;">
                                    <%= rsAlumnos.getString("nombre").charAt(0) %><%= rsAlumnos.getString("apellido_paterno").charAt(0) %>
                                </div>
                                <div>
                                    <div class="fw-semibold"><%= nombreCompleto %></div>
                                    <% if(rsAlumnos.getString("telefono") != null && !rsAlumnos.getString("telefono").isEmpty()) { %>
                                        <small class="text-muted"><i class="fas fa-phone"></i> <%= rsAlumnos.getString("telefono") %></small>
                                    <% } %>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge bg-secondary">
                                <%= rsAlumnos.getString("codigo_alumno") %>
                            </span>
                        </td>
                        <td>
                            <% if(rsAlumnos.getString("email") != null && !rsAlumnos.getString("email").isEmpty()) { %>
                                <a href="mailto:<%= rsAlumnos.getString("email") %>" class="text-decoration-none">
                                    <i class="fas fa-envelope text-primary"></i> <%= rsAlumnos.getString("email") %>
                                </a>
                            <% } else { %>
                                <span class="text-muted">No disponible</span>
                            <% } %>
                        </td>
                        <td>
                            <small class="text-muted">
                                <i class="fas fa-calendar-plus"></i> <%= fechaInscripcion %>
                            </small>
                        </td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <i class="<%= iconoEstado %>"></i> <%= estadoAlumno.toUpperCase() %>
                            </span>
                        </td>
                        <td>
                            <% if(rsAlumnos.getString("observaciones") != null && !rsAlumnos.getString("observaciones").isEmpty()) { %>
                                <button class="btn btn-sm btn-outline-info" 
                                        data-bs-toggle="tooltip" 
                                        title="<%= rsAlumnos.getString("observaciones") %>">
                                    <i class="fas fa-sticky-note"></i>
                                </button>
                            <% } else { %>
                                <span class="text-muted">-</span>
                            <% } %>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm" role="group">
                                <button class="btn btn-outline-primary" 
                                        onclick="verPerfilAlumno(<%= rsAlumnos.getInt("id_alumno") %>)"
                                        data-bs-toggle="tooltip" title="Ver perfil">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <% if(estadoAlumno.equals("activo")) { %>
                                <button class="btn btn-outline-success" 
                                        onclick="gestionarNotasAlumno(<%= rsAlumnos.getInt("id_alumno") %>, <%= idSalon %>)"
                                        data-bs-toggle="tooltip" title="Gestionar notas">
                                    <i class="fas fa-clipboard-list"></i>
                                </button>
                                <% } %>
                                <button class="btn btn-outline-warning" 
                                        onclick="editarObservacion(<%= rsAlumnos.getInt("id_inscripcion") %>)"
                                        data-bs-toggle="tooltip" title="Editar observación">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
            <%
                }
                
                if(!hayAlumnos) {
            %>
                    <tr>
                        <td colspan="8" class="text-center py-4">
                            <div class="text-muted">
                                <i class="fas fa-users fa-3x mb-3"></i>
                                <h5>No hay estudiantes inscritos</h5>
                                <p>Este salón aún no tiene estudiantes inscritos.</p>
                            </div>
                        </td>
                    </tr>
            <%
                }
                
                rsAlumnos.close();
                pstmtAlumnos.close();
            %>
        </tbody>
    </table>
</div>

<% if(hayAlumnos) { %>
<div class="row mt-3">
    <div class="col-md-6">
        <div class="card bg-light">
            <div class="card-body text-center">
                <h6 class="card-title">Resumen de Inscripciones</h6>
                <%
                    // Contar por estados
                    String sqlEstados = "SELECT estado, COUNT(*) as cantidad FROM inscripciones WHERE id_salon = ? GROUP BY estado";
                    PreparedStatement pstmtEstados = conn.prepareStatement(sqlEstados);
                    pstmtEstados.setInt(1, idSalon);
                    ResultSet rsEstados = pstmtEstados.executeQuery();
                    
                    while(rsEstados.next()) {
                        String estado = rsEstados.getString("estado");
                        int cantidad = rsEstados.getInt("cantidad");
                        String colorBadge = "";
                        
                        switch(estado) {
                            case "activo": colorBadge = "bg-success"; break;
                            case "inactivo": colorBadge = "bg-warning"; break;
                            case "retirado": colorBadge = "bg-danger"; break;
                            case "culminado": colorBadge = "bg-primary"; break;
                            default: colorBadge = "bg-secondary";
                        }
                %>
                        <span class="badge <%= colorBadge %> me-2">
                            <%= estado.toUpperCase() %>: <%= cantidad %>
                        </span>
                <%
                    }
                    rsEstados.close();
                    pstmtEstados.close();
                %>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card bg-light">
            <div class="card-body text-center">
                <h6 class="card-title">Acciones Rápidas</h6>
                <button class="btn btn-sm btn-outline-primary me-2" onclick="exportarListaAlumnos(<%= idSalon %>)">
                    <i class="fas fa-download"></i> Exportar Lista
                </button>
                <button class="btn btn-sm btn-outline-success" onclick="enviarNotificacion(<%= idSalon %>)">
                    <i class="fas fa-bell"></i> Notificar Todos
                </button>
            </div>
        </div>
    </div>
</div>
<% } %>

<%
        }
        conn.close();
    } catch(Exception e) {
%>
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i> Error al cargar los estudiantes: <%= e.getMessage() %>
        </div>
<%
    }
%>

<script>
function filtrarAlumnos() {
    const busqueda = document.getElementById('buscarAlumno').value.toLowerCase();
    const estadoFiltro = document.getElementById('filtroEstadoAlumno').value.toLowerCase();
    const filas = document.querySelectorAll('.fila-alumno');
    
    filas.forEach(fila => {
        const nombre = fila.getAttribute('data-nombre');
        const estado = fila.getAttribute('data-estado');
        
        let mostrar = true;
        
        if(busqueda && !nombre.includes(busqueda)) {
            mostrar = false;
        }
        
        if(estadoFiltro && estado !== estadoFiltro) {
            mostrar = false;
        }
        
        fila.style.display = mostrar ? '' : 'none';
    });
}

function verPerfilAlumno(idAlumno) {
    // Implementar ventana modal con perfil del alumno
    alert('Ver perfil del alumno ID: ' + idAlumno);
}

function gestionarNotasAlumno(idAlumno, idSalon) {
    // Redirigir a gestión de notas
    window.open('gestionar_notas_alumno.jsp?id_alumno=' + idAlumno + '&id_salon=' + idSalon, '_blank');
}

function editarObservacion(idInscripcion) {
    const nuevaObservacion = prompt('Ingrese la nueva observación:');
    if(nuevaObservacion !== null) {
        // Implementar actualización de observación
        fetch('actualizar_observacion.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'id_inscripcion=' + idInscripcion + '&observacion=' + encodeURIComponent(nuevaObservacion)
        })
        .then(response => response.text())
        .then(data => {
            alert('Observación actualizada correctamente');
            location.reload();
        })
        .catch(error => {
            alert('Error al actualizar la observación');
        });
    }
}

function exportarListaAlumnos(idSalon) {
    window.open('exportar_alumnos.jsp?id_salon=' + idSalon, '_blank');
}

function enviarNotificacion(idSalon) {
    const mensaje = prompt('Ingrese el mensaje a enviar a todos los estudiantes:');
    if(mensaje !== null && mensaje.trim() !== '') {
        // Implementar envío de notificaciones
        alert('Funcionalidad de notificaciones en desarrollo');
    }
}

// Inicializar tooltips
document.addEventListener('DOMContentLoaded', function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});
</script>