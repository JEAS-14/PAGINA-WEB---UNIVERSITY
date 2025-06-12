<%-- 
    Document   : ver_pagos
    Created on : 3 may. 2025, 02:30:58
    Author     : LENOVO
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String emailUsuario = (String) session.getAttribute("email"); // Obtiene el email de la sesión

    if (emailUsuario == null || emailUsuario.isEmpty()) {
        out.println("<p style='color:red;text-align:center;'>Error: No se encontró el email del usuario en la sesión. Asegúrese de haber iniciado sesión correctamente.</p>");
        return; // Detiene la ejecución si no hay email en la sesión
    }

    Connection connection = null;
    PreparedStatement preparedStatementPagos = null;
    ResultSet resultSetPagos = null;
    List<Map<String, String>> pagosUsuario = new ArrayList<>();
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    try {
        Conexion conexion = new Conexion();
connection = conexion.conecta(); // ✅

        String sqlPagosUsuario = "SELECT p.fecha_pago, p.concepto, p.monto, p.metodo_pago, p.referencia " +
                                 "FROM alumnos a " +
                                 "JOIN pagos p ON a.id = p.id_alumno " +
                                 "WHERE a.email = ?";
        preparedStatementPagos = connection.prepareStatement(sqlPagosUsuario);
        preparedStatementPagos.setString(1, emailUsuario);
        resultSetPagos = preparedStatementPagos.executeQuery();

        while (resultSetPagos.next()) {
            Map<String, String> pago = new HashMap<>();
            java.sql.Date fechaPagoSql = resultSetPagos.getDate("fecha_pago");
            String fechaPagoFormatted = (fechaPagoSql != null) ? dateFormat.format(fechaPagoSql) : "";
            pago.put("fecha_pago", fechaPagoFormatted);
            pago.put("concepto", resultSetPagos.getString("concepto"));
            pago.put("monto", resultSetPagos.getString("monto"));
            pago.put("metodo_pago", resultSetPagos.getString("metodo_pago"));
            pago.put("referencia", resultSetPagos.getString("referencia"));
            pagosUsuario.add(pago);
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("Error al obtener los pagos del usuario: " + e.getMessage());
    } finally {
        try { if (resultSetPagos != null) resultSetPagos.close(); } catch (SQLException e) {}
        try { if (preparedStatementPagos != null) preparedStatementPagos.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mis Pagos</title>
        <style>
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                background-color: #f0f2f5;
            }

            h1 {
                color: #2c3e50;
                text-align: center;
                margin-bottom: 30px;
            }

            table {
                width: 90%;
                margin: auto;
                border-collapse: collapse;
                background-color: white;
                box-shadow: 0 0 12px rgba(0, 0, 0, 0.08);
                border-radius: 8px;
                overflow: hidden;
            }

            th, td {
                padding: 12px 15px;
                border: 1px solid #e0e0e0;
                text-align: center;
                font-size: 14px;
            }

            th {
                background-color: #3498db;
                color: white;
                font-weight: bold;
            }

            td.hora {
                background-color: #ecf0f1;
                font-weight: bold;
                color: #2c3e50;
            }

            td.ocupado {
                color: white;
                font-weight: bold;
                border: 1px solid #ddd;
            }

            td.libre {
                background-color: #ffffff;
            }

            /* Puedes agregar colores específicos para ciertas clases si lo deseas: */
            /* Ejemplo:
            .clase-matematica { background-color: #f39c12; }
            .clase-historia { background-color: #8e44ad; }
            */
        </style>

    </head>
    <body>
        <h1>Mis Pagos</h1>

        <% if (pagosUsuario.isEmpty()) { %>
        <p style="text-align: center;">No se encontraron pagos para tu cuenta.</p>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Fecha de Pago</th>
                    <th>Concepto</th>
                    <th>Monto</th>
                    <th>Método de Pago</th>
                    <th>Referencia</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, String> pago : pagosUsuario) { %>
                <tr>
                    <td><%= pago.get("fecha_pago") %></td>
                    <td><%= pago.get("concepto") %></td>
                    <td><%= pago.get("monto") %></td>
                    <td><%= pago.get("metodo_pago") %></td>
                    <td><%= pago.get("referencia") %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
        <h2 style="text-align:center; margin-top:40px;">Registrar Nuevo Pago</h2>
        <form action="registrar_pago.jsp" method="post" style="width: 50%; margin: auto; background-color: #ffffff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
            <label>Concepto:</label><br>
            <input type="text" name="concepto" required style="width:100%; padding:8px; margin-bottom:10px;"><br>

            <label>Monto (S/):</label><br>
            <input type="number" name="monto" step="0.01" required style="width:100%; padding:8px; margin-bottom:10px;"><br>

            <label>Método de Pago:</label><br>
            <select name="metodo_pago" required style="width:100%; padding:8px; margin-bottom:10px;">
                <option value="Yape">Yape</option>
                <option value="Plin">Plin</option>
                <option value="Tarjeta">Tarjeta</option>
                <option value="Transferencia">Transferencia</option>
            </select><br>

            <label>Referencia:</label><br>
            <input type="text" name="referencia" required style="width:100%; padding:8px; margin-bottom:20px;"><br>

            <input type="submit" value="Registrar Pago" style="width:100%; padding:10px; background-color:#3498db; color:white; border:none; border-radius:4px; cursor:pointer;">
        </form>
    </body>
</html>