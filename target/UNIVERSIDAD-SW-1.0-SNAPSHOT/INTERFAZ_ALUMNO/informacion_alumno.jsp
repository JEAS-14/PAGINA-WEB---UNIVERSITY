<%-- 
    Document   : informacion_alumno
    Created on : 2 may. 2025, 17:17:40
    Author     : LENOVO
--%>

<%-- informacion_alumno.jsp --%>
<%-- informacion_alumno.jsp --%>
<%-- informacion_alumno.jsp --%>
<%-- informacion_alumno.jsp --%>
<%-- informacion_alumno.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Información del Alumno</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
    body {
        background-color: #f0f2f5;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        margin: 0;
    }

    .container {
        margin-top: 60px;
        max-width: 800px;
        margin-left: auto;
        margin-right: auto;
        padding: 0 20px;
    }

    .card {
        border: none;
        border-radius: 12px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        background-color: #fff;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
    }

    .card-header {
        background: linear-gradient(to right, #3498db, #2980b9);
        color: white;
        font-weight: 600;
        text-align: center;
        padding: 1.5rem;
        font-size: 1.6rem;
        border-radius: 12px 12px 0 0;
        text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
    }

    .card-body {
        padding: 2rem;
    }

    .info-row {
        margin-bottom: 1rem;
        font-size: 1rem;
        color: #34495e;
    }

    .info-label {
        font-weight: 600;
        display: inline-block;
        width: 160px;
        color: #2c3e50;
    }

    .text-danger {
        color: #e74c3c;
        font-size: 0.95rem;
        margin-top: 10px;
    }

    .update-section {
        margin-top: 2rem;
        padding-top: 1.5rem;
        border-top: 2px dashed #bdc3c7;
    }

    .form-group {
        display: flex;
        align-items: center;
        margin-bottom: 1.5rem;
    }

    .form-group label {
        font-weight: 600;
        color: #2c3e50;
        width: 160px;
        margin-right: 1rem;
        text-align: left;
    }

    .form-control {
        flex-grow: 1;
        padding: 0.75rem 1rem;
        border: 1px solid #ced4da;
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease, box-shadow 0.3s ease;
    }

    .form-control:focus {
        border-color: #3498db;
        box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        outline: none;
    }

    .btn-primary {
        background-color: #3498db;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 0.75rem 1.5rem;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        width: 100%;
        position: relative;
        overflow: hidden;
        transition: background-color 0.3s ease, box-shadow 0.3s ease;
    }

    .btn-primary:hover {
        background-color: #2980b9;
        box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
    }

    .btn-primary::after {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s;
    }

    .btn-primary:hover::after {
        left: 100%;
    }
</style>

</head>
<body>
    <div class="container">
        <div class="card">
            <div class="card-header">
                Información del Alumno
            </div>
            <div class="card-body">
                <%
                    String userEmail = (String) session.getAttribute("email");

                    Connection connection = null;
                    PreparedStatement preparedStatementAlumno = null;
                    ResultSet resultSetAlumno = null;
                    PreparedStatement preparedStatementCarrera = null;
                    ResultSet resultSetCarrera = null;
                    String nombreCarrera = "";
                    String nombre = "";
                    String apellido = "";
                    java.util.Date fechaNacimiento = null;
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    String fechaNacimientoFormatted = "";
                    String direccion = "";
                    String telefono = "";
                    String email = "";
                    int idCarrera = 0;
                    String rol = "";

                    try {
                        Conexion conexion = new Conexion();
                        connection = conexion.conecta();
                        String sqlAlumno = "SELECT nombre, apellido, fecha_nacimiento, direccion, telefono, email, id_carrera, rol FROM alumnos WHERE email = ?";
                        preparedStatementAlumno = connection.prepareStatement(sqlAlumno);
                        preparedStatementAlumno.setString(1, userEmail);
                        resultSetAlumno = preparedStatementAlumno.executeQuery();

                        if (resultSetAlumno.next()) {
                            nombre = resultSetAlumno.getString("nombre");
                            apellido = resultSetAlumno.getString("apellido");
                            fechaNacimiento = resultSetAlumno.getDate("fecha_nacimiento");
                            fechaNacimientoFormatted = (fechaNacimiento != null) ? sdf.format(fechaNacimiento) : "";
                            direccion = resultSetAlumno.getString("direccion");
                            telefono = resultSetAlumno.getString("telefono");
                            email = resultSetAlumno.getString("email");
                            idCarrera = resultSetAlumno.getInt("id_carrera");
                            rol = resultSetAlumno.getString("rol");

                            String sqlCarrera = "SELECT nombre_carrera FROM carreras WHERE id_carrera = ?";
                            preparedStatementCarrera = connection.prepareStatement(sqlCarrera);
                            preparedStatementCarrera.setInt(1, idCarrera);
                            resultSetCarrera = preparedStatementCarrera.executeQuery();

                            if (resultSetCarrera.next()) {
                                nombreCarrera = resultSetCarrera.getString("nombre_carrera");
                            }
                        } else {
                            out.println("<p class='text-danger'>No se encontró información para el email: " + userEmail + "</p>");
                        }

                    } catch (SQLException e) {
                        out.println("<p class='text-danger'>Error al conectar o consultar la base de datos: " + e.getMessage() + "</p>");
                        e.printStackTrace();
                    } finally {
                        try { if (resultSetAlumno != null) resultSetAlumno.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (preparedStatementAlumno != null) preparedStatementAlumno.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (resultSetCarrera != null) resultSetCarrera.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (preparedStatementCarrera != null) preparedStatementCarrera.close(); } catch (SQLException e) { e.printStackTrace(); }
                        try { if (connection != null) connection.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>

                <div class="info-row"><span class="info-label">Nombre:</span> <%= nombre %> <%= apellido %></div>
                <div class="info-row"><span class="info-label">Fecha de Nacimiento:</span> <%= fechaNacimientoFormatted %></div>
                <div class="info-row"><span class="info-label">Email:</span> <%= email %></div>
                <div class="info-row"><span class="info-label">Carrera:</span> <%= nombreCarrera %></div>
                <div class="info-row"><span class="info-label">Rol:</span> <%= rol %></div>

                <div class="update-section">
                    <form action="actualizar_alumno.jsp" method="post">
                        <input type="hidden" name="email" value="<%= userEmail %>">
                        <div class="form-group">
                            <label for="direccion">Dirección:</label>
                            <input type="text" class="form-control" id="direccion" name="direccion" value="<%= direccion %>">
                        </div>
                        <div class="form-group">
                            <label for="telefono">Teléfono:</label>
                            <input type="text" class="form-control" id="telefono" name="telefono" value="<%= telefono %>">
                        </div>
                        <button type="submit" class="btn btn-primary">Actualizar Datos</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>