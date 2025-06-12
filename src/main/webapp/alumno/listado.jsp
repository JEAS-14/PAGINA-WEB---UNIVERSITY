<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Alumno, pe.edu.dao.AlumnoDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%@include file="../util/referencias.jsp" %>
        <title>Listado de Alumnos</title>

        <style>
            /* Estilos generales para el fondo y el área de contenido */
            body {
                background-color: #f0f2f5; /* Un fondo gris claro para la página principal */
            }
            .col.py-3 {
                background-color: #f0f2f5; /* Asegura el mismo fondo para el área de contenido principal */
                padding: 30px; /* Añade un padding general para el contenido principal */
            }

            /* Estilos para la tarjeta principal de la tabla */
            .card_tabla {
                background-color: #ffffff; /* Fondo blanco para la tarjeta */
                border: none; /* Eliminar el borde predeterminado */
                border-radius: 12px; /* Esquinas más redondeadas */
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); /* Sombra suave para darle profundidad */
                overflow: hidden; /* Asegura que los bordes redondeados se apliquen al contenido */
            }

            /* Estilos para el encabezado de la tarjeta (título) */
            .card_titulo {
                background-color: #0d6efd; /* Color azul fuerte para el encabezado, similar a la imagen */
                color: #ffffff; /* Texto blanco */
                padding: 20px 25px; /* Más padding para el título */
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
                border-top-left-radius: 12px; /* Redondear solo las esquinas superiores */
                border-top-right-radius: 12px;
            }
            .card_titulo h2 {
                margin-bottom: 0; /* Eliminar margen inferior del h2 */
                font-weight: 600; /* Un poco más de negrita */
                font-size: 1.8rem; /* Tamaño de fuente más grande para el título */
            }

            /* Estilos para el cuerpo de la tarjeta */
            .card-body {
                padding: 25px; /* Padding para el cuerpo de la tarjeta */
            }

            /* Estilos para el botón "Nuevo" */
            .btn-primary {
                background-color: #28a745; /* Verde similar al de los paneles del dashboard */
                border-color: #28a745;
                font-weight: 500;
                padding: 10px 20px;
                border-radius: 8px; /* Esquinas ligeramente redondeadas */
                transition: background-color 0.2s, border-color 0.2s;
            }
            .btn-primary:hover {
                background-color: #218838; /* Verde más oscuro al pasar el ratón */
                border-color: #1e7e34;
            }

            /* Estilos para la tabla de datos */
            .card_contenido {
                width: 100% !important; /* Asegura que la tabla ocupe el 100% del ancho disponible */
                margin-top: 20px; /* Espacio superior para la tabla */
                border-collapse: separate; /* Permite border-radius en las celdas y filas */
                border-spacing: 0; /* Elimina el espacio entre celdas */
            }

            .card_contenido thead {
                background-color: #e9ecef; /* Fondo gris claro para el encabezado de la tabla */
                color: #495057; /* Color de texto oscuro para el encabezado */
            }

            .card_contenido th {
                padding: 15px; /* Más padding en las celdas del encabezado */
                text-align: left;
                font-weight: 600; /* Más negrita */
                border-bottom: 2px solid #dee2e6; /* Línea de separación más pronunciada */
            }
            
            /* Primer y último th para redondear esquinas del thead */
            .card_contenido thead tr th:first-child {
                border-top-left-radius: 8px;
            }
            .card_contenido thead tr th:last-child {
                border-top-right-radius: 8px;
            }

            .card_contenido tbody tr {
                border-bottom: 1px solid #e9ecef; /* Separador de filas */
            }

            .card_contenido tbody tr:last-child {
                border-bottom: none; /* No hay borde en la última fila */
            }

            .card_contenido td {
                padding: 12px 15px; /* Padding para las celdas del cuerpo */
                vertical-align: middle;
            }

            .card_contenido tbody tr:hover {
                background-color: #f5f5f5; /* Fondo ligero al pasar el ratón sobre las filas */
            }

            /* Estilos para los botones de acción dentro de la tabla */
            .card_contenido .btn {
                padding: 6px 12px;
                border-radius: 5px;
                font-size: 0.85rem; /* Tamaño de fuente más pequeño */
                font-weight: 500;
            }
            .card_contenido .btn-info {
                background-color: #17a2b8; /* Azul cyan */
                border-color: #17a2b8;
            }
            .card_contenido .btn-info:hover {
                background-color: #138496;
                border-color: #117a8b;
            }
            .card_contenido .btn-warning {
                background-color: #ffc107; /* Amarillo */
                border-color: #ffc107;
                color: #212529; /* Texto oscuro para el botón amarillo */
            }
            .card_contenido .btn-warning:hover {
                background-color: #e0a800;
                border-color: #d39e00;
            }
            .card_contenido .btn-danger {
                background-color: #dc3545; /* Rojo */
                border-color: #dc3545;
            }
            .card_contenido .btn-danger:hover {
                background-color: #c82333;
                border-color: #bd2130;
            }

            /* Contenedor responsivo para la tabla */
            .table-responsive {
                overflow-x: auto; /* Permite el scroll horizontal en pantallas pequeñas */
                -webkit-overflow-scrolling: touch; /* Mejora el scroll en dispositivos táctiles */
            }

            /* Ajustes para el contenedor principal para que sidebar y contenido coexistan */
            .container-fluid {
                padding: 0; /* Elimina el padding del container-fluid para que el sidebar no se mueva */
            }
            .row.flex-nowrap {
                height: 100vh; /* Asegura que la fila ocupe toda la altura de la vista */
            }
        </style>
    </head>
    <body>
        <%-- Instancia de AlumnoDao para interactuar con la base de datos --%>
        <jsp:useBean id="alumnoDao" class="pe.edu.dao.AlumnoDao" scope="session"></jsp:useBean>
        <div class="container-fluid">
            <div class="row flex-nowrap">
                
                <%-- Incluye el menú (sidebar) con los estilos actualizados --%>
                <%@include file="../menu.jsp" %>
                        
                <div class="col py-3">
                    <center>
                        <div class="card card_tabla">
                            <div class="card-header card_titulo">
                                <h2>Alumnos</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-sm-1">
                                        <%-- Enlace para crear un nuevo alumno --%>
                                        <a href="../AlumnoController?pagina=nuevo" class="btn btn-primary">Nuevo </a>
                                    </div>
                                    <div class="col-sm-11"></div>
                                </div>
                                <br>
                                <div class="table-responsive"> <%-- Envuelve la tabla en un contenedor responsivo --%>
                                    <table id="myTable" class="display table table-light table-striped table-hover card_contenido">
                                        <thead>
                                            <tr>
                                                <th>Id</th>
                                                <th>DNI</th>
                                                <th>Nombre</th>
                                                <th>Apellido</th>
                                                <th>Dirección</th>
                                                <th>Teléfono</th>
                                                <th>Fecha Nacimiento</th>
                                                <th>Email</th>
                                                <th>Carrera</th>
                                                <th>Rol</th>
                                                <th>Password</th>                                              
                                                <th>Ver</th>
                                                <th>Editar</th>                                            
                                                <th>Eliminar</th>                                            
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                            LinkedList<Alumno> listaAlumnos = alumnoDao.listar();
                                            if (listaAlumnos == null) {
                                                listaAlumnos = new LinkedList<Alumno>();
                                            }
                                            for (Alumno a : listaAlumnos) {
                                        %>                                          
                                            <tr>
                                                <td><%= a.getId() %></td>
                                                <td><%= a.getDni() %></td>
                                                <td><%= a.getNombre() %></td>
                                                <td><%= a.getApellido() %></td>
                                                <td><%= a.getDireccion() %></td>
                                                <td><%= a.getTelefono() %></td>
                                                <td><%= a.getFechaNacimiento() %></td>
                                                <td><%= a.getEmail() %></td>
                                                <td><%= a.getNombreCarrera() %></td>
                                                <td><%= a.getRol() %></td>
                                                <td><%= a.getPassword() %></td>                                              
                                                <%-- Enlaces para Ver, Editar y Eliminar --%>
                                                <td><a href="../AlumnoController?pagina=ver&id=<%= a.getId() %>" class="btn btn-info"><i class="bi bi-eye-fill"></i></a></td>
                                                <td><a href="../AlumnoController?pagina=editar&id=<%= a.getId() %>" class="btn btn-warning"><i class="bi bi-pencil-square"></i></a></td>                                            
                                                <td><a href="../AlumnoController?pagina=eliminar&id=<%= a.getId() %>" class="btn btn-danger"><i class="bi bi-trash-fill"></i></a></td>                                            
                                            </tr>
                                        <%
                                            }
                                        %>                                          
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>

<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
<script src="https://cdn.datatables.net/2.3.1/js/dataTables.js"></script>

<script type="text/javascript">
    $(document).ready(function() {
        $('#myTable').DataTable({
            // Opciones de DataTables para un estilo más limpio (opcional)
            "language": {
                "url": "https://cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json" // Traducción al español
            }
        });
    });
</script>