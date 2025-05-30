<%-- 
    Document   : index
    Created on : 26 abr. 2025, 4:51:16 p. m.
    Author     : Estudiante
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="util/referencias.jsp" %>        
        <title>JSP Page</title>
    </head>
    <body>  
    <center>
        <div class="card card_login">
            <div class="card-header card_titulo">
                <h2>Login</h2>
            </div>            
            <div class="card-body">
                <div class="row">
                    <div class="col-sm-5">
                        <form action="Autentica" method="post">                    
                            Usuario <br>
                            <input type="text" name="usr" class="form-control" required="true">
                            Password <br><!-- comment -->
                            <input type="password" name="psw" class="form-control" required="true"> <br>
                            <input type="submit"  class="form-control btn btn-primary">
                        </form>
                    </div>
                    <div class="col-sm-7">
                        <img src="images/login.jpg" width="400px"/>
                    </div>

                </div>
            </div>
    </center>

</body>
</html>
