<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <title>Plataforma</title>
  <link href="estilos/bootstrap.min.css" rel="stylesheet"/>
  <link href="estilos/datatables.min.css" rel="stylesheet"/>
  <script src="estilos/jquery-3.7.1.min.js"></script>
  <script src="estilos/datatables.min.js"></script>
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <jsp:include page="menu.jsp" />

      <div class="col-md-10 mt-3">
        <%-- ***** INICIO DEL CAMBIO NECESARIO ***** --%>
        <%
            String contenidoPath = (String) request.getAttribute("contenido");
            if (contenidoPath == null || contenidoPath.trim().isEmpty()) {
                // Aquí defines QUÉ PÁGINA quieres que se cargue por defecto
                // cuando 'contenido' no está establecido.
                // Por ejemplo, tu página principal de UGIC Portal (la que es más informativa):
                contenidoPath = "Portal_UGIC_Principal.jsp"; // <--- CAMBIA ESTO A LA RUTA REAL DE TU PÁGINA PRINCIPAL
                                                              //      O la página de login de apoderado si quieres que sea el inicio.
                                                              //      Por ejemplo: "WEB-INF/vistas/login_apoderado.jsp"
            }
        %>
        <jsp:include page="<%= contenidoPath %>" />
        <%-- ***** FIN DEL CAMBIO NECESARIO ***** --%>
      </div>
    </div>
  </div>
</body>
</html>