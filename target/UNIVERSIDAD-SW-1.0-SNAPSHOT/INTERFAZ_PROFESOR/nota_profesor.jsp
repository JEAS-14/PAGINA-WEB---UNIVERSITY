<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%@ page import="java.time.LocalDate, java.time.format.TextStyle, java.util.Locale" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ page session="true" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    // Helper method to parse a string to Double, returning null if empty or invalid
    private Double parseGrade(String gradeStr) {
        if (gradeStr == null || gradeStr.trim().isEmpty()) {
            return null;
        }
        try {
            double grade = Double.parseDouble(gradeStr.trim());
            // Optional: enforce range 0-20 if not already done by DB checks
            return Math.max(0.00, Math.min(20.00, grade));
        } catch (NumberFormatException e) {
            return null; // Or throw an exception for clearer error handling
        }
    }
%>

<%
    // --- Variables para la información del profesor logueado ---
    Object idObj = session.getAttribute("id_profesor");
    int idProfesor = -1; // Usamos idProfesor para ser más explícitos
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "No asignada"; // Valor por defecto
    
    if (idObj != null) {
        idProfesor = Integer.parseInt(idObj.toString());
    } else {
        // Si no hay ID de profesor en sesión, redirige al login
        response.sendRedirect(request.getContextPath() + "/Plataforma.jsp"); // Ajusta la ruta a tu página de login
        return; // Termina la ejecución del JSP
    }

    // --- Variables para la lógica de notas ---
    String idClaseParam = request.getParameter("id_clase");
    String nombreClase = "Clase No Seleccionada";
    String codigoClase = "";
    String aulaClase = "";
    String semestreClase = "";
    String anioAcademicoClase = "";
    
    // Listas para almacenar datos
    List<Map<String, String>> clasesDelProfesor = new ArrayList<>();
    List<Map<String, String>> estudiantesDeClase = new ArrayList<>();
    
    // Mensajes de éxito/error después de guardar
    String mensajeFeedback = "";
    String tipoMensajeFeedback = ""; // 'success' o 'danger'

    // --- Conexión y recursos de DB ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Conexion conexionUtil = new Conexion();
        conn = conexionUtil.conecta();

        // 1. Obtener información básica del profesor
        String sqlProfesor = "SELECT p.nombre, p.apellido_paterno, p.apellido_materno, p.email, f.nombre_facultad as facultad " +
                             "FROM profesores p JOIN facultades f ON p.id_facultad = f.id_facultad " +
                             "WHERE p.id_profesor = ?";
        pstmt = conn.prepareStatement(sqlProfesor);
        pstmt.setInt(1, idProfesor);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido_paterno") +
                             (rs.getString("apellido_materno") != null ? " " + rs.getString("apellido_materno") : "");
            emailProfesor = rs.getString("email");
            facultadProfesor = rs.getString("facultad");
        }
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();

        // --- INICIO LÓGICA DE PROCESAMIENTO POST (Guardar Notas) ---
        if ("POST".equalsIgnoreCase(request.getMethod()) && idClaseParam != null && !idClaseParam.isEmpty()) {
            int idClaseGuardar = Integer.parseInt(idClaseParam);
            
            // Re-verificar que esta clase pertenece al profesor logueado antes de guardar
            String sqlCheckClass = "SELECT COUNT(*) FROM clases WHERE id_clase = ? AND id_profesor = ?";
            pstmt = conn.prepareStatement(sqlCheckClass);
            pstmt.setInt(1, idClaseGuardar);
            pstmt.setInt(2, idProfesor);
            rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                mensajeFeedback = "Error: La clase seleccionada no es válida o no le pertenece.";
                tipoMensajeFeedback = "danger";
                response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/nota_profesor.jsp?mensaje=" + java.net.URLEncoder.encode(mensajeFeedback, "UTF-8") + "&tipo=" + tipoMensajeFeedback);
                return;
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            // Obtener todos los id_inscripcion de los alumnos en esta clase
            String sqlInscripcionesClase = "SELECT id_inscripcion FROM inscripciones WHERE id_clase = ? AND estado = 'inscrito'";
            pstmt = conn.prepareStatement(sqlInscripcionesClase);
            pstmt.setInt(1, idClaseGuardar);
            rs = pstmt.executeQuery();
            
            List<Integer> idsInscripcionEnClase = new ArrayList<>();
            while(rs.next()) {
                idsInscripcionEnClase.add(rs.getInt("id_inscripcion"));
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            int notasAfectadas = 0;
            conn.setAutoCommit(false); // Iniciar transacción

            String sqlCheckNotaExists = "SELECT id_nota FROM notas WHERE id_inscripcion = ?";
            String sqlInsertNota = "INSERT INTO notas (id_inscripcion, nota1, nota2, nota3, examen_parcial, examen_final) VALUES (?, ?, ?, ?, ?, ?)";
            String sqlUpdateNota = "UPDATE notas SET nota1 = ?, nota2 = ?, nota3 = ?, examen_parcial = ?, examen_final = ? WHERE id_inscripcion = ?";

            for (Integer idInscripcion : idsInscripcionEnClase) {
                String nota1Str = request.getParameter("nota1_" + idInscripcion);
                String nota2Str = request.getParameter("nota2_" + idInscripcion);
                String nota3Str = request.getParameter("nota3_" + idInscripcion);
                String examenParcialStr = request.getParameter("examen_parcial_" + idInscripcion);
                String examenFinalStr = request.getParameter("examen_final_" + idInscripcion);

                Double nota1 = parseGrade(nota1Str);
                Double nota2 = parseGrade(nota2Str);
                Double nota3 = parseGrade(nota3Str);
                Double examenParcial = parseGrade(examenParcialStr);
                Double examenFinal = parseGrade(examenFinalStr);
                
                // Check if a note record exists for this inscription
                boolean noteExists = false;
                pstmt = conn.prepareStatement(sqlCheckNotaExists);
                pstmt.setInt(1, idInscripcion);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    noteExists = true;
                }
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();

                if (noteExists) {
                    // Update existing record
                    pstmt = conn.prepareStatement(sqlUpdateNota);
                    if (nota1 != null) pstmt.setDouble(1, nota1); else pstmt.setNull(1, Types.DECIMAL);
                    if (nota2 != null) pstmt.setDouble(2, nota2); else pstmt.setNull(2, Types.DECIMAL);
                    if (nota3 != null) pstmt.setDouble(3, nota3); else pstmt.setNull(3, Types.DECIMAL);
                    if (examenParcial != null) pstmt.setDouble(4, examenParcial); else pstmt.setNull(4, Types.DECIMAL);
                    if (examenFinal != null) pstmt.setDouble(5, examenFinal); else pstmt.setNull(5, Types.DECIMAL);
                    pstmt.setInt(6, idInscripcion);
                    pstmt.executeUpdate();
                    notasAfectadas++;
                } else {
                    // Insert new record only if at least one grade is provided
                    if (nota1 != null || nota2 != null || nota3 != null || examenParcial != null || examenFinal != null) {
                        pstmt = conn.prepareStatement(sqlInsertNota);
                        pstmt.setInt(1, idInscripcion);
                        if (nota1 != null) pstmt.setDouble(2, nota1); else pstmt.setNull(2, Types.DECIMAL);
                        if (nota2 != null) pstmt.setDouble(3, nota2); else pstmt.setNull(3, Types.DECIMAL);
                        if (nota3 != null) pstmt.setDouble(4, nota3); else pstmt.setNull(4, Types.DECIMAL);
                        if (examenParcial != null) pstmt.setDouble(5, examenParcial); else pstmt.setNull(5, Types.DECIMAL);
                        if (examenFinal != null) pstmt.setDouble(6, examenFinal); else pstmt.setNull(6, Types.DECIMAL);
                        pstmt.executeUpdate();
                        notasAfectadas++;
                    }
                }
                if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} } // Close after each use
            }
            conn.commit(); // Confirmar transacción
            mensajeFeedback = "Notas guardadas exitosamente para " + notasAfectadas + " alumnos.";
            tipoMensajeFeedback = "success";

        } // Fin del bloque POST de procesamiento

        // Recuperar mensaje de feedback si viene de una redirección previa
        String mensajeParam = request.getParameter("mensaje");
        String tipoParam = request.getParameter("tipo");
        if (mensajeParam != null && !mensajeParam.isEmpty()) {
            mensajeFeedback = java.net.URLDecoder.decode(mensajeParam, "UTF-8");
            tipoMensajeFeedback = tipoParam != null ? tipoParam : "";
        }

        // --- INICIO LÓGICA DE VISUALIZACIÓN GET (o después de POST) ---
        if (idClaseParam == null || idClaseParam.isEmpty()) {
            // Si no se ha seleccionado una clase, listar todas las clases del profesor
            String sqlClasesProfesor = "SELECT cl.id_clase, cu.nombre_curso, cl.seccion, cl.semestre, cl.año_academico, h.aula " +
                                       "FROM clases cl " +
                                       "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                                       "JOIN horarios h ON cl.id_horario = h.id_horario " +
                                       "WHERE cl.id_profesor = ? AND cl.estado = 'activo' " +
                                       "ORDER BY cl.año_academico DESC, cl.semestre DESC, cu.nombre_curso, cl.seccion";
            pstmt = conn.prepareStatement(sqlClasesProfesor);
            pstmt.setInt(1, idProfesor);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> clase = new HashMap<>();
                clase.put("id_clase", String.valueOf(rs.getInt("id_clase")));
                clase.put("nombre_curso", rs.getString("nombre_curso"));
                clase.put("seccion", rs.getString("seccion"));
                clase.put("semestre", rs.getString("semestre"));
                clase.put("anio_academico", String.valueOf(rs.getInt("año_academico")));
                clase.put("aula", rs.getString("aula"));
                clasesDelProfesor.add(clase);
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

        } else {
            // Si se ha seleccionado una clase, mostrar sus estudiantes y notas
            int idClaseMostar = Integer.parseInt(idClaseParam);
            // Obtener detalles de la clase seleccionada
            String sqlDetalleClase = "SELECT cu.nombre_curso, cu.codigo_curso, cl.seccion, h.aula, cl.semestre, cl.año_academico " +
                                     "FROM clases cl " +
                                     "JOIN cursos cu ON cl.id_curso = cu.id_curso " +
                                     "JOIN horarios h ON cl.id_horario = h.id_horario " +
                                     "WHERE cl.id_clase = ? AND cl.id_profesor = ?";
            pstmt = conn.prepareStatement(sqlDetalleClase);
            pstmt.setInt(1, idClaseMostar);
            pstmt.setInt(2, idProfesor);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                nombreClase = rs.getString("nombre_curso");
                codigoClase = rs.getString("codigo_curso");
                aulaClase = rs.getString("aula");
                semestreClase = rs.getString("semestre");
                anioAcademicoClase = String.valueOf(rs.getInt("año_academico"));
            } else {
                // Si la clase no pertenece a este profesor o no existe, redirigir
                response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/nota_profesor.jsp");
                return;
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();

            // Obtener lista de estudiantes inscritos en la clase seleccionada y sus notas
            String sqlEstudiantes = "SELECT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, " +
                                    "i.id_inscripcion, n.nota1, n.nota2, n.nota3, n.examen_parcial, n.examen_final, n.nota_final, n.estado " +
                                    "FROM inscripciones i " +
                                    "JOIN alumnos a ON i.id_alumno = a.id_alumno " +
                                    "LEFT JOIN notas n ON i.id_inscripcion = n.id_inscripcion " +
                                    "WHERE i.id_clase = ? AND i.estado = 'inscrito' " +
                                    "ORDER BY a.apellido_paterno, a.apellido_materno, a.nombre";
            pstmt = conn.prepareStatement(sqlEstudiantes);
            pstmt.setInt(1, idClaseMostar);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, String> estudiante = new HashMap<>();
                estudiante.put("id_inscripcion", String.valueOf(rs.getInt("id_inscripcion")));
                estudiante.put("dni", rs.getString("dni"));
                estudiante.put("nombre_completo", rs.getString("nombre") + " " +
                                                  rs.getString("apellido_paterno") + " " +
                                                  (rs.getString("apellido_materno") != null ? rs.getString("apellido_materno") : ""));
                estudiante.put("nota1", rs.getString("nota1") != null ? rs.getString("nota1") : "");
                estudiante.put("nota2", rs.getString("nota2") != null ? rs.getString("nota2") : "");
                estudiante.put("nota3", rs.getString("nota3") != null ? rs.getString("nota3") : "");
                estudiante.put("examen_parcial", rs.getString("examen_parcial") != null ? rs.getString("examen_parcial") : "");
                estudiante.put("examen_final", rs.getString("examen_final") != null ? rs.getString("examen_final") : "");
                estudiante.put("nota_final", rs.getString("nota_final") != null ? rs.getString("nota_final") : "N/A");
                estudiante.put("estado_nota", rs.getString("estado") != null ? rs.getString("estado") : "pendiente");
                estudiantesDeClase.add(estudiante);
            }
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }

    } catch (Exception e) { // Captura cualquier excepción que ocurra
        System.err.println("ERROR general en nota_profesor.jsp: " + e.getMessage());
        e.printStackTrace();
        mensajeFeedback = "Ocurrió un error inesperado: " + e.getMessage();
        tipoMensajeFeedback = "danger";
        try { if (conn != null) conn.rollback(); } catch (SQLException rbex) { rbex.printStackTrace(); } // Rollback on error
    } finally {
        // Asegurar cierre de recursos
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); } // Reset auto-commit and close
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notas de Alumnos - Sistema Universitario</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
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
            background-color: #f9f9f9;
            color: var(--dark-color);
        }
        
        .header {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--secondary-color);
        }
        
        .user-info {
            text-align: right;
        }
        
        .user-info p {
            margin: 0.2rem 0;
            font-size: 0.9rem;
        }
        
        .user-name {
            font-weight: bold;
            color: var(--secondary-color);
        }
        
        .container-fluid { /* Contenedor principal de la aplicación */
            display: flex;
            min-height: calc(100vh - 60px); /* Ajusta para el header */
            padding: 0; /* Elimina padding horizontal */
        }
        
        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 0;
            flex-shrink: 0; /* Evita que el sidebar se encoja */
        }
        
        .sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .sidebar li a {
            display: block;
            padding: 0.8rem 1.5rem;
            color: white;
            text-decoration: none;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }
        
        .sidebar li a:hover {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 4px solid var(--secondary-color);
        }
        
        .sidebar li a.active {
            background-color: rgba(255, 255, 255, 0.2);
            border-left: 4px solid var(--secondary-color);
            font-weight: bold;
        }
        
        .main-content {
            flex-grow: 1; /* Permite que el contenido principal ocupe el espacio restante */
            padding: 2rem; /* Mantiene el padding interno para el contenido */
            overflow-y: auto; /* Para desplazamiento si el contenido es largo */
        }
        
        .info-card { /* Tarjetas generales de información */
            background-color: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-left: 4px solid var(--secondary-color);
        }
        
        .info-card h1, .info-card h2, .info-card h3 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1rem;
        }

        .profesor-info-card { /* Estilo específico para la info del profesor */
            border-top: 4px solid var(--primary-color);
            border-left: none; /* Anula el border-left de .info-card si aplica */
        }

        .class-list-card { /* Estilo específico para la lista de clases */
            border-top: 4px solid var(--accent-color);
            border-left: none;
        }

        .grades-form-card { /* Estilo específico para el formulario de notas */
            border-top: 4px solid #28a745; /* Verde */
            border-left: none;
        }

        .table-custom {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        
        .table-custom th {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }
        
        .table-custom td {
            padding: 1rem;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }
        
        .table-custom tr:hover {
            background-color: #f8f9fa;
        }
        
        .table-custom tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .table-custom tr:nth-child(even):hover {
            background-color: #f0f0f0;
        }

        .btn-accion {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s;
        }
        .btn-accion:hover {
            background-color: var(--accent-color);
        }

        .form-control-custom { /* Para los inputs de notas */
            width: 80px; /* Ancho más pequeño para las notas */
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            text-align: center; /* Centrar texto */
        }

        .btn-guardar-notas {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
            font-weight: 500;
        }
        .btn-guardar-notas:hover {
            background-color: var(--accent-color);
        }

        .no-data-message {
            text-align: center;
            padding: 2rem;
            color: #6c757d;
            font-style: italic;
        }

        .logout-btn {
            background-color: var(--accent-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .logout-btn:hover {
            background-color: #990000;
        }

        /* Mensajes de feedback */
        .alert-custom {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border: 1px solid transparent;
            border-radius: 0.25rem;
        }
        .alert-success-custom {
            color: #0f5132;
            background-color: #d1e7dd;
            border-color: #badbcc;
        }
        .alert-danger-custom {
            color: #842029;
            background-color: #f8d7da;
            border-color: #f5c2c7;
        }

        /* Badge for notes status */
        .badge {
            display: inline-block;
            padding: .35em .65em;
            font-size: .75em;
            font-weight: 700;
            line-height: 1;
            color: #fff;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: .25rem;
        }
        .bg-success { background-color: #198754!important; }
        .bg-danger { background-color: #dc3545!important; }
        .bg-secondary { background-color: #6c757d!important; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">Sistema Universitario</div>
        <div class="user-info">
            <p class="user-name"><%= nombreProfesor %></p>
            <p><%= emailProfesor %></p>
            <p><%= facultadProfesor %></p>
            <form action="logout.jsp" method="post">
                <button type="submit" class="logout-btn">Cerrar sesión</button>
            </form>
        </div>
    </div>
    
    <div class="container-fluid">
        <div class="sidebar">
            <ul>
                <li><a href="home_profesor.jsp">Inicio</a></li>
                <li><a href="facultad_profesor.jsp">Facultades</a></li>
                <li><a href="carreras_profesor.jsp">Carreras</a></li>
                <li><a href="cursos_profesor.jsp">Cursos</a></li>
                <li><a href="salones_profesor.jsp">Clases</a></li> 
                <li><a href="horarios_profesor.jsp">Horarios</a></li> 
                <li><a href="asistencia_profesor.jsp">Asistencia</a></li> 
                <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                <li><a href="nota_profesor.jsp" class="active">Notas</a></li>
            </ul>
        </div>
        
        <div class="main-content">
            <div class="info-card">
                <h1>Registro de Notas</h1>
                <p>Aquí puede ingresar y actualizar las notas de sus alumnos.</p>
            </div>

            <% if (!mensajeFeedback.isEmpty()) { %>
                <div class="alert-custom alert-<%= tipoMensajeFeedback %>-custom" role="alert">
                    <%= mensajeFeedback %>
                </div>
            <% } %>

            <div class="info-card profesor-info-card">
                <h3>Información del Profesor</h3>
                <p><strong>Nombre:</strong> <%= nombreProfesor %></p>
                <p><strong>Email:</strong> <%= emailProfesor %></p>
                <p><strong>Facultad:</strong> <%= facultadProfesor %></p>
            </div>
            
            <% if (idClaseParam == null || idClaseParam.isEmpty()) { %>
                <div class="info-card class-list-card">
                    <h2>Seleccione una Clase para Administrar Notas</h2>
                    <% if (clasesDelProfesor.isEmpty()) { %>
                        <p class="no-data-message">No tiene clases asignadas actualmente.</p>
                    <% } else { %>
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Curso</th>
                                    <th>Sección</th>
                                    <th>Semestre</th>
                                    <th>Año Académico</th>
                                    <th>Aula</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, String> clase : clasesDelProfesor) { %>
                                    <tr>
                                        <td><%= clase.get("nombre_curso") %></td>
                                        <td><%= clase.get("seccion") %></td>
                                        <td><%= clase.get("semestre") %></td>
                                        <td><%= clase.get("anio_academico") %></td>
                                        <td><%= clase.get("aula") %></td>
                                        <td>
                                            <a href="nota_profesor.jsp?id_clase=<%= clase.get("id_clase") %>" class="btn-accion">
                                                Administrar Notas
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } %>
                </div>
            <% } else { %>
                <div class="info-card grades-form-card">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                        <h2 class="h5 mb-0 text-primary">Notas de <%= nombreClase %> (<%= codigoClase %> - <%= aulaClase %>)</h2>
                    </div>

                    <% if (estudiantesDeClase.isEmpty()) { %>
                        <p class="no-data-message">No hay alumnos inscritos en esta clase o la clase no fue encontrada para su profesor.</p>
                        <div class="text-center mt-4">
                            <a href="nota_profesor.jsp" class="btn-accion">Volver a Clases</a>
                        </div>
                    <% } else { %>
                        <form method="post" action="nota_profesor.jsp?id_clase=<%= idClaseParam %>">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>DNI</th>
                                        <th>Nombre Completo</th>
                                        <th>Nota 1 (0-20)</th>
                                        <th>Nota 2 (0-20)</th>
                                        <th>Nota 3 (0-20)</th>
                                        <th>Ex. Parcial (0-20)</th>
                                        <th>Ex. Final (0-20)</th>
                                        <th>Nota Final</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% int contador = 1; %>
                                    <% for (Map<String, String> estudiante : estudiantesDeClase) { %>
                                        <tr>
                                            <td><%= contador++ %></td>
                                            <td><%= estudiante.get("dni") %></td>
                                            <td><%= estudiante.get("nombre_completo") %></td>
                                            <td>
                                                <input type="number" step="0.01" min="0" max="20" class="form-control-custom" 
                                                       name="nota1_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("nota1") %>">
                                            </td>
                                            <td>
                                                <input type="number" step="0.01" min="0" max="20" class="form-control-custom" 
                                                       name="nota2_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("nota2") %>">
                                            </td>
                                            <td>
                                                <input type="number" step="0.01" min="0" max="20" class="form-control-custom" 
                                                       name="nota3_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("nota3") %>">
                                            </td>
                                            <td>
                                                <input type="number" step="0.01" min="0" max="20" class="form-control-custom" 
                                                       name="examen_parcial_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("examen_parcial") %>">
                                            </td>
                                            <td>
                                                <input type="number" step="0.01" min="0" max="20" class="form-control-custom" 
                                                       name="examen_final_<%= estudiante.get("id_inscripcion") %>" 
                                                       value="<%= estudiante.get("examen_final") %>">
                                            </td>
                                            <td>
                                                <span class="badge 
                                                      <% if ("aprobado".equals(estudiante.get("estado_nota"))) { %> bg-success 
                                                      <% } else if ("desaprobado".equals(estudiante.get("estado_nota"))) { %> bg-danger
                                                      <% } else { %> bg-secondary <% } %>">
                                                    <%= estudiante.get("nota_final") %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge 
                                                      <% if ("aprobado".equals(estudiante.get("estado_nota"))) { %> bg-success 
                                                      <% } else if ("desaprobado".equals(estudiante.get("estado_nota"))) { %> bg-danger
                                                      <% } else { %> bg-secondary <% } %>">
                                                    <%= estudiante.get("estado_nota") %>
                                                </span>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            
                            <div class="text-center mt-4">
                                <button type="submit" class="btn-guardar-notas">
                                    Guardar Notas
                                </button>
                                <a href="nota_profesor.jsp" class="btn-accion ms-2">Volver a Clases</a>
                            </div>
                        </form>
                    <% } %>
                </div>
            <% } %>

            <%-- Nuevo: Tarjeta para Reporte de Notas --%>
            <div class="info-card report-card mt-4">
                <h2>Generar Reporte de Notas</h2>
                <p>Acceda a los reportes detallados de las notas de sus alumnos.</p>
                <a href="reporte-notas.jsp" class="btn-accion">
                    <i class="bi bi-file-earmark-bar-graph"></i> Ir a Reportes
                </a>
            </div>

        </div> <%-- End of main-content --%>
    </div> <%-- End of container-fluid --%>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>