<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>

<%
    Object idObj = session.getAttribute("id_profesor");
    int id = -1;
    String nombreProfesor = "";
    String emailProfesor = "";
    String facultadProfesor = "";

    if (idObj != null) {
        id = Integer.parseInt(idObj.toString());

        // Conexión a la base de datos para obtener información del profesor
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/bd_sw", "root", "");

            String sql = "SELECT nombre, email, facultad FROM profesores WHERE id_profesor = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                nombreProfesor = rs.getString("nombre");
                emailProfesor = rs.getString("email");
                facultadProfesor = rs.getString("facultad");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (con != null) {
                con.close();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema Universitario - Notas</title>
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

            .dashboard-cards {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 1.5rem;
            }

            .card {
                background-color: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
                transition: transform 0.3s, box-shadow 0.3s;
                text-decoration: none;
                color: var(--dark-color);
                display: flex;
                flex-direction: column;
                align-items: center;
                text-align: center;
            }

            .card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }

            .card-icon {
                font-size: 2.5rem;
                margin-bottom: 1rem;
                color: var(--primary-color);
            }

            .card-title {
                font-weight: bold;
                margin-bottom: 0.5rem;
                color: var(--primary-color);
            }

            .card-description {
                font-size: 0.9rem;
                color: #666;
            }

            .card-1 {
                border-top: 4px solid #002366;
            }
            .card-2 {
                border-top: 4px solid #800000;
            }
            .card-3 {
                border-top: 4px solid #FFD700;
            }
            .card-4 {
                border-top: 4px solid #4B5320;
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

            @media (max-width: 768px) {
                .container {
                    flex-direction: column;
                }

                .sidebar {
                    width: 100%;
                    padding: 1rem 0;
                }

                .dashboard-cards {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <div class="logo">Sistema Universitario</div>
            <div class="user-info">
                <p class="user-name"><%= nombreProfesor%></p>
                <p><%= emailProfesor%></p>
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
                    <li><a href="facultad_profesor.jsp">Facultades</a</li>
                    <li><a href="cursos_profesor.jsp">Cursos</a</li>
                    <li><a href="salones.jsp">Salones</a></li>
                    <li><a href="horarios.jsp">Horarios</a></li>
                    <li><a href="asistencia.jsp">Asistencia</a></li>
                    <li><a href="mensaje.jsp">Mensajería</a</li>
                    <li><a href="nota.jsp">Notas</a></li>
                </ul>
            </div>

            <div class="main-content">
                <div class="welcome-section">
                    <h1>Gestión de Notas</h1>
                    <p>Bienvenido al módulo de notas. Aquí puede registrar, modificar y consultar las calificaciones de sus estudiantes.</p>
                </div>

                <div class="dashboard-cards">
                    <a href="registrar_notas.jsp" class="card card-1">
                        <div class="card-icon">📝</div>
                        <h3 class="card-title">Registrar Notas</h3>
                        <p class="card-description">Ingrese las calificaciones de los estudiantes por curso y evaluación</p>
                    </a>

                    <a href="consultas_notas_profesor.jsp" class="card card-2">
                        <div class="card-icon">🔍</div>
                        <h3 class="card-title">Consultar Notas</h3>
                        <p class="card-description">Revise las calificaciones registradas por curso o estudiante</p>
                    </a>

                    <a href="reporte-notas.jsp" class="card card-3">
                        <div class="card-icon">📊</div>
                        <h3 class="card-title">Reportes de Notas</h3>
                        <p class="card-description">Genere reportes estadísticos y consolidados de calificaciones</p>
                    </a>

                    <a href="configurar-evaluaciones.jsp" class="card card-4">
                        <div class="card-icon">⚙️</div>
                        <h3 class="card-title">Configurar Evaluaciones</h3>
                        <p class="card-description">Defina los criterios y porcentajes de evaluación para sus cursos</p>
                    </a>
                </div>
            </div>
        </div>
    </body>
</html>