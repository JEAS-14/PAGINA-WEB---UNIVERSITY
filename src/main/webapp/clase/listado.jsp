<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Clase, pe.edu.dao.ClaseDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>Listado de Clases</title>        

    </head>
    <%-- Instancia de ClaseDao para interactuar con la base de datos --%>
    <jsp:useBean id="claseDao" class="pe.edu.dao.ClaseDao" scope="session"></jsp:useBean>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                        
                    <center>
                        <div class="card card_tabla">
                            <div class="card-header card_titulo">
                                <h2>Clases</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-sm-1">
                                        <%-- Enlace para crear una nueva clase --%>
                                        <a href="../ClaseController?pagina=nuevo" class="btn btn-primary">Nuevo</a>
                                    </div>
                                    <div class="col-sm-11"></div>
                                </div>
                                <br>
                                <table id="myTable" class="display table table-light table-striped table-hover card_contenido">
                                    <thead>
                                        <tr>
                                            <th>ID Clase</th>
                                            <th>Curso</th>
                                            <th>Profesor</th>
                                            <th>Horario</th>
                                            <th>Ciclo</th>
                                            <th>Ver</th>
                                            <th>Editar</th>            
                                            <th>Eliminar</th>            
                                        </tr>
                                    </thead>
                                    <tbody>

                                    <%
                                        LinkedList<Clase> listaClases = claseDao.listar();
                                        if (listaClases == null) {
                                            listaClases = new LinkedList<Clase>();
                                        }
                                        for (Clase cl : listaClases) {
                                    %>            
                                    <tr>
                                        <td><%= cl.getIdClase() %></td>
                                        <td><%= cl.getIdCurso() %></td>
                                        <td><%= cl.getIdProfesor() %></td>
                                        <td><%= cl.getIdHorario() %></td>
                                        <td><%= cl.getCiclo() %></td>                              
                                        <%-- Enlaces para Ver, Editar y Eliminar --%>
                                        <td><a href="../ClaseController?pagina=ver&id=<%= cl.getIdClase() %>" class="btn btn-info">O</a></td>
                                        <td><a href="../ClaseController?pagina=editar&id=<%= cl.getIdClase() %>" class="btn btn-warning">U</a></td>
                                        <td><a href="../ClaseController?pagina=eliminar&id=<%= cl.getIdClase() %>" class="btn btn-danger">X</a></td>
                                    </tr>
                                    <%
                                        }
                                    %>                  
                                    </tbody>
                                </table>  
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