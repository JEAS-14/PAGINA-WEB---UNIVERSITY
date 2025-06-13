<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page session="true" %>

<%
    // VALIDACIÓN DE SESIÓN INICIAL
    String rol = (String) session.getAttribute("rol");
    Object idProfesorObj = session.getAttribute("id_profesor");
    int idProfesor = (idProfesorObj instanceof Integer) ? (Integer) idProfesorObj : -1;

    // Redirigir si el usuario no es profesor o el ID no es válido
    if (!"profesor".equals(rol) || idProfesor == -1) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp"); // Ajusta esta ruta si es diferente
        return;
    }

    // Obtener ID de clase por GET
    int idClase = -1;
    String initialErrorMessage = null; // Para errores iniciales de ID de clase
    try {
        String idClaseParam = request.getParameter("id_clase");
        if (idClaseParam != null && !idClaseParam.isEmpty()) {
            idClase = Integer.parseInt(idClaseParam);
        } else {
            initialErrorMessage = "Error: ID de clase no proporcionado en la URL.";
        }
    } catch (NumberFormatException e) {
        initialErrorMessage = "Error: ID de clase no válido en la URL.";
    }

    // Declaraciones de objetos de BD que se usarán en el scriptlet
    Connection conn = null; // Conexión principal para toda la página
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String nombreClase = "Clase Desconocida";
    String nombreCurso = "Curso Desconocido";
    String seccionClase = "";
    boolean accesoPermitido = false;
    String classesLoadError = null; // Para errores específicos de la tabla de estudiantes

    // --- BLOQUE PRINCIPAL TRY-CATCH-FINALLY DE LA PÁGINA ---
    // Este try abarca TODA la lógica de base de datos y la generación de contenido.
    try {
        // Solo intentar conectar y cargar datos si no hubo error inicial con el ID de clase
        if (initialErrorMessage == null) {
            conn = new Conexion().conecta();

            // Verificar si la conexión fue exitosa
            if (conn == null || conn.isClosed()) {
                throw new SQLException("No se pudo establecer conexión a la base de datos.");
            }

            // Validar si el profesor tiene acceso a esta clase y obtener sus detalles
            String sqlVal = "SELECT cl.id_clase, cu.nombre_curso, cl.seccion, cl.ciclo, cl.semestre, cl.año_academico FROM clases cl " +
                            "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                            "WHERE cl.id_clase = ? AND cl.id_profesor = ?";
            pstmt = conn.prepareStatement(sqlVal);
            pstmt.setInt(1, idClase);
            pstmt.setInt(2, idProfesor);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                accesoPermitido = true;
                nombreCurso = rs.getString("nombre_curso");
                seccionClase = rs.getString("seccion");
                nombreClase = nombreCurso + " - Sección " + seccionClase + " (" + rs.getString("semestre") + " " + rs.getInt("año_academico") + ")";
            }
            if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
        }
        
        // El resto del HTML se genera aquí, y luego las consultas de estudiantes se hacen dentro de otro try/catch si accesoPermitido.

%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estudiantes de Clase - <%= nombreClase %></title>
    <link rel="icon" type="image/x-icon" href="https://ejemplo.com/favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* CSS general para el diseño de tu sistema (similar al salones_profesor.jsp) */
        :root {
            --primary-color: #002366; /* Azul universitario oscuro */
            --secondary-color: #FFD700; /* Dorado */
            --accent-color: #800000; /* Granate */
            --light-color: #F5F5F5;
            --dark-color: #333333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--light-color);
            color: var(--dark-color);
        }

        .header-main {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .header-main h1 {
            margin: 0;
            font-size: 2em;
            color: var(--secondary-color);
        }

        .content-wrapper {
            max-width: 1200px;
            margin: 30px auto;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-top: 5px solid var(--primary-color);
        }

        h2 {
            color: var(--primary-color);
            text-align: center;
            margin-bottom: 25px;
            font-size: 1.8em;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .table-container {
            overflow-x: auto; /* Para tablas que se desbordan en pantallas pequeñas */
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px 15px;
            border: 1px solid #ddd;
            text-align: left;
        }

        th {
            background-color: var(--primary-color);
            color: white;
            font-weight: 600;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:hover {
            background-color: #f0f0f0;
        }

        .back-button {
            display: inline-block;
            background-color: var(--primary-color);
            color: white;
            padding: 10px 20px;
            margin-top: 30px;
            border-radius: 5px;
            text-decoration: none;
            transition: background-color 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .back-button:hover {
            background-color: #003399;
        }

        .alert-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c2c7;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }

        .badge-status {
            padding: 0.3em 0.6em;
            border-radius: 50rem;
            font-size: 0.8em;
            font-weight: 700;
            color: white;
        }

        .badge-activo { background-color: #28a745; }
        .badge-inactivo { background-color: #6c757d; }
        .badge-egresado { background-color: #007bff; } /* Para egresados */
        .badge-expulsado { background-color: #dc3545; } /* Ejemplo de estado adicional */
    </style>
</head>
<body>

    <div class="header-main">
        <h1>Sistema Universitario</h1>
        <p>Visualización de Estudiantes por Clase</p>
    </div>

    <div class="content-wrapper">
        <% if (initialErrorMessage != null) { %>
            <div class="alert-message">
                <i class="fas fa-exclamation-triangle"></i> <%= initialErrorMessage %>
            </div>
            <div style="text-align: center;">
                <a href="salones_profesor.jsp" class="back-button">🔙 Volver a Mis Clases</a>
            </div>
        <% } else if (classesLoadError != null) { %>
            <div class="alert-message">
                <i class="fas fa-exclamation-triangle"></i> <%= classesLoadError %>
            </div>
            <div style="text-align: center;">
                <a href="salones_profesor.jsp" class="back-button">🔙 Volver a Mis Clases</a>
            </div>
        <% } else if (!accesoPermitido) { %>
            <div class="alert-message" style="background-color: #ffeeba; color: #856404; border-color: #ffeeba;">
                <i class="fas fa-exclamation-circle"></i> No tienes permiso para ver los estudiantes de esta clase.
            </div>
            <div style="text-align: center;">
                <a href="salones_profesor.jsp" class="back-button">🔙 Volver a Mis Clases</a>
            </div>
        <% } else { %>
            <h2><i class="fas fa-users"></i> Estudiantes inscritos en: <%= nombreClase %></h2>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>N°</th>
                            <th>DNI</th>
                            <th>Nombre Completo</th>
                            <th>Email</th>
                            <th>Teléfono</th>
                            <th>Fecha Nac.</th>
                            <th>Estado Inscripción</th>
                            <th>Estado Alumno</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Nuevas declaraciones para este try-catch-finally interno
                            PreparedStatement pstmtEstudiantes = null;
                            ResultSet rsEstudiantes = null;
                            try {
                                String sqlEstudiantes = "SELECT a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, a.email, a.telefono, a.fecha_nacimiento, a.estado AS alumno_estado, i.estado AS inscripcion_estado " +
                                                        "FROM inscripciones i " +
                                                        "JOIN alumnos a ON i.id_alumno = a.id_alumno " +
                                                        "WHERE i.id_clase = ? " +
                                                        "ORDER BY a.apellido_paterno, a.apellido_materno";
                                pstmtEstudiantes = conn.prepareStatement(sqlEstudiantes);
                                pstmtEstudiantes.setInt(1, idClase);
                                rsEstudiantes = pstmtEstudiantes.executeQuery();
                                int count = 1;
                                boolean hayEstudiantes = false;

                                while (rsEstudiantes.next()) {
                                    hayEstudiantes = true;
                                    String estadoInscripcion = rsEstudiantes.getString("inscripcion_estado");
                                    String estadoAlumno = rsEstudiantes.getString("alumno_estado");
                                    String badgeInscripcionClass = "badge-inactivo"; // Default
                                    String badgeAlumnoClass = "badge-inactivo"; // Default

                                    if ("inscrito".equals(estadoInscripcion)) badgeInscripcionClass = "badge-activo";
                                    // Puedes añadir más condiciones para el estado de inscripción si hay más opciones.

                                    if ("activo".equals(estadoAlumno)) badgeAlumnoClass = "badge-activo";
                                    else if ("egresado".equals(estadoAlumno)) badgeAlumnoClass = "badge-egresado";
                                    // Agrega más condiciones si tienes otros estados de alumno (ej. inactivo, expulsado)

                        %>
                        <tr>
                            <td><%= count++ %></td>
                            <td><%= rsEstudiantes.getString("dni") %></td>
                            <td><%= rsEstudiantes.getString("nombre") %> <%= rsEstudiantes.getString("apellido_paterno") %> <%= rsEstudiantes.getString("apellido_materno") != null ? rsEstudiantes.getString("apellido_materno") : "" %></td>
                            <td><%= rsEstudiantes.getString("email") %></td>
                            <td><%= rsEstudiantes.getString("telefono") != null ? rsEstudiantes.getString("telefono") : "N/A" %></td>
                            <td><%= rsEstudiantes.getDate("fecha_nacimiento") %></td>
                            <td><span class="badge-status <%= badgeInscripcionClass %>"><%= estadoInscripcion.toUpperCase() %></span></td>
                            <td><span class="badge-status <%= badgeAlumnoClass %>"><%= estadoAlumno.toUpperCase() %></span></td>
                        </tr>
                        <%
                                }
                                if (!hayEstudiantes) {
                        %>
                        <tr>
                            <td colspan="8" style="text-align: center; color: #666;">No hay estudiantes inscritos en esta clase.</td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) { // <-- CAMBIO AQUÍ: Catch genérico para cualquier excepción
                                classesLoadError = "Error al cargar la lista de estudiantes: " + e.getMessage();
                                e.printStackTrace();
                        %>
                            <tr><td colspan="8" class="alert-message"><%= classesLoadError %></td></tr>
                        <%
                            } finally {
                                // Cierre de recursos de este try-catch-finally interno
                                if (pstmtEstudiantes != null) { try { pstmtEstudiantes.close(); } catch (SQLException ignore) {} }
                                if (rsEstudiantes != null) { try { rsEstudiantes.close(); } catch (SQLException ignore) {} }
                            }
                        %>
                    </tbody>
                </table>
            </div>
            <div style="text-align: center;">
                <a href="salones_profesor.jsp" class="back-button">🔙 Volver a Mis Clases</a>
            </div>
        <% } %>
    </div>

<%
    } finally {
        // Cierre final de la conexión principal abierta al inicio del JSP
        if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
    }
%>
</body>
</html>