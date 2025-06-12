<%-- 
    Document   : ver_horarios
    Created on : 2 may. 2025, 17:09:35
    Author     : LENOVO
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<%@ page import="java.util.*" %>

<%
    String emailUsuario = (String) session.getAttribute("email");

    if (emailUsuario == null || emailUsuario.isEmpty()) {
        out.println("<p style='color:red;text-align:center;'>Error: No se encontró el email del usuario en la sesión.</p>");
        return;
    }

    Connection connection = null;
    PreparedStatement preparedStatementHorarios = null;
    ResultSet resultSetHorarios = null;

    // Mapa con clave como "dia_hora" para pintar en el calendario
    Set<String> bloquesReservados = new HashSet<>();

    try {
        Conexion conexion = new Conexion();
connection = conexion.conecta(); // ✅

        String sqlHorariosUsuario = "SELECT h.dia_semana, h.hora_inicio, h.hora_fin " +
                                     "FROM alumnos a " +
                                     "JOIN inscripciones i ON a.id = i.id_alumno " +
                                     "JOIN clases cl ON i.id_clase = cl.id_clase " +
                                     "JOIN horarios h ON cl.id_horario = h.id_horario " +
                                     "WHERE a.email = ?";
        preparedStatementHorarios = connection.prepareStatement(sqlHorariosUsuario);
        preparedStatementHorarios.setString(1, emailUsuario);
        resultSetHorarios = preparedStatementHorarios.executeQuery();

        while (resultSetHorarios.next()) {
            String dia = resultSetHorarios.getString("dia_semana");
            String horaInicio = resultSetHorarios.getString("hora_inicio");
            String horaFin = resultSetHorarios.getString("hora_fin");

            // Convertimos las horas a bloques por hora
            int inicio = Integer.parseInt(horaInicio.substring(0, 2));
            int fin = Integer.parseInt(horaFin.substring(0, 2));

            for (int h = inicio; h < fin; h++) {
                bloquesReservados.add(dia + "_" + h);
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<p style='color:red;text-align:center;'>Error al obtener los horarios: " + e.getMessage() + "</p>");
    } finally {
        try { if (resultSetHorarios != null) resultSetHorarios.close(); } catch (SQLException e) {}
        try { if (preparedStatementHorarios != null) preparedStatementHorarios.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }

    String[] dias = {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"};
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mi Horario Semanal</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f0f2f5;
        }

        h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 30px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: center;
            font-size: 14px;
        }

        th {
            background-color: #3498db;
            color: white;
        }

        .hora {
            background-color: #ecf0f1;
            font-weight: bold;
        }

        .ocupado {
            background-color: #2ecc71;
            color: white;
            font-weight: bold;
        }

        .libre {
            background-color: #ffffff;
        }

        .tooltip {
            position: relative;
            display: inline-block;
        }

        .tooltip:hover::after {
            content: "Clase asignada";
            position: absolute;
            background-color: #333;
            color: #fff;
            padding: 5px 8px;
            border-radius: 5px;
            top: 120%;
            left: 50%;
            transform: translateX(-50%);
            white-space: nowrap;
            font-size: 12px;
            z-index: 10;
        }
    </style>
</head>
<body>
    <h1>Mi Horario Semanal</h1>
    <table>
        <thead>
            <tr>
                <th>Hora</th>
                <% for (String dia : dias) { %>
                    <th><%= dia %></th>
                <% } %>
            </tr>
        </thead>
        <tbody>
            <% 
                for (int hora = 7; hora <= 22; hora++) { 
                    String horaLabel = String.format("%02d:00 - %02d:00", hora, hora + 1);
            %>
            <tr>
                <td class="hora"><%= horaLabel %></td>
                <% for (String dia : dias) { 
                    String clave = dia + "_" + hora;
                    boolean ocupado = bloquesReservados.contains(clave);
                %>
                    <td class="<%= ocupado ? "ocupado tooltip" : "libre" %>">
                        <%= ocupado ? "✓" : "" %>
                    </td>
                <% } %>
            </tr>
            <% } %>
        </tbody>
    </table>
</body>
</html>
