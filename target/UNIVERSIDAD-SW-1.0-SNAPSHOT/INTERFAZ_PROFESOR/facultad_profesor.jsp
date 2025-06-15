<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page session="true" %>

<%
    // Obtener información de la sesión
    String email = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");

    if (email == null || !"profesor".equalsIgnoreCase(rolUsuario)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String facultadProfesor = "No asignado";
    String nombreProfesor = "";
    int idProfesor = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Conexion c = new Conexion();
        conn = c.conecta();

        // Obtener datos del profesor
        String sqlProfesor = "SELECT id_profesor, nombre, apellido_paterno, apellido_materno, id_facultad FROM profesores WHERE email = ?";
        pstmt = conn.prepareStatement(sqlProfesor);
        pstmt.setString(1, email);
        rs = pstmt.executeQuery();

        int idFacultad = 0;

        if (rs.next()) {
            idProfesor = rs.getInt("id_profesor");
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido_paterno") + " " + rs.getString("apellido_materno");
            idFacultad = rs.getInt("id_facultad");
        }

        rs.close();
        pstmt.close();

        // Obtener el nombre de la facultad
        if (idFacultad > 0) {
            String sqlFacultad = "SELECT nombre_facultad FROM facultades WHERE id_facultad = ?";
            pstmt = conn.prepareStatement(sqlFacultad);
            pstmt.setInt(1, idFacultad);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                facultadProfesor = rs.getString("nombre_facultad");
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException e) {
        }
        try {
            if (pstmt != null) {
                pstmt.close();
            }
        } catch (SQLException e) {
        }
        // NO cerramos conn aquí porque se usa después (en las estadísticas y tabla)
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Mi Facultad - Sistema Universitario</title>
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

            .container {
                display: flex;
                min-height: calc(100vh - 60px);
            }

            .sidebar {
                width: 250px;
                background-color: var(--primary-color);
                color: white;
                padding: 1.5rem 0;
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
                flex: 1;
                padding: 2rem;
            }

            .welcome-section {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-left: 4px solid var(--secondary-color);
            }

            .welcome-section h1 {
                color: var(--primary-color);
                margin-top: 0;
            }

            .facultad-card {
                background-color: white;
                border-radius: 8px;
                padding: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                margin-bottom: 2rem;
                text-align: center;
                border-top: 4px solid var(--primary-color);
            }

            .facultad-card h2 {
                color: var(--primary-color);
            }

            .info-card {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                margin-bottom: 1.5rem;
                border-left: 4px solid var(--secondary-color);
            }

            .stats-card {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                margin-bottom: 1.5rem;
                border-left: 4px solid var(--accent-color);
            }

            .profesores-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 1rem;
            }

            .profesores-table th {
                background-color: var(--primary-color);
                color: white;
                padding: 0.75rem;
                text-align: left;
            }

            .profesores-table td {
                padding: 0.75rem;
                border-bottom: 1px solid #eee;
            }

            .profesores-table tr:hover {
                background-color: #f5f5f5;
            }

            .badge {
                padding: 0.35em 0.65em;
                border-radius: 50rem;
                font-size: 0.75em;
                font-weight: 700;
            }

            .badge-primary {
                background-color: var(--primary-color);
                color: white;
            }

            .badge-success {
                background-color: #28a745;
                color: white;
            }

            .badge-warning {
                background-color: #ffc107;
                color: #212529;
            }

            .logout-btn {
                background-color: var(--accent-color);
                color: white;
                border: none;
                padding: 0.5rem 1rem;
                border-radius: 4px;
                cursor: pointer;
                margin-top: 0.5rem;
                transition: background-color 0.3s;
            }

            .logout-btn:hover {
                background-color: #990000;
            }

            .alert {
                padding: 1rem;
                border-radius: 4px;
                margin-bottom: 1rem;
            }

            .alert-info {
                background-color: #e7f5fe;
                border-left: 4px solid #17a2b8;
                color: #0c5460;
            }

            @media (max-width: 768px) {
                .container {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    padding: 1rem 0;
                }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="logo">Sistema Universitario</div>
            <div class="user-info">
                <p class="user-name"><%= nombreProfesor%></p>
                <p><%= email%></p>
                <p><%= facultadProfesor%></p>
                <form action="logout.jsp" method="post">
                    <button type="submit" class="logout-btn">Cerrar sesión</button>
                </form>
            </div>
        </div>

        <div class="container">
            <div class="sidebar">
                <ul>
                    <li><a href="home_profesor.jsp">Inicio</a></li>
                    <li><a href="facultad_profesor.jsp" class="active">Facultades</a></li>
                    <li><a href="carreras_profesor.jsp">Carreras</a></li>
                    <li><a href="cursos_profesor.jsp">Cursos</a></li>
                    <li><a href="salones_profesor.jsp">Clases</a></li> 
                    <li><a href="horarios_profesor.jsp">Horarios</a></li> 
                    <li><a href="asistencia_profesor.jsp">Asistencia</a></li>
                    <li><a href="mensaje_profesor.jsp">Mensajería</a></li>
                    <li><a href="nota_profesor.jsp">Notas</a></li>
                </ul>
            </div>

            <div class="main-content">
                <div class="welcome-section">
                    <h1>Mi Información de Facultad</h1>
                    <p>Bienvenido al módulo de facultades. Aquí puedes ver la información de tu facultad asignada y los profesores asociados.</p>
                </div>

                <!-- Tarjeta de Facultad Principal -->
                <div class="facultad-card">
                    <h2>Mi Facultad Asignada</h2>
                    <% if (!"No asignado".equals(facultadProfesor)) {%>
                    <h1 style="color: var(--primary-color);"><%= facultadProfesor%></h1>
                    <span class="badge badge-success">Facultad Activa</span>
                    <% } else { %>
                    <h3 style="color: var(--accent-color);">No Asignado</h3>
                    <p>Contacta al administrador para asignación de facultad</p>
                    <span class="badge badge-warning">Sin Asignación</span>
                    <% } %>
                </div>

                <div style="display: flex; gap: 1.5rem; margin-bottom: 2rem;">
                    <!-- Información adicional -->
                    <div class="info-card" style="flex: 1;">
                        <h3>Información</h3>
                        <ul style="list-style-type: none; padding-left: 0;">
                            <li style="margin-bottom: 0.5rem;">✓ Puedes ver la información de tu facultad asignada</li>
                            <li style="margin-bottom: 0.5rem;">✓ Accede a la lista de profesores de tu facultad</li>
                            <li style="margin-bottom: 0.5rem;">✓ Consulta estadísticas generales</li>
                            <li>ℹ Para cambios, contacta al administrador</li>
                        </ul>
                    </div>

                    <!-- Estadísticas -->
                    <div class="stats-card" style="flex: 1;">
                        <h3>Estadísticas de Mi Facultad</h3>
                        <%
                            int totalProfesoresFacultad = 0;
                            int totalCursosFacultad = 0;

                            if (!"No asignado".equals(facultadProfesor)) {
                                try {
                                    if (conn == null) {
                                        Conexion c = new Conexion();
                                        conn = c.conecta();
                                    }

                                    // Contar profesores de la facultad
                                    String sqlProfCount = "SELECT COUNT(*) as total FROM profesores "
                                            + "WHERE id_facultad = (SELECT id_facultad FROM facultades WHERE nombre_facultad = ?)";
                                    pstmt = conn.prepareStatement(sqlProfCount);
                                    pstmt.setString(1, facultadProfesor);
                                    rs = pstmt.executeQuery();
                                    if (rs.next()) {
                                        totalProfesoresFacultad = rs.getInt("total");
                                    }

                                    // Cerrar el primer ResultSet y PreparedStatement
                                    if (rs != null) {
                                        rs.close();
                                    }
                                    if (pstmt != null) {
                                        pstmt.close();
                                    }

                                    // Contar todos los cursos de la facultad
                                    String sqlCursosCount = "SELECT COUNT(*) as total FROM cursos c "
                                            + "INNER JOIN carreras car ON c.id_carrera = car.id_carrera "
                                            + "INNER JOIN facultades f ON car.id_facultad = f.id_facultad "
                                            + "WHERE f.nombre_facultad = ?";

                                    pstmt = conn.prepareStatement(sqlCursosCount);
                                    pstmt.setString(1, facultadProfesor);
                                    rs = pstmt.executeQuery();
                                    if (rs.next()) {
                                        totalCursosFacultad = rs.getInt("total");
                                    }

                                } catch (SQLException e) {
                                    out.println("Error al contar datos de facultad: " + e.getMessage());
                                    e.printStackTrace();
                                } finally {
                                    // Limpiar recursos
                                    try {
                                        if (rs != null) {
                                            rs.close();
                                        }
                                        if (pstmt != null) {
                                            pstmt.close();
                                        }
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            }
                        %>

                        <div style="display: flex; justify-content: space-around; text-align: center;">
                            <div>
                                <h3 style="color: var(--primary-color);"><%= totalProfesoresFacultad%></h3>
                                <small>Profesores en mi facultad</small>
                            </div>
                            <div>
                                <h3 style="color: var(--primary-color);"><%= totalCursosFacultad%></h3>
                                <small>Cursos por facultad</small>
                                <% if (totalCursosFacultad > 0) { %>
                                <div style="color: #666; font-size: 0.75em; margin-top: 0.2rem;">
                                    <i class="bi bi-book"></i> Total disponibles
                                </div>
                                <% } %>
                            </div>
                        </div>


                        <!-- Lista de profesores de la misma facultad -->
                        <% if (!"No asignado".equals(facultadProfesor)) {%>
                        <div class="info-card">
                            <h3>Profesores de <%= facultadProfesor%></h3>
                            <table class="profesores-table">
                                <thead>
                                    <tr>
                                        <th>Nombre Completo</th>
                                        <th>Email</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String sqlProfesores = "SELECT nombre, apellido_paterno, apellido_materno, email "
                                                    + "FROM profesores WHERE id_facultad = (SELECT id_facultad FROM facultades WHERE nombre_facultad = ?) "
                                                    + "ORDER BY apellido_paterno, nombre";

                                            pstmt = conn.prepareStatement(sqlProfesores);
                                            pstmt.setString(1, facultadProfesor);
                                            rs = pstmt.executeQuery();

                                            boolean hayProfesores = false;
                                            while (rs.next()) {
                                                hayProfesores = true;
                                                String nombreCompleto = rs.getString("nombre") + " "
                                                        + rs.getString("apellido_paterno") + " "
                                                        + rs.getString("apellido_materno");
                                                String emailProfesor = rs.getString("email");
                                                boolean esUsuarioActual = email.equals(emailProfesor);
                                    %>
                                    <tr style="<%= esUsuarioActual ? "background-color: #e7f3ff;" : ""%>">
                                        <td>
                                            <strong><%= nombreCompleto%></strong>
                                            <% if (esUsuarioActual) { %>
                                            <span class="badge badge-primary">Tú</span>
                                            <% }%>
                                        </td>
                                        <td><%= emailProfesor%></td>
                                        <td>
                                            <span class="badge badge-success">Activo</span>
                                        </td>
                                    </tr>
                                    <%
                                        }

                                        if (!hayProfesores) {
                                    %>
                                    <tr>
                                        <td colspan="3" style="text-align: center; padding: 2rem; color: #666;">
                                            No hay otros profesores en esta facultad
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace(); // <- Agregado para ayudarte a ver el error exacto
                                    %>
                                    <tr>
                                        <td colspan="3" style="text-align: center; color: var(--accent-color);">
                                            Error al cargar profesores
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>


                        <!-- Información para contacto 
                      <div class="alert alert-info">
                            <h4>¿Necesitas ayuda?</h4>
                            <p>
                                 <p>
                                    Si tienes preguntas sobre tu asignación de facultad, cambios en la información, 
                                    o necesitas soporte técnico, contacta al administrador del sistema a través de 
                                    los canales oficiales de la universidad.
                                 </p>
                            </p>
                        </div>
                    </div>
                </div>-->

                        <%
                            // Cerrar conexiones al final
                            try {
                                if (rs != null) {
                                    rs.close();
                                }
                                if (pstmt != null) {
                                    pstmt.close();
                                }
                                if (conn != null) {
                                    conn.close();
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        %>
                        </body>
                        </html>