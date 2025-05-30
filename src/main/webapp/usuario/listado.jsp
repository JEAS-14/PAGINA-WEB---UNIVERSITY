

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Usuario, pe.edu.dao.UsuarioDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>
        
        <title>JSP Page</title>        

    </head>
    <jsp:useBean id="users" class="pe.edu.entity.Usuario" scope="session"></jsp:useBean>
    <jsp:useBean id="usersDao" class="pe.edu.dao.UsuarioDao" scope="session"></jsp:useBean>
        <body>            
            <div class="container-fluid">
                <div class="row flex-nowrap">
                    
                    <!-- menu -->
                <%@include file="../menu.jsp" %>
                    
                    <div class="col py-3">            
                        
                        <!-- contenido -->
                        <center>
                            <div class="card card_tabla">
                                <div class="card-header card_titulo">
                                    <h2>Usuarios</h2>
                                </div>
                                <br>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-sm-1">
                                            <a href="../UsuarioController?pagina=nuevo" class="btn btn-primary ">Nuevo</a>
                                        </div>
                                        <div class="col-sm-11"></div>
                                    </div>
                                    <br>
                                    <table id="myTable" class="display table table-light table-striped table-hover card_contenido">
                                        <thead>
                                            <tr>
                                                <th>Id</th>
                                                <th>Password</th>                    
                                                <th>Nombre</th>    
                                                <th>Ver</th>
                                                <th>Editar</th>                    
                                                <th>Eliminar</th>    
                                            </tr>
                                        </thead>
                                        <tbody>

                                        <%
                                            LinkedList<Usuario> lista = new LinkedList<>();
                                            lista = usersDao.listar();
                                            for (Usuario u : lista) {
                                        %>                
                                        <tr>
                                            <td><%=u.getId()%></td>
                                            <td><%=u.getPassword()%></td>
                                            <td><%=u.getNombre()%></td>
                                            <td><a href="../UsuarioController?pagina=leer&usr=<%=u.getId()%>" class="btn btn-info">O</a></td>
                                            <td><a href="../UsuarioController?pagina=editar&usr=<%=u.getId()%>"  class="btn btn-warning">U</a></td>
                                            <td><a href="../UsuarioController?pagina=eliminar&usr=<%=u.getId()%>" class="btn btn-danger">X</a></td>
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

