<%-- 
    Document   : nuevo_curso
    Created on : 31 may. 2025, 00:00:08
    Author     : Anthony
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>

<%
    int alumnoId = 1; // Obtener desde la sesión en un caso real
    int idCurso = Integer.parseInt(request.getParameter("idCurso"));

    Connection conn = null;
    PreparedStatement stmt = null;

    try {
        Conexion conexion = new Conexion();
conn = conexion.conecta(); // ✅

        
        // Obtener clase relacionada al curso (esto depende de tu estructura)
        String obtenerClase = "SELECT id_clase FROM Clases WHERE id_curso = ? LIMIT 1";
        stmt = conn.prepareStatement(obtenerClase);
        stmt.setInt(1, idCurso);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            int idClase = rs.getInt("id_clase");
            rs.close();
            
            String insertar = "INSERT INTO Inscripciones (id_alumno, id_clase) VALUES (?, ?)";
            stmt = conn.prepareStatement(insertar);
            stmt.setInt(1, alumnoId);
            stmt.setInt(2, idClase);
            stmt.executeUpdate();
            
            out.println("<p></p>");
        } else {
            out.println("<p>No se encontró clase para este curso.</p>");
        }
    } catch (SQLException e) {
        out.println("<p>Error al registrar el curso: " + e.getMessage() + "</p>");
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
        <p>Te has registrado correctamente del curso.</p>
        <a href="home_alumno.jsp" class="boton-volver">Volver al inicio</a>
    </div>

</body>
</html>
