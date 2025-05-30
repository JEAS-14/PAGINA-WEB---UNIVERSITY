<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Usuario, pe.edu.dao.UsuarioDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>JSP Page</title>        

    </head>
    <jsp:useBean id="usuarioDao" class="pe.edu.dao.UsuarioDao" scope="session"></jsp:useBean>
        <body>            
            <div class="container-fluid">
                <div class="row flex-nowrap">
                    <!-- menu -->
                <%@include file="../menu.jsp" %>
                <div class="col py-3"> 
                    <jsp:useBean id="usuario" class="pe.edu.entity.Usuario" scope="session"></jsp:useBean>
                    <%
                        String id = request.getParameter("usr");
                    %>
                    <jsp:scriptlet>
                        usuario.setId(id);
                        usuario.setPassword(usuarioDao.leer(id).getPassword());
                        usuario.setNombre(usuarioDao.leer(id).getNombre());
                    </jsp:scriptlet>
                    <center>
                        <div class="card card_login">
                            <div class="card-body">
                                <form action="../UsuarioController"  method="post">
                                    <h3>EDITAR</h3>
                                    <input type="hidden" name="accion" value="editar">
                                    Usuario <br>
                                    <input type="text" name="usr" class="form-control" readonly="true"
                                           value="<jsp:getProperty name="usuario" property="id"></jsp:getProperty>">
                                           Password <br><!-- comment -->
                                           <input type="text" name="psw"  class="form-control" 
                                                  value="<jsp:getProperty name="usuario" property="password"></jsp:getProperty>">
                                           Nombre <br>
                                           <input type="text" name="nom"  class="form-control" 
                                                  value="<jsp:getProperty name="usuario" property="nombre"></jsp:getProperty>"><br>
                                    <a href="listado.jsp" class="btn btn-danger">Cancelar</a>
                                    <input type="submit"  class="btn btn-success" value="Aceptar">
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
    </
