<%-- 
    Document   : ver_notas
    Created on : 2 may. 2025, 17:19:37
    Author     : LENOVO
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>

<%
    String emailUsuario = (String) session.getAttribute("email"); // Obtiene el email de la sesión

    if (emailUsuario == null || emailUsuario.isEmpty()) {
        out.println("<p style='color:red;text-align:center;'>Error: No se encontró el email del usuario en la sesión. Asegúrese de haber iniciado sesión correctamente.</p>");
        return; // Detiene la ejecución si no hay email en la sesión
    }

    Connection connection = null;
    PreparedStatement preparedStatementNotas = null;
    ResultSet resultSetNotas = null;
    List<Map<String, String>> notasUsuario = new ArrayList<>();

    try {
        Conexion conexion = new Conexion();
connection = conexion.conecta(); // ✅

        String sqlNotasUsuario = "SELECT c.nombre_curso, n.nota1, n.nota2, n.nota_final, n.estado " +
                                 "FROM alumnos a " +
                                 "JOIN inscripciones i ON a.id = i.id_alumno " +
                                 "JOIN notas n ON i.id_inscripcion = n.id_inscripcion " +
                                 "JOIN clases cl ON i.id_clase = cl.id_clase " +
                                 "JOIN cursos c ON cl.id_curso = c.id_curso " +
                                 "WHERE a.email = ?";
        preparedStatementNotas = connection.prepareStatement(sqlNotasUsuario);
        preparedStatementNotas.setString(1, emailUsuario);
        resultSetNotas = preparedStatementNotas.executeQuery();

        while (resultSetNotas.next()) {
            Map<String, String> nota = new HashMap<>();
            nota.put("nombre_curso", resultSetNotas.getString("nombre_curso"));
            nota.put("nota1", resultSetNotas.getString("nota1"));
            nota.put("nota2", resultSetNotas.getString("nota2"));
            nota.put("nota_final", resultSetNotas.getString("nota_final"));
            nota.put("estado", resultSetNotas.getString("estado"));
            notasUsuario.add(nota);
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("Error al obtener las notas del usuario: " + e.getMessage());
    } finally {
        try { if (resultSetNotas != null) resultSetNotas.close(); } catch (SQLException e) {}
        try { if (preparedStatementNotas != null) preparedStatementNotas.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mis Notas</title>
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
        <h1>Mis Notas</h1>
        <% if (notasUsuario.isEmpty()) { %>
        <p style="text-align: center;">No se encontraron notas para tu cuenta.</p>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Curso</th>
                    <th>Nota 1</th>
                    <th>Nota 2</th>
                    <th>Nota Final</th>
                    <th>Estado</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, String> nota : notasUsuario) { %>
                <tr>
                    <td><%= nota.get("nombre_curso") %></td>
                    <td><%= nota.get("nota1") %></td>
                    <td><%= nota.get("nota2") %></td>
                    <td><%= nota.get("nota_final") %></td>
                    <td><%= nota.get("estado") %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </body>
</html>