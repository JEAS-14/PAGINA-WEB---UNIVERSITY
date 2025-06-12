<%-- 
    Document   : actualizar_alumno
    Created on : 2 may. 2025, 22:37:19
    Author     : LENOVO
--%>

<%-- actualizar_alumno.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %> <%-- Importa tu clase Conexion --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Actualizar Alumno</title>
</head>
<body>
    <%
        String userEmail = request.getParameter("email");
        String nuevaDireccion = request.getParameter("direccion");
        String nuevoTelefono = request.getParameter("telefono");

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            connection = Conexion.getConnection();
            String sql = "UPDATE alumnos SET direccion = ?, telefono = ? WHERE email = ?";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, nuevaDireccion);
            preparedStatement.setString(2, nuevoTelefono);
            preparedStatement.setString(3, userEmail);

            int filasActualizadas = preparedStatement.executeUpdate();

            if (filasActualizadas > 0) {
                out.println("<h3>Información actualizada correctamente.</h3>");
                out.println("<p><a href='informacion_alumno.jsp'>Volver a la información del alumno</a></p>");
            } else {
                out.println("<h3 class='text-danger'>Error al actualizar la información.</h3>");
                out.println("<p class='text-danger'>No se pudo actualizar el registro para el email: " + userEmail + "</p>");
                out.println("<p><a href='informacion_alumno.jsp'>Volver a la información del alumno</a></p>");
            }

        } catch (SQLException e) {
            out.println("<p class='text-danger'>Error al conectar o actualizar la base de datos: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try { if (preparedStatement != null) preparedStatement.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (connection != null) connection.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>
</body>
</html>