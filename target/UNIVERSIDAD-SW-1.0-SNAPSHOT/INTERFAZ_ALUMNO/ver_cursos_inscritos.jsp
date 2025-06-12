<%-- 
    Document   : ver_cursos_inscritos
    Created on : 2 may. 2025, 09:35:03
    Author     : LENOVO
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Base64" %>

<%
    // Suponiendo que tienes el ID del alumno en la sesión
    int alumnoId = 1; // Reemplazar con la obtención real del ID de la sesión

    Connection connection = null;
    PreparedStatement preparedStatementCursos = null;
    ResultSet resultSetCursos = null;

    List<String> cursosInscritos = new ArrayList<>();
    List<Integer> cursoIds = new ArrayList<>();
    Map<Integer, String> imagenesBase64 = new HashMap<>(); // Para almacenar las imágenes en Base64

    try {
        Conexion conexion = new Conexion();
        connection = conexion.conecta(); // ✅

        String sqlCursosConImagen = "SELECT c.id_curso, c.nombre_curso, c.imagen, c.tipo_imagen FROM Inscripciones i " +
                           "JOIN Clases cl ON i.id_clase = cl.id_clase " +
                           "JOIN Cursos c ON cl.id_curso = c.id_curso " +
                           "WHERE i.id_alumno = ?";
        preparedStatementCursos = connection.prepareStatement(sqlCursosConImagen);
        preparedStatementCursos.setInt(1, alumnoId);
        resultSetCursos = preparedStatementCursos.executeQuery();

        while (resultSetCursos.next()) {
            int idCurso = resultSetCursos.getInt("id_curso");
            String nombreCurso = resultSetCursos.getString("nombre_curso");
            
            cursosInscritos.add(nombreCurso);
            cursoIds.add(idCurso);
            
            // Obtener la imagen y convertirla a Base64
            Blob blob = resultSetCursos.getBlob("imagen");
            String tipoImagen = resultSetCursos.getString("tipo_imagen");
            
            if (blob != null && tipoImagen != null) {
                // Convertir el blob a un array de bytes
                byte[] imagenBytes = blob.getBytes(1, (int) blob.length());
                
                // Convertir a Base64
                String imagenBase64 = Base64.getEncoder().encodeToString(imagenBytes);
                
                // Guardar en el mapa con formato para HTML (data URI)
                imagenesBase64.put(idCurso, "data:" + tipoImagen + ";base64," + imagenBase64);
            } else {
                // Imagen por defecto o marcador de posición si no hay imagen
                imagenesBase64.put(idCurso, "");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("Error al obtener los cursos inscritos: " + e.getMessage());
    } finally {
        try { if (resultSetCursos != null) resultSetCursos.close(); } catch (SQLException e) {}
        try { if (preparedStatementCursos != null) preparedStatementCursos.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Cursos Inscritos</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f0f2f5;
                margin: 0;
            }

            h1 {
                color: #2c3e50;
                text-align: center;
                margin-bottom: 40px;
                font-size: 2.2rem;
                text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
            }

            .cursos-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 25px;
                list-style-type: none;
                padding: 0;
                margin: 0 auto;
                max-width: 1200px;
            }

            .curso-card {
                background-color: #ffffff;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                display: flex;
                flex-direction: column;
                cursor: pointer;
                border-top: 5px solid #3498db;
            }

            .curso-card:hover {
                transform: translateY(-7px);
                box-shadow: 0 12px 25px rgba(0, 0, 0, 0.12);
            }

            .curso-imagen-container {
                height: 220px;
                background-color: #ecf0f1;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
            }

            .curso-imagen {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.3s ease;
            }

            .curso-card:hover .curso-imagen {
                transform: scale(1.05);
            }

            .no-image {
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1rem;
                color: #95a5a6;
                background-color: #dfe6e9;
            }

            .curso-nombre {
                padding: 18px 15px;
                font-weight: 600;
                font-size: 1.1rem;
                color: #2c3e50;
                background-color: #ffffff;
                border-top: 1px solid #ecf0f1;
                transition: background-color 0.3s ease;
            }

            .curso-card:hover .curso-nombre {
                background-color: #f9fbfd;
            }
            .popup-form {
                max-width: 400px;
                margin: 60px auto;
                background-color: #ffffff;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                text-align: center;
                animation: fadeInUp 0.5s ease-in-out;
            }

            .popup-form h2 {
                margin-bottom: 20px;
                font-size: 1.5rem;
                color: #2c3e50;
            }

            .popup-form label {
                display: block;
                margin-bottom: 8px;
                text-align: left;
                color: #34495e;
            }

            .popup-form select,
            .popup-form button {
                width: 100%;
                padding: 12px;
                margin-bottom: 15px;
                border-radius: 6px;
                border: 1px solid #ccc;
                font-size: 1rem;
            }

            .popup-form button {
                background-color: #3498db;
                color: white;
                border: none;
                cursor: pointer;
                transition: background-color 0.3s ease;
            }

            .popup-form button:hover {
                background-color: #2980b9;
            }

            .popup-form .btn-danger {
                background-color: #e74c3c;
            }

            .popup-form .btn-danger:hover {
                background-color: #c0392b;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
        </style>

    </head>
    <body>
        <h1>Mis Cursos Inscritos</h1>

        <% if (cursosInscritos.isEmpty()) { %>
        <p style="text-align: center;">No estás inscrito en ningún curso actualmente.</p>
        <% } else { %>
        <ul class="cursos-grid">
            <% for (int i = 0; i < cursosInscritos.size(); i++) { 
                 String nombreCurso = cursosInscritos.get(i);
                 int idCurso = cursoIds.get(i);
                 String imagenBase64 = imagenesBase64.get(idCurso);
            %>
            <li class="curso-card">
                <div class="curso-imagen-container">
                    <% if (imagenBase64 != null && !imagenBase64.isEmpty()) { %>
                    <img class="curso-imagen" src="<%= imagenBase64 %>" alt="<%= nombreCurso %>">
                    <% } else { %>
                    <div class="no-image">Sin imagen</div>
                    <% } %>
                </div>
                <div class="curso-nombre"><%= nombreCurso %></div>
            </li>
            <% } %>
        </ul>
        <% } %>
        <%@ page import="java.util.LinkedHashMap" %>
        <%
            // Obtener cursos disponibles para inscribirse (que aún no tiene el alumno)
            Map<Integer, String> cursosDisponibles = new LinkedHashMap<>();
            try {
                Conexion conexion = new Conexion();
connection = conexion.conecta(); // ✅

                String sqlDisponibles = "SELECT id_curso, nombre_curso FROM Cursos WHERE id_curso NOT IN " +
                                        "(SELECT c.id_curso FROM Inscripciones i " +
                                        "JOIN Clases cl ON i.id_clase = cl.id_clase " +
                                        "JOIN Cursos c ON cl.id_curso = c.id_curso WHERE i.id_alumno = ?)";
                preparedStatementCursos = connection.prepareStatement(sqlDisponibles);
                preparedStatementCursos.setInt(1, alumnoId);
                resultSetCursos = preparedStatementCursos.executeQuery();

                while (resultSetCursos.next()) {
                    cursosDisponibles.put(resultSetCursos.getInt("id_curso"), resultSetCursos.getString("nombre_curso"));
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { if (resultSetCursos != null) resultSetCursos.close(); } catch (SQLException e) {}
                try { if (preparedStatementCursos != null) preparedStatementCursos.close(); } catch (SQLException e) {}
                try { if (connection != null) connection.close(); } catch (SQLException e) {}
            }
        %>

        <div class="popup-form">
            <h2>Registrar nuevo curso</h2>
            <form action="registrar_curso.jsp" method="post">
                <label for="idCurso">Seleccione un curso:</label>
                <select name="idCurso" required>
                    <% for (Map.Entry<Integer, String> curso : cursosDisponibles.entrySet()) { %>
                    <option value="<%= curso.getKey() %>"><%= curso.getValue() %></option>
                    <% } %>
                </select>
                <button type="submit">Inscribirse</button>
            </form>
        </div>

        <div class="popup-form">
            <h2>Retirar curso inscrito</h2>
            <form action="retirar_curso.jsp" method="post">
                <label for="idCursoRetiro">Seleccione un curso:</label>
                <select name="idCursoRetiro" required>
                    <% for (int i = 0; i < cursoIds.size(); i++) { %>
                    <option value="<%= cursoIds.get(i) %>"><%= cursosInscritos.get(i) %></option>
                    <% } %>
                </select>
                <button type="submit" class="btn-danger">Retirarse</button>
            </form>
        </div>
    </body>
</html>