<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.util.List, java.util.Map, java.util.UUID, java.util.ArrayList" %>
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
    // Recuperar datos de la sesión
    Integer id_postulante_actual = (Integer) session.getAttribute("id_postulante_actual");
    List<Integer> idsPreguntasExamen = (List<Integer>) session.getAttribute("ids_preguntas_examen");
    Map<Integer, String> respuestasCorrectasMap = (Map<Integer, String>) session.getAttribute("respuestas_correctas_map");
    Integer id_carrera_postulacion = (Integer) session.getAttribute("id_carrera_postulacion");
    Integer totalPreguntas = (Integer) session.getAttribute("total_preguntas_examen");

    // Redirigir si falta información crucial en la sesión
    if (id_postulante_actual == null || idsPreguntasExamen == null || idsPreguntasExamen.isEmpty() || respuestasCorrectasMap == null || totalPreguntas == null) {
        response.sendRedirect("postulacion_registro.jsp?error=sesion_o_datos_de_examen_faltantes");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int puntaje = 0;
    boolean aprobado = false;
    String mensajeResultado = "";
    String claseResultado = ""; // Para aplicar estilos CSS de Bootstrap (alert-success/alert-danger)
    String correoInstitucional = "";
    String passwordGenerada = "";

    try {
        Conexion c = new Conexion();
        conn = c.conecta();
        conn.setAutoCommit(false); // Iniciar transacción

        // 1. Evaluar las respuestas del usuario y guardar en respuestas_postulacion
        String sqlInsertRespuesta = "INSERT INTO respuestas_postulacion (id_postulante, id_pregunta, respuesta_elegida, es_correcta) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sqlInsertRespuesta); // Preparar una vez para reutilizar

        for (int idPregunta : idsPreguntasExamen) {
            String respuestaUsuario = request.getParameter("pregunta_" + idPregunta);
            String respuestaCorrecta = respuestasCorrectasMap.get(idPregunta);
            boolean esCorrecta = false;

            if (respuestaUsuario != null && respuestaUsuario.equals(respuestaCorrecta)) {
                puntaje++;
                esCorrecta = true;
            }

            // Guardar la respuesta del usuario en la tabla respuestas_postulacion
            pstmt.setInt(1, id_postulante_actual);
            pstmt.setInt(2, idPregunta);
            pstmt.setString(3, respuestaUsuario != null ? respuestaUsuario : "");
            pstmt.setBoolean(4, esCorrecta);
            pstmt.executeUpdate();
            pstmt.clearParameters(); // Limpiar parámetros para la siguiente iteración
        }
        cerrarRecursos(null, pstmt); // Cierro el pstmt de inserción

        // 2. Determinar estado de aprobación y actualizar en postulantes
        // Criterio de aprobación: ejemplo, 60% de preguntas correctas
        double porcentajeAprobacionMinimo = 0.60; 
        if (totalPreguntas > 0 && (double) puntaje / totalPreguntas >= porcentajeAprobacionMinimo) {
            aprobado = true;
            mensajeResultado = "¡Felicidades! Has aprobado el examen y has sido admitido a la universidad.";
            claseResultado = "alert-success";
        } else {
            aprobado = false;
            mensajeResultado = "Lo sentimos, no has alcanzado el puntaje mínimo para ser admitido en esta ocasión.";
            claseResultado = "alert-danger";
        }

        String estadoPostulacion = aprobado ? "aprobado_examen" : "desaprobado_examen";
        String sqlUpdatePostulante = "UPDATE postulantes SET puntaje_examen = ?, estado_postulacion = ? WHERE id_postulante = ?";
        pstmt = conn.prepareStatement(sqlUpdatePostulante);
        pstmt.setInt(1, puntaje);
        pstmt.setString(2, estadoPostulacion);
        pstmt.setInt(3, id_postulante_actual);
        pstmt.executeUpdate();
        cerrarRecursos(null, pstmt);

        // 3. Si el postulante aprueba, crear su cuenta de alumno
        if (aprobado) {
            // Obtener datos completos del postulante
            String nombrePostulante = "";
            String apellidoPaternoPostulante = "";
            String apellidoMaternoPostulante = "";
            String dniPostulante = "";
            String fechaNacimientoPostulante = "";
            String direccionPostulante = "";
            String telefonoPostulante = "";
            String emailPersonalPostulante = ""; // También necesitamos el email personal original

            String sqlGetPostulanteData = "SELECT dni, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, direccion, telefono, email_personal FROM postulantes WHERE id_postulante = ?";
            pstmt = conn.prepareStatement(sqlGetPostulanteData);
            pstmt.setInt(1, id_postulante_actual);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dniPostulante = rs.getString("dni");
                nombrePostulante = rs.getString("nombre");
                apellidoPaternoPostulante = rs.getString("apellido_paterno");
                apellidoMaternoPostulante = rs.getString("apellido_materno");
                fechaNacimientoPostulante = rs.getString("fecha_nacimiento");
                direccionPostulante = rs.getString("direccion");
                telefonoPostulante = rs.getString("telefono");
                emailPersonalPostulante = rs.getString("email_personal");
            }
            cerrarRecursos(rs, pstmt);

            // Generar correo institucional (ejemplo: inicial_apellido.nombre@est.universidad.edu.pe)
            String baseEmailPart = nombrePostulante.toLowerCase().substring(0, 1) + 
                                  apellidoPaternoPostulante.toLowerCase().replaceAll("\\s", "");
            if (apellidoMaternoPostulante != null && !apellidoMaternoPostulante.isEmpty()) {
                baseEmailPart += apellidoMaternoPostulante.toLowerCase().replaceAll("\\s", "");
            }
            baseEmailPart = baseEmailPart.replaceAll("[^a-zA-Z0-9]", ""); // Limpiar de caracteres especiales

            correoInstitucional = baseEmailPart + "@est.universidad.edu.pe";
            
            // Lógica para asegurar que el email sea único
            int emailCounter = 0;
            String originalCorreoInstitucional = correoInstitucional;
            while (true) {
                String checkEmailSql = "SELECT COUNT(*) FROM alumnos WHERE email = ?";
                pstmt = conn.prepareStatement(checkEmailSql);
                pstmt.setString(1, correoInstitucional);
                rs = pstmt.executeQuery();
                rs.next();
                if (rs.getInt(1) == 0) {
                    cerrarRecursos(rs, pstmt);
                    break; // Correo es único
                }
                cerrarRecursos(rs, pstmt);
                emailCounter++;
                correoInstitucional = baseEmailPart + emailCounter + "@est.universidad.edu.pe";
            }

            // Generar contraseña temporal (¡IMPORTANTE: Solo para DEMO! En prod, usar HASHING como BCrypt)
            passwordGenerada = "UGIC" + UUID.randomUUID().toString().substring(0, 6).toUpperCase(); 

            // Insertar en la tabla alumnos
            String sqlInsertAlumno = "INSERT INTO alumnos (dni, nombre, apellido_paterno, apellido_materno, direccion, telefono, fecha_nacimiento, email, id_carrera, password, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'activo')";
            pstmt = conn.prepareStatement(sqlInsertAlumno);
            pstmt.setString(1, dniPostulante);
            pstmt.setString(2, nombrePostulante);
            pstmt.setString(3, apellidoPaternoPostulante);
            pstmt.setString(4, apellidoMaternoPostulante);
            pstmt.setString(5, direccionPostulante);
            pstmt.setString(6, telefonoPostulante);
            pstmt.setString(7, fechaNacimientoPostulante);
            pstmt.setString(8, correoInstitucional);
            pstmt.setInt(9, id_carrera_postulacion);
            pstmt.setString(10, passwordGenerada); 
            pstmt.executeUpdate();
            cerrarRecursos(null, pstmt);

            // Actualizar el estado del postulante a "registrado_alumno" y guardar credenciales
            String sqlUpdatePostulanteCredenciales = "UPDATE postulantes SET estado_postulacion = 'registrado_alumno', correo_institucional = ?, password_generada = ? WHERE id_postulante = ?";
            pstmt = conn.prepareStatement(sqlUpdatePostulanteCredenciales);
            pstmt.setString(1, correoInstitucional);
            pstmt.setString(2, passwordGenerada);
            pstmt.setInt(3, id_postulante_actual);
            pstmt.executeUpdate();
            cerrarRecursos(null, pstmt);
        }

        conn.commit(); // Confirmar la transacción

    } catch (SQLException e) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException rbex) { /* ignore */ }
        }
        mensajeResultado = "Ocurrió un error en la base de datos al procesar tu examen. Por favor, inténtalo de nuevo o contacta con soporte: " + e.getMessage();
        claseResultado = "alert-danger";
        System.err.println("SQLException en procesarExamenPostulacion.jsp: " + e.getMessage());
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        mensajeResultado = "Error al cargar el driver de la base de datos. Contacta con soporte técnico.";
        claseResultado = "alert-danger";
        System.err.println("ClassNotFoundException en procesarExamenPostulacion.jsp: " + e.getMessage());
        e.printStackTrace();
    } finally {
        // Asegúrate de cerrar todos los recursos de la base de datos en finally
        cerrarRecursos(rs, pstmt);
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }

        // Limpiar atributos de sesión relacionados con el examen una vez procesado
        session.removeAttribute("id_postulante_actual");
        session.removeAttribute("ids_preguntas_examen");
        session.removeAttribute("respuestas_correctas_map");
        session.removeAttribute("id_carrera_postulacion");
        session.removeAttribute("total_preguntas_examen");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultado de Postulación - UGIC</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OerSvFwwjofx2zWfKzS0sVbF/HjFwprh3P5d" crossorigin="anonymous">
    <link rel="stylesheet" href="css/estilos.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            background-color: #ffffff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            margin-top: 80px;
            margin-bottom: 80px;
            text-align: center;
        }
        h1 {
            color: #007bff;
            margin-bottom: 30px;
            font-weight: 700;
        }
        .alert {
            padding: 20px;
            font-size: 1.1rem;
            line-height: 1.6;
            border-radius: 6px;
            margin-bottom: 30px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .alert strong {
            font-weight: 700;
            color: inherit; /* Hereda el color del texto del alert */
        }
        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
            padding: 10px 25px;
            font-size: 1rem;
            border-radius: 5px;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #545b62;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4">Resultados de tu Postulación</h1>
        <div class="<%= claseResultado %>" role="alert">
            <p><%= mensajeResultado %></p>
            <p class="mb-3">Tu puntaje final es: <strong><%= puntaje %> de <%= totalPreguntas %></strong></p>
            <%
                if (aprobado) {
            %>
                <p class="mt-4">¡Bienvenido a la Universidad UGIC!</p>
                <p>Tu correo institucional es: <strong class="text-primary"><%= correoInstitucional %></strong></p>
                <p>Tu contraseña temporal es: <strong class="text-primary"><%= passwordGenerada %></strong></p>
                <p class="mt-3">Por favor, usa estas credenciales para iniciar sesión en el <a href="login.jsp" class="alert-link">portal de alumnos</a>.</p>
            <%
                }
            %>
        </div>
        <p class="mt-4">
            <a href="index.jsp" class="btn btn-secondary">Volver a la página principal</a>
        </p>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>
