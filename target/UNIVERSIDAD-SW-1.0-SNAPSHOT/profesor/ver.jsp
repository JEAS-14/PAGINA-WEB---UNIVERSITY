<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Profesor, pe.edu.dao.ProfesorDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Ver Profesor</title>        
    </head>
    
    <%-- Instancia de ProfesorDao para interactuar con la base de datos --%>
    <jsp:useBean id="profesorDao" class="pe.edu.dao.ProfesorDao" scope="session"></jsp:useBean>
    
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                <div class="col py-3">    
                    <%-- Instancia de Profesor para almacenar los datos del profesor a ver --%>
                    <jsp:useBean id="profesor" class="pe.edu.entity.Profesor" scope="request"></jsp:useBean>
                    <%
                        String mensaje = "";
                        String tipoMensaje = "";

                        try {
                            // Obtener el ID del profesor desde la URL
                            String id = request.getParameter("id");
                            
                            // Si el ID no es nulo, cargar los datos del profesor de la base de datos
                            if (id != null && !id.isEmpty()) {
                                Profesor profesorExistente = profesorDao.leer(id);
                                if (profesorExistente != null) {
                                    // Establecer las propiedades del bean 'profesor' con los datos existentes
                                    profesor.setIdProfesor(profesorExistente.getIdProfesor());
                                    profesor.setNombre(profesorExistente.getNombre());
                                    profesor.setApellidoPaterno(profesorExistente.getApellidoPaterno());
                                    profesor.setApellidoMaterno(profesorExistente.getApellidoMaterno());
                                    profesor.setEmail(profesorExistente.getEmail());
                                    profesor.setIdFacultad(profesorExistente.getIdFacultad());
                                    profesor.setRol(profesorExistente.getRol());
                                    profesor.setPassword(profesorExistente.getPassword());
                                } else {
                                    mensaje = "No se encontró el profesor con ID: " + id + ".";
                                    tipoMensaje = "danger";
                                }
                            } else {
                                mensaje = "ID de profesor no proporcionado para ver detalles.";
                                tipoMensaje = "warning";
                            }
                        } catch (Exception e) {
                            mensaje = "Error al cargar los datos del profesor: " + e.getMessage();
                            tipoMensaje = "danger";
                            e.printStackTrace(); // Para depuración
                        }
                    %>
                    
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-md-8 col-lg-6">
                                <%-- Mostrar mensajes de error o información --%>
                                <% if (!mensaje.isEmpty()) { %>
                                    <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                                        <%= mensaje %>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                <% } %>

                                <% if (profesor.getIdProfesor() != 0) { // Si el ID es 0, asumimos que no se encontró %>
                                    <div class="card shadow">
                                        <div class="card-header bg-info text-white">
                                            <h4 class="mb-0">
                                                <i class="fas fa-eye me-2"></i>Detalles del Profesor
                                            </h4>
                                        </div>
                                        <div class="card-body">
                                            <%-- En el caso de "ver", no hay formulario POST. Se muestra solo información. --%>
                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-fingerprint me-1"></i>ID Profesor:</label>
                                                <p class="form-control-plaintext"><%= profesor.getIdProfesor() %></p>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-user me-1"></i>Nombre:</label>
                                                <p class="form-control-plaintext"><%= profesor.getNombre() %></p>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-user-tag me-1"></i>Apellido Paterno:</label>
                                                <p class="form-control-plaintext"><%= profesor.getApellidoPaterno() %></p>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-user-tag me-1"></i>Apellido Materno:</label>
                                                <p class="form-control-plaintext"><%= profesor.getApellidoMaterno() %></p>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-envelope me-1"></i>Email:</label>
                                                <p class="form-control-plaintext"><%= profesor.getEmail() %></p>
                                            </div>
                                            
                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-building me-1"></i>ID Facultad:</label>
                                                <p class="form-control-plaintext"><%= profesor.getIdFacultad() %></p>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-user-shield me-1"></i>Rol:</label>
                                                <p class="form-control-plaintext"><%= profesor.getRol() %></p>
                                            </div>
                                            
                                            <%-- No mostrar el password aquí por seguridad --%>
                                            <%-- <div class="mb-3">
                                                <label class="form-label fw-bold"><i class="fas fa-key me-1"></i>Password:</label>
                                                <p class="form-control-plaintext"><%= profesor.getPassword() %></p>
                                            </div> --%>
                                            
                                            <div class="d-grid gap-2">
                                                <a href="listado.jsp" class="btn btn-primary d-flex align-items-center justify-content-center">
                                                    <i class="fas fa-arrow-alt-circle-left me-2"></i>Volver al Listado
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <div class="alert alert-info mt-3" role="alert">
                                        No hay datos de profesor para mostrar. Por favor, asegúrese de que el ID sea válido.
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>

<%-- Scripts (no necesarios en esta página, ya incluidos en referencias.jsp) --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
<script type="text/javascript">
    let table = new DataTable('#myTable');
</script>