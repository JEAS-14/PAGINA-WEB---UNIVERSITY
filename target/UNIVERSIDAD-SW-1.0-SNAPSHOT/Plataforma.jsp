<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%
    String loginError = (String) session.getAttribute("loginError");
    if (loginError != null) {
        session.removeAttribute("loginError");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>UGIC PORTAL</title>
        <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" />
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            .navbar-brand img {
                max-height: 2.5rem;
                margin-right: 10px;
            }
        </style>
        <style>
            .fade-in {
                opacity: 0;
                animation: fadeInAnimation 1.5s ease-in forwards;
            }

            @keyframes fadeInAnimation {
                to {
                    opacity: 1;
                }
            }
        </style>
    </head>
    <body>
        <div class="modal fade" id="loginErrorModal" tabindex="-1" aria-labelledby="loginErrorModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title" id="loginErrorModalLabel"><i class="fas fa-exclamation-triangle me-2"></i> Error de Inicio de Sesión</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p id="loginErrorMessage"></p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const error = "<%= loginError != null ? loginError.replaceAll("\"", "\\\\\"") : "" %>";
                if (error && error.trim() !== "") {
                    const loginErrorMessage = document.getElementById('loginErrorMessage');
                    const loginErrorModal = new bootstrap.Modal(document.getElementById('loginErrorModal'));
                    loginErrorMessage.textContent = error;
                    loginErrorModal.show();
                }
            });
        </script>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
            <div class="container-fluid">
                <a class="navbar-brand" href="#">
                    <img src="img/logo_ugic.png" alt="Logo UGIC"> UGIC Portal
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent"
                        aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarSupportedContent">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="carrerasPregradoDropdown" role="button"
                               data-bs-toggle="dropdown" aria-expanded="false">
                                Carreras Pregrado
                            </a>
                            <ul class="dropdown-menu" aria-labelledby="carrerasPregradoDropdown">
                                <li><a class="dropdown-item" href="Carreras/Ingenieria de Sistemas.jsp">Ingeniería de Sistemas</a></li>
                                <li><a class="dropdown-item" href="Carreras/Administración de Empresas.jsp">Administración de Empresas</a></li>
                                <li><a class="dropdown-item" href="Carreras/Derecho.jsp">Derecho</a></li>
                                <li><a class="dropdown-item" href="Carreras/Contabilidad.jsp">Contabilidad</a></li>
                                <li><a class="dropdown-item" href="Carreras/Ingeniería Industrial.jsp">Ingeniería Industrial</a></li>
                                <li><a class="dropdown-item" href="Carreras/Ingeniería Civil.jsp">Ingeniería Civil</a></li>
                                <li><a class="dropdown-item" href="Carreras/Psicología.jsp">Psicología</a></li>
                                <li><a class="dropdown-item" href="Carreras/Educación Inicial.jsp">Educación Inicial</a></li>
                                <li><a class="dropdown-item" href="Carreras/Ciencias de la Comunicación.jsp">Ciencias de la Comunicación</a></li>
                                <li><a class="dropdown-item" href="Carreras/Arquitectura.jsp">Arquitectura</a></li>
                            </ul>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="carrerasDistanciaDropdown" role="button"
                               data-bs-toggle="dropdown" aria-expanded="false">
                                Carreras a Distancia
                            </a>
                            <ul class="dropdown-menu" aria-labelledby="carrerasDistanciaDropdown">
                                <li><a class="dropdown-item" href="#">Administración de Empresas (Virtual)</a></li>
                                <li><a class="dropdown-item" href="#">Marketing Digital (Virtual)</a></li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Posgrado</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Nosotros</a>
                        </li>
                    </ul>
                    <form class="d-flex">
                        <input class="form-control me-2" type="search" placeholder="Buscar" aria-label="Buscar">
                        <button class="btn btn-outline-success" type="submit">Buscar</button>
                    </form>
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="#">Postular a UGIC</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="usuarioDropdown" role="button"
                               data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-user"></i> Iniciar Sesión
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="usuarioDropdown">
                                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#alumnoModal">Alumno</a></li>
                                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#profesorModal">Profesor</a></li>
                                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#apoderadoModal">Apoderado</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#adminModal">Administrador</a></li>
                                <li><hr class="dropdown-divider"></li>                                
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
        <div class="position-relative">
            <div class="position-absolute top-50 start-50 translate-middle text-center text-white px-4 py-3 rounded fade-in"
                 style="z-index: 10; background-color: rgba(0, 0, 0, 0.5);">
                <h1 class="display-4 fw-bold">Bienvenido al Portal de la Universidad UGIC</h1>
            </div>

            <div id="miCarrusel" class="carousel slide" data-bs-ride="carousel">
                <div class="carousel-inner">
                    <div class="carousel-item active">
                        <img src="img/imagen1.jpg" class="d-block w-100" alt="Campus 1" style="height: 600px; object-fit: cover;">
                    </div>
                    <div class="carousel-item">
                        <img src="img/imagen3.jpg" class="d-block w-100" alt="Campus 2" style="height: 600px; object-fit: cover;">
                    </div>
                    <div class="carousel-item">
                        <img src="img/imagen4.jpg" class="d-block w-100" alt="Evento" style="height: 600px; object-fit: cover;">
                    </div>
                </div>
                <button class="carousel-control-prev" type="button" data-bs-target="#miCarrusel" data-bs-slide="prev">
                    <span class="carousel-control-prev-icon"></span>
                </button>
                <button class="carousel-control-next" type="button" data-bs-target="#miCarrusel" data-bs-slide="next">
                    <span class="carousel-control-next-icon"></span>
                </button>
            </div>
        </div>
        <div id="titulo" style="background-color: black; color: white; font-size: 70px; font-family: 'Arial Black', sans-serif; padding: 20px;">
            <p style="margin-left: 50px">
                SOBRE NOSOTROS
            </p>
        </div>

        <div id="contenido" style="display: flex; justify-content: space-between; align-items: flex-start; margin: 40px auto; padding: 0 60px; gap: 50px; max-width: 1200px;">
            <div id="texto" style="width: 50%; font-size: 18px;padding-top: 30px">
                La Universidad de Gestión e Innovación del Conocimiento (UGIC) es una institución educativa de nivel superior comprometida con la formación de profesionales íntegros, críticos y creativos. Nuestra propuesta académica se fundamenta en la excelencia, la innovación y el compromiso con la sociedad. En UGIC, promovemos un entorno inclusivo, colaborativo y orientado al desarrollo sostenible y tecnológico.
            </div>
            <div id="imagen" style="width: 50%; text-align: right;">
                <img src="img/universidad.jpg" alt="universidad" style="max-width: 100%; height: auto; border-radius: 10px;">
            </div>
        </div>

        <div style="background-color: black; color: white; font-size: 60px; font-family: 'Arial Black', sans-serif; padding: 25px;">
            <p style="margin-left: 50px;">NUESTRA VISIÓN Y MISIÓN</p>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin: 40px auto; padding: 0 60px; gap: 50px; max-width: 1200px;">

            <div style="width: 50%;">
                <h2 style="font-size: 24px; color: darkred; margin-bottom: 10px;">Misión</h2>
                <div style="border: 2px solid darkred; border-radius: 10px; padding: 20px; font-size: 16px; background-color: #fff;">
                    Formar profesionales con sólida preparación académica, ética y humanística, capaces de liderar procesos de cambio e innovación en sus comunidades. Fomentamos la investigación, el pensamiento crítico y el compromiso social como pilares fundamentales para contribuir al desarrollo regional, nacional e internacional.
                </div>
            </div>

            <div style="width: 50%;">
                <h2 style="font-size: 24px; color: darkred; margin-bottom: 10px;">Visión</h2>
                <div style="border: 2px solid darkred; border-radius: 10px; padding: 20px; font-size: 16px; background-color: #fff;">
                    Ser reconocida como una universidad líder en educación superior por su excelencia académica, su capacidad innovadora y su impacto positivo en la sociedad, a través de la formación de líderes transformadores y comprometidos con el conocimiento, la equidad y el progreso.
                </div>
            </div>
        </div>
        <div style="margin: 60px auto 40px; padding: 0 60px; max-width: 1200px;">
            <h2 style="font-size: 36px; font-family: 'Arial Black', sans-serif; color: black; margin-bottom: 30px;">NUESTROS VALORES</h2>
            <div style="display: flex; flex-wrap: wrap; gap: 30px;">
                <div style="flex: 1 1 300px; border: 2px solid darkred; border-radius: 10px; padding: 20px; background-color: #fff;">
                    <h3 style="color: darkred; margin-bottom: 10px;">Excelencia Académica</h3>
                    <p>Nos esforzamos por alcanzar y mantener altos estándares en enseñanza, investigación y gestión institucional.</p>
                </div>
                <div style="flex: 1 1 300px; border: 2px solid darkred; border-radius: 10px; padding: 20px; background-color: #fff;">
                    <h3 style="color: darkred; margin-bottom: 10px;">Innovación</h3>
                    <p>Promovemos la creatividad, el emprendimiento y la incorporación de tecnologías que transforman la sociedad.</p>
                </div>
                <div style="flex: 1 1 300px; border: 2px solid darkred; border-radius: 10px; padding: 20px; background-color: #fff;">
                    <h3 style="color: darkred; margin-bottom: 10px;">Ética</h3>
                    <p>Actuamos con integridad, transparencia y responsabilidad en todos nuestros procesos y relaciones.</p>
                </div>
                <div style="flex: 1 1 300px; border: 2px solid darkred; border-radius: 10px; padding: 20px; background-color: #fff;">
                    <h3 style="color: darkred; margin-bottom: 10px;">Compromiso Social</h3>
                    <p>Trabajamos con y para nuestras comunidades, generando impacto real y sostenible.</p>
                </div>
                <div style="flex: 1 1 300px; border: 2px solid darkred; border-radius: 10px; padding: 20px; background-color: #fff;">
                    <h3 style="color: darkred; margin-bottom: 10px;">Diversidad e Inclusión</h3>
                    <p>Valoramos las diferencias como fuente de crecimiento, promoviendo un entorno respetuoso y equitativo.</p>
                </div>
            </div>
        </div>

        <div style="background-color: darkred; color: white; font-size: 60px; font-family: 'Arial Black', sans-serif; padding: 25px;">
            <p style="margin-left: 50px;">NUESTRA HISTORIA</p>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin: 40px auto; padding: 0 60px; gap: 50px; max-width: 1200px;">

            <div style="width: 50%; font-size: 18px;">
                <p>
                    UGIC fue fundada en el año 2010 como una iniciativa académica destinada a cubrir las nuevas demandas del mercado laboral en sectores emergentes. Con un enfoque vanguardista, la universidad ha crecido sostenidamente, ampliando su oferta educativa, modernizando su infraestructura y fortaleciendo alianzas estratégicas con instituciones nacionales e internacionales. Hoy, UGIC es un referente en educación superior centrada en la innovación y el impacto social.
                </p>
            </div>

            <div style="width: 50%; display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
                <img src="img/universidad1.jpg" alt="Foto 1" style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                <img src="img/universidad2.jpg" alt="Foto 2" style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
                <img src="img/universidad3.jpg" alt="Foto 3" style="grid-column: span 2; width: 100%; height: 200px; object-fit: cover; border-radius: 8px;">
            </div>

        </div>
        <div style="background-color: black; color: white; font-size: 60px; font-family: 'Arial Black', sans-serif; padding: 25px;">
            <p style="margin-left: 50px;">AUTORIDADES</p>
        </div>

        <div style="max-width: 1000px; margin: 40px auto; padding: 0 60px;">
            <ul style="list-style: none; padding: 0; font-size: 18px; line-height: 1.8;">

                <li>
                    <strong>Rector General:</strong> Dr. Mario Fernández Torres
                </li>

                <li>
                    <strong>Vicerrectora Académica:</strong> Dra. Lucía Ramírez Delgado
                </li>

                <li>
                    <strong>Vicerrector de Investigación:</strong> Dr. Felipe Montes Quispe
                </li>

                <li>
                    <strong>Directora de Bienestar Universitario:</strong> Lic. Ana Gabriela Suárez
                </li>

                <li>
                    <strong>Decano de la Facultad de Ingeniería:</strong> Ing. Carlos Méndez Rosales
                </li>

                <li>
                    <strong>Decana de la Facultad de Ciencias Sociales:</strong> Dra. Rosa Elena Támara
                </li>

                <li>
                    <strong>Secretario General:</strong> Mgr. Javier López Herrera
                </li>

            </ul>
        </div>
        <div class="container mt-2">
        </div>
        <div class="modal fade" id="alumnoModal" tabindex="-1" aria-labelledby="alumnoModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header modal-header-primary bg-primary text-white">
                        <h5 class="modal-title" id="alumnoModalLabel"><i class="fas fa-graduation-cap me-2"></i> Iniciar Sesión Alumno</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="loginServlet" method="post">
                            <input type="hidden" name="userType" value="alumno">
                            <div class="mb-3">
                                <label for="alumnoUsernameModal" class="form-label"><i class="fas fa-user me-2"></i> Usuario</label>
                                <input type="text" class="form-control" id="alumnoUsernameInput" name="username" placeholder="Ingrese su usuario" required>
                            </div>
                            <div class="mb-3">
                                <label for="alumnoPasswordModal" class="form-label"><i class="fas fa-lock me-2"></i> Contraseña</label>
                                <input type="password" class="form-control" id="alumnoPasswordInput" name="password" placeholder="Ingrese su contraseña" required>
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="rememberAlumno">
                                <label class="form-check-label" for="rememberAlumno">Recordarme</label>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary"><i class="fas fa-sign-in-alt me-2"></i> Iniciar Sesión</button>
                            </div>
                            <div class="mt-3 text-center">
                                <a href="#">¿Olvidó su contraseña?</a> 
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal"><i class="fas fa-times me-2"></i> Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="profesorModal" tabindex="-1" aria-labelledby="profesorModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title" id="profesorModalLabel"><i class="fas fa-chalkboard-teacher me-2"></i> Iniciar Sesión Profesor</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="loginServlet" method="post">
                            <input type="hidden" name="userType" value="profesor">
                            <div class="mb-3">
                                <label for="profesorUsernameModal" class="form-label"><i class="fas fa-user me-2"></i> Usuario </label>
                                <input type="text" class="form-control" id="profesorUsernameInput" name="username" placeholder="Ingrese su usuario de profesor" required>
                            </div>
                            <div class="mb-3">
                                <label for="profesorPasswordModal" class="form-label"><i class="fas fa-lock me-2"></i> Contraseña </label>
                                <input type="password" class="form-control" id="profesorPasswordInput" name="password" placeholder="Ingrese su contraseña" required>
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="rememberProfesor">
                                <label class="form-check-label" for="rememberProfesor">Recordarme</label>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-info"><i class="fas fa-sign-in-alt me-2"></i> Iniciar Sesión</button>
                            </div>
                            <div class="mt-3 text-center">
                                <a href="#">¿Olvidó su contraseña?</a> 
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal"><i class="fas fa-times me-2"></i> Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="apoderadoModal" tabindex="-1" aria-labelledby="apoderadoModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title" id="apoderadoModalLabel"><i class="fas fa-user-friends me-2"></i> Iniciar Sesión Apoderado</h5>
                        <button type="button" class="btn-close btn-close-dark" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="loginServlet" method="post">
                            <input type="hidden" name="userType" value="apoderado">
                            <div class="mb-3">
                                <label for="apoderadoUsernameModal" class="form-label"><i class="fas fa-user me-2"></i> Usuario</label>
                                <input type="text" class="form-control" id="apoderadoUsernameInput" name="username" placeholder="Ingrese su usuario de apoderado" required>
                            </div>
                            <div class="mb-3">
                                <label for="apoderadoPasswordModal" class="form-label"><i class="fas fa-lock me-2"></i> Contraseña</label>
                                <input type="password" class="form-control" id="apoderadoPasswordInput" name="password" placeholder="Ingrese su contraseña" required>
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="rememberApoderado">
                                <label class="form-check-label" for="rememberApoderado">Recordarme</label>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-warning text-dark"><i class="fas fa-sign-in-alt me-2"></i> Iniciar Sesión</button>
                            </div>
                            <div class="mt-3 text-center">
                                <a href="#">¿Olvidó su contraseña?</a> 
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal"><i class="fas fa-times me-2"></i> Cerrar</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="adminModal" tabindex="-1" aria-labelledby="adminModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="adminModalLabel"><i class="fas fa-user-shield me-2"></i> Iniciar Sesión Administrador</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="loginServlet" method="post">
                            <input type="hidden" name="userType" value="admin">
                            <div class="mb-3">
                                <label for="adminUsernameModal" class="form-label"><i class="fas fa-user me-2"></i> Usuario </label>
                                <input type="text" class="form-control" id="adminUsernameInput" name="username" placeholder="Ingrese su usuario de administrador" required>
                            </div>
                            <div class="mb-3">
                                <label for="adminPasswordModal" class="form-label"><i class="fas fa-lock me-2"></i> Contraseña </label>
                                <input type="password" class="form-control" id="adminPasswordInput" name="password" placeholder="Ingrese su contraseña" required>
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="rememberAdmin">
                                <label class="form-check-label" for="rememberAdmin">Recordarme</label>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-success"><i class="fas fa-sign-in-alt me-2"></i> Iniciar Sesión</button>
                            </div>
                            <div class="mt-3 text-center">
                                <a href="#">¿Olvidó su contraseña?</a> 
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal"><i class="fas fa-times me-2"></i> Cerrar</button>
                    </div>
                </div>
            </div>
        </div>
        <footer style="background-color: #222; color: white; text-align: center; padding: 30px 20px; font-size: 16px; margin-top: 60px;">
            <p>&copy; 2025 Universidad Global de Innovación y Conocimiento (UGIC). Todos los derechos reservados.</p>
            <p>Contacto: info@ugic.edu | Tel: +123 456 7890</p>
            <div style="margin-top: 10px;">
                <a href="#" style="color: #ccc; margin: 0 10px; text-decoration: none;">Aviso legal</a>
                |
                <a href="#" style="color: #ccc; margin: 0 10px; text-decoration: none;">Política de privacidad</a>
                |
                <a href="#" style="color: #ccc; margin: 0 10px; text-decoration: none;">Términos de uso</a>
            </div>
        </footer>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>