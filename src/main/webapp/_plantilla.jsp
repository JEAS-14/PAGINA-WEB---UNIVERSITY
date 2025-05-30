<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.model.Usuario" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="referencias.jsp" %>

        <title>JSP Page</title>        

    </head>
    <jsp:useBean id="users" class="pe.edu.model.Usuario" scope="session"></jsp:useBean>
        <body>            
            <div class="container-fluid">
                <div class="row flex-nowrap">
                    <!-- menu -->
                <%@include file="menu.jsp" %>
                <div class="col py-3">
                    <!-- contenido -->
                    
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
