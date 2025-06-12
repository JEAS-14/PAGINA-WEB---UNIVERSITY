<%-- 
    Document   : registrar_pago
    Created on : 31 may. 2025, 01:04:34
    Author     : Anthony
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null || email.isEmpty()) {
        out.println("<p style='color:red;text-align:center;'>Error: Debes iniciar sesión.</p>");
        return;
    }

    String concepto = request.getParameter("concepto");
    String monto = request.getParameter("monto");
    String metodo = request.getParameter("metodo_pago");
    String referencia = request.getParameter("referencia");

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Conexion conexion = new Conexion();
conn = conexion.conecta(); // ✅

        String sql = "INSERT INTO pagos (id_alumno, fecha_pago, concepto, monto, metodo_pago, referencia) " +
                     "VALUES ((SELECT id FROM alumnos WHERE email = ?), CURDATE(), ?, ?, ?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, email);
        stmt.setString(2, concepto);
        stmt.setDouble(3, Double.parseDouble(monto));
        stmt.setString(4, metodo);
        stmt.setString(5, referencia);

        int rows = stmt.executeUpdate();
        if (rows > 0) {
            response.sendRedirect("home_alumno.jsp"); // Regresa al listado de pagos
        } else {
            out.println("<p style='color:red;text-align:center;'>Error al registrar el pago.</p>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;text-align:center;'>Error al procesar el pago: " + e.getMessage() + "</p>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
