<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Postulación - UGIC</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OerSvFwwjofx2zWfKzS0sVbF/HjFwprh3P5d" crossorigin="anonymous">
    <link rel="stylesheet" href="css/estilos.css">
    <style>
        /* Estilos específicos para este formulario si no están en estilos.css */
        body {
            background-color: #f8f9fa;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            margin-top: 50px;
            margin-bottom: 50px;
        }
        h1 {
            color: #007bff;
            margin-bottom: 30px;
            text-align: center;
        }
        .form-label {
            font-weight: 600;
        }
        .btn-primary {
            width: 100%;
            padding: 10px;
            font-size: 1.1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4">Formulario de Postulación a la Universidad UGIC</h1>
        
        <%
            // Mensaje de error si viene de una redirección (desde procesarRegistroPostulante.jsp)
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null && !errorMessage.isEmpty()) {
        %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            }
        %>

        <form action="procesarRegistroPostulante.jsp" method="post">
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="dni" class="form-label">DNI:</label>
                    <input type="text" class="form-control" id="dni" name="dni" required maxlength="8" pattern="[0-9]{8}" title="El DNI debe tener 8 dígitos numéricos.">
                </div>
                <div class="col-md-6 mb-3">
                    <label for="nombre" class="form-label">Nombre:</label>
                    <input type="text" class="form-control" id="nombre" name="nombre" required>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="apellido_paterno" class="form-label">Apellido Paterno:</label>
                    <input type="text" class="form-control" id="apellido_paterno" name="apellido_paterno" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label for="apellido_materno" class="form-label">Apellido Materno:</label>
                    <input type="text" class="form-control" id="apellido_materno" name="apellido_materno">
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="fecha_nacimiento" class="form-label">Fecha de Nacimiento:</label>
                    <input type="date" class="form-control" id="fecha_nacimiento" name="fecha_nacimiento" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label for="telefono" class="form-label">Teléfono:</label>
                    <input type="text" class="form-control" id="telefono" name="telefono" pattern="[0-9]{9}" title="El teléfono debe tener 9 dígitos numéricos.">
                </div>
            </div>
            
            <div class="mb-3">
                <label for="direccion" class="form-label">Dirección:</label>
                <input type="text" class="form-control" id="direccion" name="direccion">
            </div>

            <div class="mb-3">
                <label for="email_personal" class="form-label">Email Personal:</label>
                <input type="email" class="form-control" id="email_personal" name="email_personal" required>
            </div>

            <div class="mb-4">
                <label for="id_carrera_postulacion" class="form-label">Carrera a la que postula:</label>
                <select class="form-select" id="id_carrera_postulacion" name="id_carrera_postulacion" required>
                    <option value="">Seleccione una carrera</option>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            Conexion c = new Conexion();
                            conn = c.conecta();
                            String sql = "SELECT id_carrera, nombre_carrera FROM carreras WHERE estado = 'activo' ORDER BY nombre_carrera";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                int idCarrera = rs.getInt("id_carrera");
                                String nombreCarrera = rs.getString("nombre_carrera");
                    %>
                                <option value="<%= idCarrera %>"><%= nombreCarrera %></option>
                    <%
                            }
                        } catch (SQLException e) {
                            out.println("<option value=''>Error al cargar carreras</option>");
                            System.err.println("Error SQL al cargar carreras: " + e.getMessage());
                        } catch (ClassNotFoundException e) {
                            out.println("<option value=''>Error de configuración: Driver no encontrado</option>");
                            System.err.println("Error ClassNotFound al cargar driver: " + e.getMessage());
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignore */ }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignore */ }
                            if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
                        }
                    %>
                </select>
            </div>

            <button type="submit" class="btn btn-primary">Continuar al Examen</button>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>
