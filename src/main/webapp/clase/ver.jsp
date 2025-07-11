<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Clase, pe.edu.dao.ClaseDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>Ver Clase</title>        

    </head>
    <%-- Instancia de ClaseDao para interactuar con la base de datos --%>
    <jsp:useBean id="claseDao" class="pe.edu.dao.ClaseDao" scope="session"></jsp:useBean>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                <div class="col py-3">    
                    <%-- Instancia de Clase para almacenar los datos de la clase a ver --%>
                    <jsp:useBean id="clase" class="pe.edu.entity.Clase" scope="session"></jsp:useBean>
                    <%
                        // Obtener el ID de la clase desde la URL
                        String id = request.getParameter("id");
                        
                        // Si el ID no es nulo, cargar los datos de la clase de la base de datos
                        if (id != null && !id.isEmpty()) {
                            Clase claseExistente = claseDao.leer(id);
                            if (claseExistente != null) {
                                clase.setIdClase(claseExistente.getIdClase());
                                clase.setIdCurso(claseExistente.getIdCurso());
                                clase.setIdProfesor(claseExistente.getIdProfesor());
                                clase.setIdHorario(claseExistente.getIdHorario());
                                clase.setCiclo(claseExistente.getCiclo());
                            }
                        }
                    %>
                    <center>
                        <div class="card card_login">
                            <div class="card-header card_titulo">
                                <h2>Ver Clase</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <%-- El action del formulario apunta a ClaseController, aunque para "ver" no se envía nada --%>
                                <form action="../ClaseController" method="post">
                                    <input type="hidden" name="accion" value="ver">
                                    
                                    <%-- Campo ID Clase (solo lectura) --%>
                                    ID Clase <br>
                                    <input type="text" name="idClase" class="form-control" readonly="true"
                                            value="<jsp:getProperty name="clase" property="idClase"></jsp:getProperty>"><br>
                                    
                                    <%-- Campo ID Curso (solo lectura) --%>
                                    ID Curso <br>
                                    <input type="text" name="idCurso" class="form-control" readonly="true"
                                            value="<jsp:getProperty name="clase" property="idCurso"></jsp:getProperty>"><br>

                                    <%-- Campo ID Profesor (solo lectura) --%>
                                    ID Profesor <br>
                                    <input type="text" name="idProfesor" class="form-control" readonly="true"
                                            value="<jsp:getProperty name="clase" property="idProfesor"></jsp:getProperty>"><br>

                                    <%-- Campo ID Horario (solo lectura) --%>
                                    ID Horario <br>
                                    <input type="text" name="idHorario" class="form-control" readonly="true"
                                            value="<jsp:getProperty name="clase" property="idHorario"></jsp:getProperty>"><br>

                                    <%-- Campo Ciclo (solo lectura) --%>
                                    Ciclo <br>
                                    <input type="text" name="ciclo" class="form-control" readonly="true"
                                            value="<jsp:getProperty name="clase" property="ciclo"></jsp:getProperty>"><br>
                                    
                                    <a href="listado.jsp" class="btn btn-danger">Volver al Listado</a>
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
