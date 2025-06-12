<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Alumno, pe.edu.dao.AlumnoDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>Ver Alumno</title>        

    </head>
    <%-- Instancia de AlumnoDao para interactuar con la base de datos --%>
    <jsp:useBean id="alumnoDao" class="pe.edu.dao.AlumnoDao" scope="session"></jsp:useBean>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                <div class="col py-3">    
                    <%-- Instancia de Alumno para almacenar los datos del alumno a ver --%>
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
                                alumno.setApellidoPaterno(alumnoExistente.getApellidoPaterno());
                                alumno.setApellidoMaterno(alumnoExistente.getApellidoMaterno());
                                alumno.setDireccion(alumnoExistente.getDireccion());
                                alumno.setTelefono(alumnoExistente.getTelefono());
                                alumno.setFechaNacimiento(alumnoExistente.getFechaNacimiento());
                                alumno.setEmail(alumnoExistente.getEmail());
                                alumno.setIdCarrera(alumnoExistente.getIdCarrera());
                                alumno.setRol(alumnoExistente.getRol());
                                alumno.setPassword(alumnoExistente.getPassword());
                                alumno.setEstado(alumnoExistente.getEstado());
                                alumno.setFechaRegistro(alumnoExistente.getFechaRegistro());                               
                            }
                        }
                    %>
                    <center>
                        <div class="card card_login">
                            <div class="card-header card_titulo">
                                <h2>Ver Alumno</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <%-- El action del formulario apunta a AlumnoController, aunque para "ver" no se envía nada --%>
                                <form action="../AlumnoController" method="post">
                                    <input type="hidden" name="accion" value="ver">
                                    
                                    <%-- Campo ID (solo lectura) --%>
                                    ID Alumno <br>
                                    <input type="text" name="id" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="id"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo DNI (solo lectura) --%>
                                    DNI <br>
                                    <input type="text" name="dni" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="dni"></jsp:getProperty>"><br>

                                    <%-- Campo Nombre (solo lectura) --%>
                                    Nombre <br>
                                    <input type="text" name="nombre" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="nombre"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Apellido Paterno (solo lectura) --%>
                                    Apellido Paterno <br>
                                    <input type="text" name="apellidoPaterno" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="apellidoPaterno"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Apellido Materno (solo lectura) --%>
                                    Apellido Materno <br>
                                    <input type="text" name="apellidoMaterno" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="apellidoMaterno"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Dirección (solo lectura) --%>
                                    Dirección <br>
                                    <input type="text" name="direccion" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="direccion"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Teléfono (solo lectura) --%>
                                    Teléfono <br>
                                    <input type="text" name="telefono" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="telefono"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Fecha de Nacimiento (solo lectura) --%>
                                    Fecha de Nacimiento <br>
                                    <input type="text" name="fechaNacimiento" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="fechaNacimiento"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Email (solo lectura) --%>
                                    Email <br>
                                    <input type="text" name="email" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="email"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo ID Carrera (solo lectura) --%>
                                    ID Carrera <br>
                                    <input type="text" name="idCarrera" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="idCarrera"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Rol (solo lectura) --%>
                                    Rol <br>
                                    <input type="text" name="rol" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="rol"></jsp:getProperty>"><br>

                                    <%-- Campo Password (solo lectura) --%>
                                    Password <br>
                                    <input type="password" name="password" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="password"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Estado (solo lectura) --%>
                                    Estado <br>
                                    <input type="text" name="estado" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="estado"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo Fecha de Registro (solo lectura) --%>
                                    Fecha de Registro <br>
                                    <input type="text" name="fechaRegistro" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="alumno" property="fechaRegistro"></jsp:getProperty>"><br>
                                    
                                    <a href="listado.jsp" class="btn btn-danger">Volver al Listado</a>
                                    <%-- El botón "Aceptar" no tiene una función aquí, ya que es solo para ver. 
                                         Se podría quitar o cambiar a un botón de "Cerrar" --%>
                                    <%-- <input type="submit" class="btn btn-success" value="Aceptar"> --%>
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