<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UGIC Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OerSvFwwjofx2zWfKzS0sVbF/HjFwprh3P5d" crossorigin="anonymous">
    <link rel="stylesheet" href="css/estilos.css">
    <style>
        /* Estilos específicos para la página principal del portal si no los tienes en estilos.css */
        body {
            background-color: #f8f9fa; /* Un color de fondo suave */
        }
        .hero-section {
            background: linear-gradient(to right, #007bff, #0056b3); /* Degradado azul */
            color: white;
            padding: 80px 0;
            margin-top: 56px; /* Para dejar espacio a la navbar */
        }
        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: 700;
        }
        .hero-section p {
            font-size: 1.25rem;
            margin-top: 15px;
        }
        .hero-section .btn {
            font-size: 1.1rem;
            padding: 12px 30px;
            border-radius: 30px;
            margin-top: 30px;
            transition: all 0.3s ease;
        }
        .hero-section .btn-light:hover {
            background-color: #e2e6ea;
            color: #0056b3;
        }
        .about-section {
            background-color: #ffffff;
            padding: 60px 0;
        }
        .about-section h2 {
            color: #0056b3;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="index.jsp">UGIC Portal</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link active" aria-current="page" href="index.jsp">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Carreras Pregrado</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Carreras a Distancia</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Posgrado</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Nosotros</a>
                    </li>
                </ul>
                <form class="d-flex me-2">
                    <input class="form-control me-2" type="search" placeholder="Buscar" aria-label="Search">
                    <button class="btn btn-outline-light" type="submit">Buscar</button>
                </form>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="btn btn-primary me-2" href="postulacion_registro.jsp">Postular a UGIC</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-outline-light" href="login.jsp">Iniciar Sesión</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="hero-section text-center">
        <div class="container">
            <h1 class="display-4 mb-3 animate__animated animate__fadeInDown">Bienvenido al Portal de la Universidad UGIC</h1>
            <p class="lead animate__animated animate__fadeInUp">Tu camino hacia el futuro comienza aquí.</p>
            <a class="btn btn-light btn-lg animate__animated animate__zoomIn" href="postulacion_registro.jsp" role="button">
                ¡Postula Ahora!
            </a>
        </div>
    </div>

    <div class="about-section">
        <div class="container">
            <h2 class="text-center mb-5">SOBRE NOSOTROS</h2>
            <div class="row">
                <div class="col-md-6">
                    <img src="https://via.placeholder.com/500x300?text=Campus+UGIC" class="img-fluid rounded shadow-sm mb-4" alt="Campus UGIC">
                </div>
                <div class="col-md-6">
                    <p class="lead">La Universidad de Gestión e Innovación del Conocimiento (UGIC) es una institución educativa de nivel superior comprometida con la excelencia académica y la formación integral de profesionales líderes y éticos. Nuestra misión es impulsar el desarrollo social y económico a través de la investigación, la innovación y la transferencia de conocimiento.</p>
                    <p>En UGIC, ofrecemos una amplia gama de carreras de pregrado, posgrado y educación a distancia, diseñadas para responder a las demandas del mercado laboral global. Contamos con un cuerpo docente altamente calificado, infraestructura moderna y programas de estudio actualizados que garantizan una educación de calidad.</p>
                    <p>Te invitamos a ser parte de nuestra comunidad, donde podrás desarrollar tu potencial, alcanzar tus metas y contribuir al progreso de la sociedad.</p>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <div class="container">
            <p>&copy; <%= java.time.Year.now().getValue() %> Universidad UGIC. Todos los derechos reservados.</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>
