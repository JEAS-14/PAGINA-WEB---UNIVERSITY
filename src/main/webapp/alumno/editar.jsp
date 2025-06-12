<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Alumno, pe.edu.dao.AlumnoDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>Editar Alumno</title>        

    </head>
    <%-- Instancia de AlumnoDao para interactuar con la base de datos --%>
    <jsp:useBean id="alumnoDao" class="pe.edu.dao.AlumnoDao" scope="session"></jsp:useBean>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                <div class="col py-3">    
                    <%-- Instancia de Alumno para almacenar los datos del alumno a editar --%>
                    <jsp:useBean id="alumno" class="pe.edu.entity.Alumno" scope="session"></jsp:useBean>
                    <%
                        // Obtener el ID del alumno desde la URL
                        String id = request.getParameter("id");
                        
                        // Si el ID no es nulo, cargar los datos del alumno de la base de datos
                        if (id != null && !id.isEmpty()) {
                            Alumno alumnoExistente = alumnoDao.leer(id);
                            if (alumnoExistente != null) {
                                alumno.setId(alumnoExistente.getId());
                                alumno.setDni(alumnoExistente.getDni());
                                alumno.setNombre(alumnoExistente.getNombre());
                                alumno.setApellido(alumnoExistente.getApellido());
                                alumno.setDireccion(alumnoExistente.getDireccion());
                                alumno.setTelefono(alumnoExistente.getTelefono());
                                alumno.setFechaNacimiento(alumnoExistente.getFechaNacimiento());
                                alumno.setEmail(alumnoExistente.getEmail());
                                alumno.setIdCarrera(alumnoExistente.getIdCarrera());
                                alumno.setRol(alumnoExistente.getRol());
                                alumno.setPassword(alumnoExistente.getPassword());                               
                            }
                        }
                    %>
                    <center>
                        <div class="card card_login">
                            <div class="card-body">
                                <%-- El action del formulario apunta a AlumnoController --%>
                                <form action="../AlumnoController" method="post">
                                    <h3>EDITAR ALUMNO</h3>
                                    <input type="hidden" name="accion" value="editar">
                                    
                                    <%-- Campo ID (solo lectura) --%>
                                    ID Alumno <br>
                                    <input type="text" name="id" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="id"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo DNI --%>
                                    DNI <br>
                                    <input type="text" name="dni" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="dni"></jsp:getProperty>"><br>

                                    <%-- Campo Nombre --%>
                                    Nombre <br>
                                    <input type="text" name="nombre" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="nombre"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Apellido --%>
                                    Apellido <br>
                                    <input type="text" name="apellido" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="apellido"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Dirección --%>
                                    Dirección <br>
                                    <input type="text" name="direccion" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="direccion"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Teléfono --%>
                                    Teléfono <br>
                                    <input type="text" name="telefono" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="telefono"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Fecha de Nacimiento --%>
                                    Fecha de Nacimiento <br>
                                    <input type="text" name="fechaNacimiento" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="fechaNacimiento"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Email --%>
                                    Email <br>
                                    <input type="text" name="email" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="email"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo ID Carrera --%>
                                    ID Carrera <br>
                                    <input type="text" name="idCarrera" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="idCarrera"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Rol (si aplica y es editable) --%>
                                    Rol <br>
                                    <input type="text" name="rol" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="rol"></jsp:getProperty>"><br>

                                    <%-- Campo Password --%>
                                    Password <br>
                                    <input type="text" name="password" class="form-control"
                                           value="<jsp:getProperty name="alumno" property="password"></jsp:getProperty>"><br>
                                                                   
                                    <a href="listado.jsp" class="btn btn-danger">Cancelar</a>
                                    <input type="submit" class="btn btn-success" value="Aceptar">
                                </form>
                            </div>
                        </div>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>

<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="https://cdn.datatables.net/2.3.1/js/dataTables.js"></script>

<script type="text/javascript">
    let table = new DataTable('#myTable');
</script>