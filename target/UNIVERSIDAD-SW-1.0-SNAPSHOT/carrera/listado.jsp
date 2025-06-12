<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Carrera, pe.edu.dao.CarreraDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>Listado de Carreras</title>        

    </head>
    <%-- Instancia de CarreraDao para interactuar con la base de datos --%>
    <jsp:useBean id="carreraDao" class="pe.edu.dao.CarreraDao" scope="session"></jsp:useBean>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                        
                    <center>
                        <div class="card card_tabla">
                            <div class="card-header card_titulo">
                                <h2>Carreras</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-sm-1">
                                        <%-- Enlace para crear una nueva carrera --%>
                                        <a href="../CarreraController?pagina=nuevo" class="btn btn-primary">Nuevo</a>
                                    </div>
                                    <div class="col-sm-11"></div>
                                </div>
                                <br>
                                <table id="myTable" class="display table table-light table-striped table-hover card_contenido">
                                    <thead>
                                        <tr>
                                            <th>ID Carrera</th>
                                            <th>Nombre Carrera</th>
                                            <th>ID Facultad</th>
                                            <th>Ver</th>
                                            <th>Editar</th>            
                                            <th>Eliminar</th>            
                                        </tr>
                                    </thead>
                                    <tbody>

                                    <%
                                        LinkedList<Carrera> listaCarreras = carreraDao.listar();
    if (listaCarreras == null) {
        listaCarreras = new LinkedList<Carrera>();
    }
    for (Carrera c : listaCarreras) {
                                    %>            
                                    <tr>
                                        <td><%= c.getIdCarrera() %></td>
                                        <td><%= c.getNombreCarrera() %></td>
                                        <td><%= c.getIdFacultad() %></td>                              
                                        <%-- Enlaces para Ver, Editar y Eliminar --%>
                                        <td><a href="../CarreraController?pagina=ver&id=<%= c.getIdCarrera() %>" class="btn btn-info">O</a></td>
                                        <td><a href="../CarreraController?pagina=editar&id=<%= c.getIdCarrera() %>" class="btn btn-warning">U</a></td>
                                        <td><a href="../CarreraController?pagina=eliminar&id=<%= c.getIdCarrera() %>" class="btn btn-danger">X</a></td>
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