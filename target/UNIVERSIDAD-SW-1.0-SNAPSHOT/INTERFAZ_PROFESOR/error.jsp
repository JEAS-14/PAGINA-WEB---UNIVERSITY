<%@ page isErrorPage="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error en la Aplicación</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8d7da; color: #721c24; padding: 20px; }
        .container { background-color: #fdd; border: 1px solid #f5c6cb; border-radius: 8px; padding: 30px; margin-top: 50px; }
        h1 { color: #dc3545; }
        pre { background-color: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Error en la Aplicación</h1>
        <p>Ha ocurrido un error inesperado al procesar su solicitud.</p>
        <p>Por favor, intente de nuevo más tarde o contacte al soporte técnico si el problema persiste.</p>
        <%-- Mostrar el mensaje de la URL si existe --%>
        <%
            String message = request.getParameter("message");
            if (message != null && !message.isEmpty()) {
                out.println("<p><strong>Mensaje del sistema:</strong> " + message.replace("_", " ") + "</p>");
            }
        %>
        <%-- Opcional: para depuración, si quieres ver la traza del error real si es isErrorPage="true" --%>
        <% if (exception != null) { %>
            <h3>Detalles del Error:</h3>
            <p><strong>Tipo de Excepción:</strong> <%= exception.getClass().getName() %></p>
            <p><strong>Mensaje:</strong> <%= exception.getMessage() %></p>
            <pre><%= exception.toString() %></pre>
            <%
                // Para imprimir la traza completa en la consola de Tomcat
                exception.printStackTrace(new java.io.PrintWriter(out));
            %>
        <% } %>
        <a href="login.jsp" class="btn btn-primary mt-3">Volver a Inicio de Sesión</a>
    </div>
</body>
</html>