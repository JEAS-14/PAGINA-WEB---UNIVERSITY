<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Invalida la sesión actual
    session.invalidate();

    // Redirige al usuario a la página Plataforma.jsp (o la ruta completa si es diferente)
    response.sendRedirect("Plataforma.jsp");
%>