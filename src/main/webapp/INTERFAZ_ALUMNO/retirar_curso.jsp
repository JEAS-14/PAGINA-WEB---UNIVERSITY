<%-- 
    Document   : retirar_curso
    Created on : 31 may. 2025, 00:21:58
    Author     : Anthony
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>

<%
    int alumnoId = 1; // Reemplazar con sesión en un entorno real
    int idCursoRetiro = Integer.parseInt(request.getParameter("idCursoRetiro"));

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Conexion conexion = new Conexion();
conn = conexion.conecta(); // ✅

        String sql = "DELETE i FROM Inscripciones i " +
                     "JOIN Clases cl ON i.id_clase = cl.id_clase " +
                     "WHERE cl.id_curso = ? AND i.id_alumno = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, idCursoRetiro);
        stmt.setInt(2, alumnoId);

        int filas = stmt.executeUpdate();

        if (filas > 0) {
            out.println("<p></p>");
        } else {
            out.println("<p>No se pudo retirar o no estás inscrito en el curso.</p>");
        }
    } catch (SQLException e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Resultado</title>
    <style>
        body {
            margin: 0;
            background-color: #f8f9fa;
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .mensaje {
            background-color: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 500px;
            animation: fadeIn 0.5s ease;
        }

        .mensaje h2 {
            margin-bottom: 20px;
            color: #2c3e50;
        }

        .mensaje p {
            font-size: 1.1rem;
            color: #555;
            margin-bottom: 30px;
        }

        .boton-volver {
            background-color: #3498db;
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            cursor: pointer;
            text-decoration: none;
        }

        .boton-volver:hover {
            background-color: #2980b9;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
</head>
<body>

    <div class="mensaje">
        <h2>¡Operación exitosa!</h2>
        <p>Te has retirado correctamente del curso.</p>
        <a href="home_alumno.jsp" class="boton-volver">Volver al inicio</a>
    </div>

</body>
</html>