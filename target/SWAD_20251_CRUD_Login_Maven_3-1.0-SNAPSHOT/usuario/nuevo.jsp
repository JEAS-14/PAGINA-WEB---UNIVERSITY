<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>

        <title>JSP Page</title>        

    </head>
        <body>            
            <div class="container-fluid">
                <div class="row flex-nowrap">
                    <!-- menu -->
                <%@include file="../menu.jsp" %>
                <div class="col py-3"> 
                    <center>
                        <div class="card card_login">
                            <div class="card-header card_titulo">
                                    <h2>Nuevo Usuario</h2>
                                </div>
                                <br>
                            <div class="card-body">
                                <form action="../UsuarioController" method="post">                                    
                                    <input type="hidden" name="accion" value="nuevo">
                                    Usuario <br>
                                    <input type="text" name="usr" class="form-control" required="true">
                                    Password <br><!-- comment -->
                                    <input type="password" name="psw"  class="form-control" required="true">
                                    Nombre <br>
                                    <input type="nombre" name="nom"  class="form-control" required="true"> <br>
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

