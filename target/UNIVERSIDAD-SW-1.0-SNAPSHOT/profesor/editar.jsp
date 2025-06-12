<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Profesor, pe.edu.dao.ProfesorDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Editar Profesor</title>        
    </head>
    
    <%-- Instancia de ProfesorDao para interactuar con la base de datos --%>
    <jsp:useBean id="profesorDao" class="pe.edu.dao.ProfesorDao" scope="session"></jsp:useBean>
    
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                    <%-- CAMBIO CLAVE: Usar scope="session" en lugar de "request" --%>
                    <jsp:useBean id="profesor" class="pe.edu.entity.Profesor" scope="session"></jsp:useBean>
                    <%
                        String id = request.getParameter("id");
                    %>
                    <%-- CAMBIO CLAVE: Usar jsp:scriptlet como en el formulario de usuario que funciona --%>
                    <jsp:scriptlet>
                        if (id != null && !id.isEmpty()) {
                            Profesor profesorExistente = profesorDao.leer(id);
                            if (profesorExistente != null) {
                                profesor.setIdProfesor(profesorExistente.getIdProfesor());
                                profesor.setNombre(profesorExistente.getNombre());
                                profesor.setApellidoPaterno(profesorExistente.getApellidoPaterno());
                                profesor.setApellidoMaterno(profesorExistente.getApellidoMaterno());
                                profesor.setEmail(profesorExistente.getEmail());
                                profesor.setIdFacultad(profesorExistente.getIdFacultad());
                                profesor.setRol(profesorExistente.getRol());
                                profesor.setPassword(profesorExistente.getPassword());
                            }
                        }
                    </jsp:scriptlet>
                    
                    <center>
                        <div class="card card_login shadow">
                            <div class="card-header card_titulo bg-warning text-white">
                                <h2 class="mb-0">
                                    <i class="fas fa-edit me-2"></i>Editar Profesor
                                </h2>
                            </div>
                            <div class="card-body">
                                <%-- El action del formulario apunta a ProfesorController --%>
                                <form action="../ProfesorController" method="post">        
                                    <input type="hidden" name="accion" value="editar">
                                    
                                    <%-- Campo ID Profesor (oculto para enviar el ID al controlador) --%>
                                    <input type="hidden" name="idProfesor" 
                                           value="<jsp:getProperty name="profesor" property="idProfesor"></jsp:getProperty>">
                                                                            
                                    <%-- Campo ID Profesor (solo lectura para visualización) --%>
                                    <div class="mb-3 text-start">
                                        <label for="displayIdProfesor" class="form-label"><i class="fas fa-fingerprint me-1"></i>ID Profesor:</label>
                                        <input type="text" id="displayIdProfesor" class="form-control" readonly="true" 
                                               value="<jsp:getProperty name="profesor" property="idProfesor"></jsp:getProperty>">
                                    </div>

                                    <%-- Campo Nombre --%>
                                    <div class="mb-3 text-start">
                                        <label for="nombre" class="form-label"><i class="fas fa-user me-1"></i>Nombre:</label>
                                        <input type="text" id="nombre" name="nombre" class="form-control" required="true" 
                                               value="<jsp:getProperty name="profesor" property="nombre"></jsp:getProperty>">
                                    </div>

                                    <%-- Campo Apellido Paterno --%>
                                    <div class="mb-3 text-start">
                                        <label for="apellidoPaterno" class="form-label"><i class="fas fa-user-tag me-1"></i>Apellido Paterno:</label>
                                        <input type="text" id="apellidoPaterno" name="apellidoPaterno" class="form-control" required="true" 
                                               value="<jsp:getProperty name="profesor" property="apellidoPaterno"></jsp:getProperty>">
                                    </div>

                                    <%-- Campo Apellido Materno --%>
                                    <div class="mb-3 text-start">
                                        <label for="apellidoMaterno" class="form-label"><i class="fas fa-user-tag me-1"></i>Apellido Materno:</label>
                                        <input type="text" id="apellidoMaterno" name="apellidoMaterno" class="form-control" 
                                               value="<jsp:getProperty name="profesor" property="apellidoMaterno"></jsp:getProperty>">
                                    </div>

                                    <%-- Campo Email --%>
                                    <div class="mb-3 text-start">
                                        <label for="email" class="form-label"><i class="fas fa-envelope me-1"></i>Email:</label>
                                        <input type="email" id="email" name="email" class="form-control" required="true" 
                                               value="<jsp:getProperty name="profesor" property="email"></jsp:getProperty>">
                                    </div>
                                    
                                    <%-- Campo ID Facultad --%>
                                    <div class="mb-3 text-start">
                                        <label for="idFacultad" class="form-label"><i class="fas fa-building me-1"></i>ID Facultad:</label>
                                        <input type="number" id="idFacultad" name="idFacultad" class="form-control" required="true" 
                                               value="<jsp:getProperty name="profesor" property="idFacultad"></jsp:getProperty>">
                                    </div>

                                    <%-- Campo Rol --%>
                                    <div class="mb-3 text-start">
                                        <label for="rol" class="form-label"><i class="fas fa-user-shield me-1"></i>Rol:</label>
                                        <select id="rol" name="rol" class="form-select" required="true">
                                            <option value="profesor" <%= profesor.getRol() != null && profesor.getRol().equals("profesor") ? "selected" : "" %>>profesor</option>
                                            <option value="jefe_departamento" <%= profesor.getRol() != null && profesor.getRol().equals("jefe_departamento") ? "selected" : "" %>>jefe_departamento</option>
                                            <option value="admin" <%= profesor.getRol() != null && profesor.getRol().equals("admin") ? "selected" : "" %>>admin</option>
                                        </select>
                                    </div>

                                    <%-- Campo Password --%>
                                    <div class="mb-3 text-start">
                                        <label for="password" class="form-label"><i class="fas fa-key me-1"></i>Contraseña:</label>
                                        <input type="password" id="password" name="password" class="form-control" placeholder="Dejar en blanco para no cambiar">
                                    </div>
                                                                            
                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                        <a href="listado.jsp" class="btn btn-danger d-flex align-items-center me-md-2">
                                            <i class="fas fa-times-circle me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-warning d-flex align-items-center">
                                            <i class="fas fa-save me-2"></i>Actualizar Profesor
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>

<%-- Scripts --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
<script type="text/javascript">
    let table = new DataTable('#myTable');
</script>