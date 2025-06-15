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
    int idFacultadProfesor = 0;

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

        if (rs.next()) {
            idProfesor = rs.getInt("id_profesor");
            nombreProfesor = rs.getString("nombre") + " " + rs.getString("apellido_paterno") + " " + rs.getString("apellido_materno");
            idFacultadProfesor = rs.getInt("id_facultad");
        }

        rs.close();
        pstmt.close();

        // Obtener el nombre de la facultad
        if (idFacultadProfesor > 0) {
            String sqlFacultad = "SELECT nombre_facultad FROM facultades WHERE id_facultad = ?";
            pstmt = conn.prepareStatement(sqlFacultad);
            pstmt.setInt(1, idFacultadProfesor);
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
        // NO cerramos conn aquí porque se usa después
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Carreras - Sistema Universitario</title>
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

            .stats-section {
                display: flex;
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .stat-card {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                flex: 1;
                text-align: center;
                border-top: 4px solid var(--accent-color);
            }

            .stat-number {
                font-size: 2rem;
                font-weight: bold;
                color: var(--primary-color);
            }

            .stat-label {
                color: #666;
                font-size: 0.9rem;
                margin-top: 0.5rem;
            }

            .carreras-section {
                background-color: white;
                border-radius: 8px;
                padding: 2rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                border-top: 4px solid var(--primary-color);
            }

            .carreras-section h2 {
                color: var(--primary-color);
                margin-top: 0;
                margin-bottom: 1.5rem;
            }

            .carreras-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 1rem;
            }

            .carreras-table th {
                background-color: var(--primary-color);
                color: white;
                padding: 1rem;
                text-align: left;
                font-weight: 600;
            }

            .carreras-table td {
                padding: 1rem;
                border-bottom: 1px solid #eee;
                vertical-align: middle;
            }

            .carreras-table tr:hover {
                background-color: #f8f9fa;
            }

            .carreras-table tr:nth-child(even) {
                background-color: #f9f9f9;
            }

            .carreras-table tr:nth-child(even):hover {
                background-color: #f0f0f0;
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

            .badge-info {
                background-color: #17a2b8;
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

            .no-data {
                text-align: center;
                padding: 3rem;
                color: #666;
                font-style: italic;
            }

            .info-box {
                background-color: #e7f3ff;
                border-left: 4px solid #17a2b8;
                padding: 1rem;
                margin-bottom: 2rem;
                border-radius: 4px;
            }

            .info-box h4 {
                color: #0c5460;
                margin-top: 0;
            }

            .info-box p {
                color: #0c5460;
                margin-bottom: 0;
            }

            .carrera-id {
                font-weight: bold;
                color: var(--primary-color);
            }

            .carrera-name {
                font-weight: 600;
                color: var(--dark-color);
            }

            @media (max-width: 768px) {
                .container {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    padding: 1rem 0;
                }

                .stats-section {
                    flex-direction: column;
                }

                .carreras-table {
                    font-size: 0.9rem;
                }

                .carreras-table th,
                .carreras-table td {
                    padding: 0.75rem 0.5rem;
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
                    <li><a href="facultad_profesor.jsp">Facultades</a></li>
                    <li><a href="carreras_profesor.jsp" class="active">Carreras</a></li>
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
                    <h1>Carreras de Mi Facultad</h1>
                    <p>Consulta las carreras disponibles en <%= facultadProfesor%>. Esta información es solo de lectura y es administrada por el personal autorizado.</p>
                </div>

                <div class="info-box">
                    <h4>ℹ️ Información</h4>
                    <p>Como profesor, puedes consultar las carreras de tu facultad asignada. Para modificaciones o nuevas carreras, contacta al administrador del sistema.</p>
                </div>

                <%
                    // Contar carreras de la facultad del profesor
                    int totalCarreras = 0;
                    int cursosDisponibles = 0;

                    if (idFacultadProfesor > 0) {
                        try {
                            if (conn == null) {
                                Conexion c = new Conexion();
                                conn = c.conecta();
                            }

                            // Contar carreras de la facultad
                            String sqlCount = "SELECT COUNT(*) as total FROM carreras WHERE id_facultad = ?";
                            pstmt = conn.prepareStatement(sqlCount);
                            pstmt.setInt(1, idFacultadProfesor);
                            rs = pstmt.executeQuery();
                            if (rs.next()) {
                                totalCarreras = rs.getInt("total");
                            }

                            // Cerrar el primer ResultSet y PreparedStatement
                            if (rs != null) {
                                rs.close();
                            }
                            if (pstmt != null) {
                                pstmt.close();
                            }

                            // Contar cursos disponibles (cursos de la facultad que el profesor NO tiene asignados)
                            String sqlCursosDisponibles = "SELECT COUNT(*) as disponibles "
                                    + "FROM cursos c "
                                    + "INNER JOIN carreras car ON c.id_carrera = car.id_carrera "
                                    + "WHERE car.id_facultad = ? "
                                    + "AND c.id_curso NOT IN ("
                                    + "    SELECT pc.id_curso FROM profesor_curso pc WHERE pc.id_profesor = ?"
                                    + ")";

                            pstmt = conn.prepareStatement(sqlCursosDisponibles);
                            pstmt.setInt(1, idFacultadProfesor);
                            pstmt.setInt(2, idProfesor);
                            rs = pstmt.executeQuery();
                            if (rs.next()) {
                                cursosDisponibles = rs.getInt("disponibles");
                            }

                        } catch (SQLException e) {
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

                <div class="stats-section">
                    <div class="stat-card">
                        <div class="stat-number"><%= totalCarreras%></div>
                        <div class="stat-label">Carreras en mi facultad</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= facultadProfesor.equals("No asignado") ? "0" : "1"%></div>
                        <div class="stat-label">Facultad asignada</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= cursosDisponibles%></div>
                        <div class="stat-label">Cursos disponibles</div>
                        <% if (cursosDisponibles > 0) { %>
                        <div class="stat-sublabel" style="color: #4caf50; font-size: 0.8em; margin-top: 0.2rem;">
                            <i class="bi bi-plus-circle"></i> Listos para unirse
                        </div>
                        <% } else { %>
                        <div class="stat-sublabel" style="color: #999; font-size: 0.8em; margin-top: 0.2rem;">
                            <i class="bi bi-check-circle"></i> Todos asignados
                        </div>
                        <% }%>
                    </div>
                </div>

                <div class="carreras-section">
                    <h2>Listado de Carreras - <%= facultadProfesor%></h2>

                    <% if (idFacultadProfesor > 0) { %>
                    <table class="carreras-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre de la Carrera</th>
                                <th>Facultad</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    String sqlCarreras = "SELECT c.id_carrera, c.nombre_carrera, f.nombre_facultad "
                                            + "FROM carreras c "
                                            + "INNER JOIN facultades f ON c.id_facultad = f.id_facultad "
                                            + "WHERE c.id_facultad = ? "
                                            + "ORDER BY c.nombre_carrera";

                                    pstmt = conn.prepareStatement(sqlCarreras);
                                    pstmt.setInt(1, idFacultadProfesor);
                                    rs = pstmt.executeQuery();

                                    boolean hayCarreras = false;
                                    while (rs.next()) {
                                        hayCarreras = true;
                                        int idCarrera = rs.getInt("id_carrera");
                                        String nombreCarrera = rs.getString("nombre_carrera");
                                        String nombreFacultad = rs.getString("nombre_facultad");
                            %>
                            <tr>
                                <td>
                                    <span class="carrera-id"><%= String.format("%03d", idCarrera)%></span>
                                </td>
                                <td>
                                    <span class="carrera-name"><%= nombreCarrera%></span>
                                </td>
                                <td><%= nombreFacultad%></td>
                                <td>
                                    <span class="badge badge-info">Activa</span>
                                </td>
                            </tr>
                            <%
                                }

                                if (!hayCarreras) {
                            %>
                            <tr>
                                <td colspan="4" class="no-data">
                                    📚 No hay carreras registradas en tu facultad
                                </td>
                            </tr>
                            <%
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            %>
                            <tr>
                                <td colspan="4" class="no-data" style="color: var(--accent-color);">
                                    ❌ Error al cargar las carreras
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div class="no-data">
                        <h3>No tienes una facultad asignada</h3>
                        <p>Contacta al administrador para que te asigne una facultad y puedas ver las carreras disponibles.</p>
                        <span class="badge badge-warning">Sin Asignación</span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

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