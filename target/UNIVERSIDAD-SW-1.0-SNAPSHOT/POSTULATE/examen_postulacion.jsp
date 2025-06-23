<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.Collections" %>
<%@ page import="java.util.Map, java.util.HashMap" %>
<%@ page session="true" %>

<%!
    // Método para cerrar recursos de BD
    private static void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
            /* Ignorar */ }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
            /* Ignorar */ }
    }
%>

<%
    // Asegurarse de que el postulante ha sido registrado y el ID está en sesión
    Integer id_postulante_actual = (Integer) session.getAttribute("id_postulante_actual");
    Integer id_carrera_postulacion = (Integer) session.getAttribute("id_carrera_postulacion");

    if (id_postulante_actual == null) {
        response.sendRedirect("postulacion_registro.jsp?error=sesion_no_iniciada");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    List<Integer> idsPreguntas = new ArrayList<>(); // Para almacenar los IDs de las preguntas seleccionadas
    Map<Integer, String> respuestasCorrectasMap = new HashMap<>(); // Para almacenar las respuestas correctas
    String errorMessage = null;

    try {
        Conexion c = new Conexion();
        conn = c.conecta();

        String sqlSelectPreguntas = "SELECT id_pregunta, texto_pregunta, opcion_a, opcion_b, opcion_c, opcion_d, respuesta_correcta FROM preguntas_examen WHERE estado = 'activo'";
        
        // Opcional: Filtrar por carrera. Si id_carrera es null en preguntas_examen, son generales.
        // Si quieres solo preguntas específicas de la carrera, cambia el WHERE.
        // if (id_carrera_postulacion != null) {
        //     sqlSelectPreguntas += " AND (id_carrera IS NULL OR id_carrera = ?)";
        // }
        
        sqlSelectPreguntas += " ORDER BY RAND() LIMIT 25"; // Selecciona 25 preguntas al azar

        pstmt = conn.prepareStatement(sqlSelectPreguntas);
        // if (id_carrera_postulacion != null) { pstmt.setInt(1, id_carrera_postulacion); }

        rs = pstmt.executeQuery();

        StringBuilder preguntasHtml = new StringBuilder();
        int contadorPreguntas = 1;

        while (rs.next()) {
            int idPregunta = rs.getInt("id_pregunta");
            String textoPregunta = rs.getString("texto_pregunta");
            String opcionA = rs.getString("opcion_a");
            String opcionB = rs.getString("opcion_b");
            String opcionC = rs.getString("opcion_c");
            String opcionD = rs.getString("opcion_d");
            String respuestaCorrecta = rs.getString("respuesta_correcta");

            idsPreguntas.add(idPregunta); // Guardar el ID de la pregunta para luego validar
            respuestasCorrectasMap.put(idPregunta, respuestaCorrecta); // Guardar la respuesta correcta

            preguntasHtml.append("<div class='card mb-3 pregunta'>");
            preguntasHtml.append("<div class='card-body'>");
            preguntasHtml.append("<h5 class='card-title mb-3'>Pregunta ").append(contadorPreguntas).append(": ").append(textoPregunta).append("</h5>");
            preguntasHtml.append("<div class='form-check mb-2'>");
            preguntasHtml.append("<input class='form-check-input' type='radio' id='p").append(idPregunta).append("_a' name='pregunta_").append(idPregunta).append("' value='a' required>");
            preguntasHtml.append("<label class='form-check-label' for='p").append(idPregunta).append("_a'>A) ").append(opcionA).append("</label>");
            preguntasHtml.append("</div>");
            preguntasHtml.append("<div class='form-check mb-2'>");
            preguntasHtml.append("<input class='form-check-input' type='radio' id='p").append(idPregunta).append("_b' name='pregunta_").append(idPregunta).append("' value='b'>");
            preguntasHtml.append("<label class='form-check-label' for='p").append(idPregunta).append("_b'>B) ").append(opcionB).append("</label>");
            preguntasHtml.append("</div>");
            preguntasHtml.append("<div class='form-check mb-2'>");
            preguntasHtml.append("<input class='form-check-input' type='radio' id='p").append(idPregunta).append("_c' name='pregunta_").append(idPregunta).append("' value='c'>");
            preguntasHtml.append("<label class='form-check-label' for='p").append(idPregunta).append("_c'>C) ").append(opcionC).append("</label>");
            preguntasHtml.append("</div>");
            preguntasHtml.append("<div class='form-check mb-2'>");
            preguntasHtml.append("<input class='form-check-input' type='radio' id='p").append(idPregunta).append("_d' name='pregunta_").append(idPregunta).append("' value='d'>");
            preguntasHtml.append("<label class='form-check-label' for='p").append(idPregunta).append("_d'>D) ").append(opcionD).append("</label>");
            preguntasHtml.append("</div>");
            preguntasHtml.append("</div>");
            preguntasHtml.append("</div>");
            contadorPreguntas++;
        }

        // Guardar la lista de IDs de preguntas y sus respuestas correctas en la sesión
        session.setAttribute("ids_preguntas_examen", idsPreguntas);
        session.setAttribute("respuestas_correctas_map", respuestasCorrectasMap); // Guardar el mapa de respuestas correctas
        session.setAttribute("total_preguntas_examen", idsPreguntas.size()); // Guardar el total de preguntas

%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examen de Postulación - UGIC</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OerSvFwwjofx2zWfKzS0sVbF/HjFwprh3P5d" crossorigin="anonymous">
    <link rel="stylesheet" href="css/estilos.css">
    <style>
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
        .pregunta .card-title {
            color: #343a40;
            font-size: 1.15rem;
            font-weight: 600;
        }
        .form-check-label {
            font-size: 1rem;
            color: #555;
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
        <h1 class="mb-4">Examen de Conocimientos para Postulantes</h1>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <form action="procesarExamenPostulacion.jsp" method="post">
            <%= preguntasHtml.toString() %>
            <% if (idsPreguntas.isEmpty()) { %>
                <div class="alert alert-warning" role="alert">
                    No se pudieron cargar las preguntas del examen. Por favor, contacta con soporte.
                </div>
            <% } %>
            <button type="submit" class="btn btn-primary mt-4">Enviar Examen</button>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>
<%
    } catch (SQLException e) {
        errorMessage = "Error de base de datos al cargar preguntas: " + e.getMessage();
        System.err.println("SQLException en examen_postulacion.jsp: " + e.getMessage());
        e.printStackTrace();
        // Mostrar error en la página
        out.println("<div class='container mt-5'><div class='alert alert-danger' role='alert'>Error al cargar el examen: " + errorMessage + "</div></div>");
    } catch (ClassNotFoundException e) {
        errorMessage = "Error al cargar el driver de la base de datos. Contacta con soporte técnico.";
        System.err.println("ClassNotFoundException en examen_postulacion.jsp: " + e.getMessage());
        e.printStackTrace();
        out.println("<div class='container mt-5'><div class='alert alert-danger' role='alert'>Error al cargar el examen: " + errorMessage + "</div></div>");
    } finally {
        cerrarRecursos(rs, pstmt);
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
    }
%>
