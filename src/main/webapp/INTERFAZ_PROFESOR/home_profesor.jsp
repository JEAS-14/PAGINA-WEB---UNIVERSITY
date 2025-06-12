<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Profesor | UNI</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-blue: #002366;
            --secondary-blue: #1a4b8c;
            --light-blue: #e6f0ff;
            --white: #ffffff;
            --light-gray: #f8f9fa;
            --medium-gray: #e9ecef;
            --dark-gray: #495057;
        }
        
        body {
            background-color: var(--white);
            color: #212529;
        }
        
        .sidebar {
            background-color: var(--primary-blue);
            color: white;
            min-height: 100vh;
            position: fixed;
            width: 250px;
            transition: all 0.3s;
        }
        
        .sidebar-header {
            padding: 20px;
            background-color: var(--secondary-blue);
            text-align: center;
        }
        
        .sidebar-header img {
            max-width: 80%;
            height: auto;
            margin-bottom: 15px;
        }
        
        .nav-menu {
            list-style: none;
            padding: 0;
        }
        
        .nav-item {
            padding: 10px 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .nav-link {
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
        }
        
        .nav-link i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        
        .nav-link:hover, .nav-link.active {
            background-color: var(--secondary-blue);
            border-radius: 5px;
        }
        
        .main-content {
            margin-left: 250px;
            padding: 20px;
            background-color: var(--light-gray);
            min-height: 100vh;
        }
        
        .header {
            background-color: var(--white);
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            background-color: var(--primary-blue);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 15px;
        }
        
        .stat-card {
            background-color: var(--white);
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border-left: 4px solid var(--primary-blue);
        }
        
        .stat-card h3 {
            font-size: 1rem;
            color: var(--dark-gray);
            margin-bottom: 10px;
        }
        
        .stat-card .value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-blue);
        }
        
        .stat-card .description {
            font-size: 0.8rem;
            color: var(--dark-gray);
        }
        
        .content-section {
            background-color: var(--white);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .section-title {
            color: var(--primary-blue);
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
            margin-bottom: 20px;
        }
        
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        
        .action-card {
            background-color: var(--white);
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
        }
        
        .action-card i {
            font-size: 2rem;
            color: var(--primary-blue);
            margin-bottom: 15px;
        }
        
        .action-card h4 {
            color: var(--primary-blue);
            margin-bottom: 10px;
        }
        
        .action-card p {
            font-size: 0.9rem;
            color: var(--dark-gray);
            margin-bottom: 15px;
        }
        
        .action-btn {
            display: inline-block;
            background-color: var(--primary-blue);
            color: white;
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .action-btn:hover {
            background-color: var(--secondary-blue);
            color: white;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            background-color: var(--primary-blue);
            color: white;
            padding: 12px;
            text-align: left;
        }
        
        td {
            padding: 12px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        tr:hover {
            background-color: var(--light-blue);
        }
        
        .badge-primary {
            background-color: var(--primary-blue);
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            text-decoration: none;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .header {
                flex-direction: column;
                text-align: center;
            }
            
            .user-profile {
                margin-top: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <img src="https://www.uni.edu.pe/images/logo_uni.png" alt="Logo UNI" class="img-fluid">
                <h2 class="h5">Sistema Académico</h2>
                <p class="small">Panel del Profesor</p>
            </div>

            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="home_profesor.jsp" class="nav-link active">
                        <i class="fas fa-home"></i> Inicio
                    </a>
                </li>
                <li class="nav-item">
                    <a href="cursos_profesor.jsp" class="nav-link">
                        <i class="fas fa-book"></i> Mis Cursos
                    </a>
                </li>
                <li class="nav-item">
                    <a href="asistencia.jsp" class="nav-link">
                        <i class="fas fa-user-check"></i> Asistencia
                    </a>
                </li>
                <li class="nav-item">
                    <a href="notas.jsp" class="nav-link">
                        <i class="fas fa-clipboard-list"></i> Notas
                    </a>
                </li>
                <li class="nav-item">
                    <a href="logout.jsp" class="nav-link">
                        <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <div class="header">
                <div class="welcome-message">
                    <h1 class="h3">
                        Bienvenido, 
                        <c:choose>
                            <c:when test="${not empty sessionScope.home.nombreCompleto}">
                                ${sessionScope.home.nombreCompleto}
                            </c:when>
                            <c:otherwise>
                                Usuario
                            </c:otherwise>
                        </c:choose>
                    </h1>
                    <p class="mb-0 text-muted">
                        <c:choose>
                            <c:when test="${not empty sessionScope.today}">
                                <fmt:setLocale value="es_ES" />
                                <fmt:formatDate value="${sessionScope.today}" pattern="EEEE, d 'de' MMMM 'de' yyyy"/>
                            </c:when>
                            <c:otherwise>
                                ${pageContext.session.creationTime}
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <div class="user-profile">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty sessionScope.home.nombreCompleto}">
                                ${fn:substring(sessionScope.home.nombreCompleto, 0, 1)}
                            </c:when>
                            <c:otherwise>
                                U
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-info">
                        <strong>
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.nombreCompleto}">
                                    ${sessionScope.home.nombreCompleto}
                                </c:when>
                                <c:otherwise>
                                    Usuario no identificado
                                </c:otherwise>
                            </c:choose>
                        </strong><br>
                        <small class="text-muted">
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.facultad}">
                                    ${sessionScope.home.facultad}
                                </c:when>
                                <c:otherwise>
                                    Facultad no especificada
                                </c:otherwise>
                            </c:choose>
                        </small>
                    </div>
                </div>
            </div>

            <!-- Estadísticas -->
            <div class="row mb-4">
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Cursos Asignados</h3>
                        <div class="value">
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.totalCursos}">
                                    ${sessionScope.home.totalCursos}
                                </c:when>
                                <c:otherwise>
                                    0
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="description">Total de cursos a su cargo</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Cursos Activos</h3>
                        <div class="value">
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.cursosActivos}">
                                    ${sessionScope.home.cursosActivos}
                                </c:when>
                                <c:otherwise>
                                    0
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="description">Cursos en periodo lectivo</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Estudiantes</h3>
                        <div class="value">
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.totalAlumnos}">
                                    ${sessionScope.home.totalAlumnos}
                                </c:when>
                                <c:otherwise>
                                    0
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="description">Alumnos matriculados</div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="stat-card">
                        <h3>Evaluaciones</h3>
                        <div class="value">
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.evaluacionesPendientes}">
                                    ${sessionScope.home.evaluacionesPendientes}
                                </c:when>
                                <c:otherwise>
                                    0
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="description">Pendientes de calificar</div>
                    </div>
                </div>
            </div>

            <!-- Información del profesor -->
            <div class="content-section mb-4">
                <h3 class="section-title">Mi Información</h3>
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Nombre completo:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.nombreCompleto}">
                                    ${sessionScope.home.nombreCompleto}
                                </c:when>
                                <c:otherwise>No disponible</c:otherwise>
                            </c:choose>
                        </p>
                        <p><strong>DNI:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.dni}">
                                    ${sessionScope.home.dni}
                                </c:when>
                                <c:otherwise>No disponible</c:otherwise>
                            </c:choose>
                        </p>
                        <p><strong>Facultad:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.facultad}">
                                    ${sessionScope.home.facultad}
                                </c:when>
                                <c:otherwise>No disponible</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Correo electrónico:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.email}">
                                    ${sessionScope.email}
                                </c:when>
                                <c:otherwise>No disponible</c:otherwise>
                            </c:choose>
                        </p>
                        <p><strong>Teléfono:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.home.telefono}">
                                    ${sessionScope.home.telefono}
                                </c:when>
                                <c:otherwise>No registrado</c:otherwise>
                            </c:choose>
                        </p>
                        <p><strong>Último acceso:</strong> 
                            <c:choose>
                                <c:when test="${not empty sessionScope.today}">
                                    <fmt:formatDate value="${sessionScope.today}" pattern="dd/MM/yyyy HH:mm"/>
                                </c:when>
                                <c:otherwise>Ahora</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>
            </div>

            <!-- Tabla de cursos -->
            <div class="content-section mb-4">
                <h3 class="section-title">Mis Cursos</h3>
                <div class="table-responsive">
                    <c:choose>
                        <c:when test="${not empty sessionScope.home.cursosList}">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Código</th>
                                        <th>Nombre del Curso</th>
                                        <th>Créditos</th>
                                        <th>Alumnos</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="curso" items="${sessionScope.home.cursosList}">
                                    <tr>
                                        <td>${curso.codigo_curso}</td>
                                        <td>${curso.nombre_curso}</td>
                                        <td>${curso.creditos}</td>
                                        <td>${curso.alumnos}</td>
                                        <td><a href="detalle_curso.jsp?id=${curso.id_curso}" class="badge-primary">Ver</a></td>
                                    </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise><p class="text-muted">No hay cursos asignados actualmente.</p></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Tabla de alumnos recientes -->
            <div class="content-section mb-4">
                <h3 class="section-title">Alumnos Recientes</h3>
                <div class="table-responsive">
                    <c:choose>
                        <c:when test="${not empty sessionScope.home.alumnosList}">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Nombre</th>
                                        <th>Curso</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="alumno" items="${sessionScope.home.alumnosList}">
                                    <tr>
                                        <td>${alumno.id_alumno}</td>
                                        <td>${alumno.nombre} ${alumno.apellido_paterno} ${alumno.apellido_materno}</td>
                                        <td>${alumno.nombre_curso}</td>
                                        <td><a href="detalle_alumno.jsp?id=${alumno.id_alumno}" class="badge-primary">Ver</a></td>
                                    </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise><p class="text-muted">No hay alumnos registrados recientemente.</p></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Tabla de evaluaciones próximas -->
            <div class="content-section mb-4">
                <h3 class="section-title">Evaluaciones Próximas</h3>
                <div class="table-responsive">
                    <c:choose>
                        <c:when test="${not empty sessionScope.home.evaluacionesList}">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Evaluación</th>
                                        <th>Curso</th>
                                        <th>Fecha Límite</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="evaluacion" items="${sessionScope.home.evaluacionesList}">
                                    <tr>
                                        <td>${evaluacion.nombre_evaluacion}</td>
                                        <td>${evaluacion.nombre_curso}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty evaluacion.fecha_limite}">
                                                    ${evaluacion.fecha_limite}
                                                </c:when>
                                                <c:otherwise>Sin fecha</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><a href="gestionar_evaluacion.jsp?id=${evaluacion.id_evaluacion}" class="badge-primary">Gestionar</a></td>
                                    </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise><p class="text-muted">No hay evaluaciones próximas.</p></c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Acciones rápidas -->
            <div class="content-section">
                <h3 class="section-title">Acciones Rápidas</h3>
                <div class="quick-actions">
                    <div class="action-card">
                        <i class="fas fa-clipboard-check"></i>
                        <h4>Registrar Asistencia</h4>
                        <p>Registre la asistencia de sus estudiantes para la sesión de hoy</p>
                        <a href="registrar_asistencia.jsp" class="action-btn">Ir ahora</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-edit"></i>
                        <h4>Ingresar Notas</h4>
                        <p>Ingrese las calificaciones de la última evaluación</p>
                        <a href="ingresar_notas.jsp" class="action-btn">Ir ahora</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-calendar-alt"></i>
                        <h4>Ver Horario</h4>
                        <p>Consulte su horario de clases para esta semana</p>
                        <a href="horarios.jsp" class="action-btn">Ver horario</a>
                    </div>

                    <div class="action-card">
                        <i class="fas fa-envelope"></i>
                        <h4>Mensajes</h4>
                        <p>Revise sus mensajes y comunicados importantes</p>
                        <a href="mensajes.jsp" class="action-btn">Ver mensajes</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</body>

</html>