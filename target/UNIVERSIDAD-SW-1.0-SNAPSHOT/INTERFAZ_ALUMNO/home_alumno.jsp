<%-- 
    Document   : home_alumno
    Created on : 2 may. 2025, 09:32:48
    Author     : LENOVO
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="pe.universidad.util.Conexion" %> <%-- Importa tu clase Conexion --%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <style>
    body {
        background-color: #f0f2f5;
        min-height: 100vh;
        display: flex;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        margin: 0;
    }
    
    .sidebar {
        background: linear-gradient(to bottom, #2c3e50, #1a252f);
        color: white;
        padding-top: 20px;
        width: 280px;
        flex-shrink: 0;
        box-shadow: 3px 0 10px rgba(0, 0, 0, 0.1);
        transition: width 0.3s ease;
        z-index: 100;
    }
    
    .sidebar.collapsed {
        width: 80px;
    }
    
    .sidebar h2 {
        padding: 15px 20px;
        margin-bottom: 25px;
        border-bottom: 2px solid rgba(255, 255, 255, 0.1);
        font-size: 1.6rem;
        text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
        position: relative;
    }
    
    .sidebar h2::after {
        content: '';
        position: absolute;
        left: 20px;
        bottom: -2px;
        width: 50px;
        height: 3px;
        background-color: #3498db;
        transition: width 0.3s ease;
    }
    
    .sidebar h2:hover::after {
        width: 100px;
    }
    
    .sidebar ul {
        list-style: none;
        padding-left: 0;
        margin-bottom: 0;
    }
    
    .sidebar ul li {
        margin-bottom: 5px;
    }
    
    .sidebar ul li a {
        display: flex;
        align-items: center;
        padding: 14px 20px;
        text-decoration: none;
        color: #ecf0f1;
        transition: all 0.3s ease;
        border-left: 4px solid transparent;
        font-weight: 500;
    }
    
    .sidebar ul li a i {
        margin-right: 12px;
        font-size: 18px;
        transition: transform 0.3s ease;
    }
    
    .sidebar ul li a:hover {
        background-color: rgba(255, 255, 255, 0.1);
        border-left: 4px solid #3498db;
        transform: translateX(5px);
    }
    
    .sidebar ul li a:hover i {
        transform: scale(1.2);
        color: #3498db;
    }
    
    .sidebar ul li a.active {
        background-color: rgba(52, 152, 219, 0.2);
        border-left: 4px solid #3498db;
        color: #3498db;
    }
    
    .btn-cerrar-sesion {
        margin-top: 30px;
        display: block;
        padding: 14px 20px;
        color: #ecf0f1;
        text-decoration: none;
        transition: all 0.3s ease;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
        font-weight: 500;
    }
    
    .btn-cerrar-sesion:hover {
        background-color: rgba(231, 76, 60, 0.2);
        color: #e74c3c;
    }
    
    .btn-cerrar-sesion i {
        margin-right: 10px;
        transition: transform 0.3s ease;
    }
    
    .btn-cerrar-sesion:hover i {
        transform: translateX(-5px);
    }
    
    .content {
        flex-grow: 1;
        padding: 30px;
        transition: margin-left 0.3s ease;
    }
    
    .dynamic-content {
        background-color: #fff;
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        margin-bottom: 25px;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .dynamic-content:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
    }
    
    .alumno-info {
        background-color: #fff;
        padding: 25px;
        border-radius: 12px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
        margin-bottom: 25px;
        border-top: 4px solid #3498db;
        transition: all 0.3s ease;
    }
    
    .alumno-info:hover {
        box-shadow: 0 8px 25px rgba(52, 152, 219, 0.2);
    }
    
    /* Header con nombre del usuario */
    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 20px 20px 0;
        margin-bottom: 20px;
    }
    
    .user-welcome {
        font-size: 1.8rem;
        color: #2c3e50;
        font-weight: 600;
    }
    
    .user-welcome span {
        color: #3498db;
        border-bottom: 2px dashed #3498db;
        padding-bottom: 2px;
    }
    
    /* Notificaciones */
    .notification-badge {
        position: relative;
        display: inline-block;
        margin-left: 15px;
    }
    
    .notification-badge .badge {
        position: absolute;
        top: -8px;
        right: -8px;
        padding: 4px 8px;
        border-radius: 50%;
        background-color: #e74c3c;
        color: white;
        font-size: 12px;
        font-weight: bold;
        animation: pulse 1.5s infinite;
    }
    
    @keyframes pulse {
        0% {
            transform: scale(1);
            opacity: 1;
        }
        50% {
            transform: scale(1.2);
            opacity: 0.8;
        }
        100% {
            transform: scale(1);
            opacity: 1;
        }
    }
    
    /* Tarjetas animadas */
    .card-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .card {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        transition: all 0.3s ease;
        overflow: hidden;
        position: relative;
    }
    
    .card:hover {
        transform: translateY(-10px);
        box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
    }
    
    .card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 5px;
        height: 100%;
        background: #3498db;
        transform: scaleY(0);
        transition: transform 0.3s ease;
        transform-origin: bottom;
    }
    
    .card:hover::before {
        transform: scaleY(1);
    }
    
    .card-title {
        margin-bottom: 15px;
        color: #2c3e50;
        font-weight: 600;
        display: flex;
        align-items: center;
    }
    
    .card-title i {
        margin-right: 10px;
        color: #3498db;
        font-size: 1.2em;
    }
    
    /* Botones con efectos */
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }
    
    .btn-primary {
        background-color: #3498db;
        color: white;
    }
    
    .btn-primary:hover {
        background-color: #2980b9;
        box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
    }
    
    .btn::after {
        content: '';
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        left: -100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: 0.5s;
    }
    
    .btn:hover::after {
        left: 100%;
    }
</style>
</head>
<body>
    <div class="sidebar">
        <h2>Panel del Alumno</h2>
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link" href="informacion_alumno.jsp" data-target="#contenido-principal">Información del Alumno</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ver_cursos_inscritos.jsp" data-target="#contenido-principal">Ver Cursos Inscritos</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ver_horarios.jsp" data-target="#contenido-principal">Ver Horario</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ver_notas.jsp" data-target="#contenido-principal">Ver Mis Notas</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ver_pagos.jsp" data-target="#contenido-principal">Realizar Pago</a>
            </li>      
            <a href="#" onclick="confirmarCerrarSesion(); return false;" class="btn-cerrar-sesion">     Cerrar Sesión</a>

            <script>
            function confirmarCerrarSesion() {
            if (confirm('¿Está seguro que desea cerrar la sesión?')) {
            window.location.href = '${pageContext.request.contextPath}/Plataforma.jsp';
            }
        }
</script>
        </ul>
    </div>

    <div class="content">
        <div id="contenido-principal" class="dynamic-content">
            <%-- Contenido inicial o dinámico se cargará aquí --%>
            <%@ include file="informacion_alumno.jsp" %> <%-- Incluye la información del alumno inicialmente --%>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const navLinks = document.querySelectorAll('.sidebar ul li a');
            const contenidoPrincipal = document.getElementById('contenido-principal');

            navLinks.forEach(link => {
                link.addEventListener('click', function(event) {
                    event.preventDefault(); // Evita la navegación predeterminada

                    const url = this.getAttribute('href');
                    const targetId = this.getAttribute('data-target');

                    if (targetId) {
                        fetch(url)
                            .then(response => response.text())
                            .then(data => {
                                document.querySelector(targetId).innerHTML = data;
                            })
                            .catch(error => {
                                console.error('Error al cargar el contenido:', error);
                                document.querySelector(targetId).innerHTML = '<p class="text-danger">Error al cargar el contenido.</p>';
                            });
                    } else {
                        // Si el enlace no tiene un data-target, realiza la navegación normal (como el cierre de sesión)
                        window.location.href = url;
                    }
                });
            });
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>
</html>