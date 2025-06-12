<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList" %>
<%@page import="pe.edu.entity.Nota" %>
<%@page import="pe.edu.dao.NotaDao" %>
<%@page import="java.math.BigDecimal" %>
<%@page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
        <%@include file="../util/referencias.jsp" %>
        <title>Listado de Notas</title>

        <style>
            /* Estilos generales para el fondo y el área de contenido */
            body {
                background-color: #f0f2f5;
            }
            .col.py-3 {
                background-color: #f0f2f5;
                padding: 30px;
            }

            /* Estilos para la tarjeta principal de la tabla */
            .card_tabla {
                background-color: #ffffff;
                border: none;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                overflow: hidden;
            }

            /* Estilos para el encabezado de la tarjeta (título) */
            .card_titulo {
                background-color: #0d6efd;
                color: #ffffff;
                padding: 20px 25px;
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
                border-top-left-radius: 12px;
                border-top-right-radius: 12px;
            }
            .card_titulo h2 {
                margin-bottom: 0;
                font-weight: 600;
                font-size: 1.8rem;
            }

            /* Estilos para el cuerpo de la tarjeta */
            .card-body {
                padding: 25px;
            }

            /* Estilos para el botón "Nuevo" */
            .btn-primary {
                background-color: #28a745;
                border-color: #28a745;
                font-weight: 500;
                padding: 10px 20px;
                border-radius: 8px;
                transition: background-color 0.2s, border-color 0.2s;
            }
            .btn-primary:hover {
                background-color: #218838;
                border-color: #1e7e34;
            }

            /* Estilos para la tabla de datos */
            .card_contenido {
                width: 100% !important;
                margin-top: 20px;
                border-collapse: separate;
                border-spacing: 0;
            }

            .card_contenido thead {
                background-color: #e9ecef;
                color: #495057;
            }

            .card_contenido th {
                padding: 15px;
                text-align: left;
                font-weight: 600;
                border-bottom: 2px solid #dee2e6;
            }
            
            .card_contenido thead tr th:first-child {
                border-top-left-radius: 8px;
            }
            .card_contenido thead tr th:last-child {
                border-top-right-radius: 8px;
            }

            .card_contenido tbody tr {
                border-bottom: 1px solid #e9ecef;
            }

            .card_contenido tbody tr:last-child {
                border-bottom: none;
            }

            .card_contenido td {
                padding: 12px 15px;
                vertical-align: middle;
            }

            .card_contenido tbody tr:hover {
                background-color: #f5f5f5;
            }

            /* Estilos para los botones de acción dentro de la tabla */
            .card_contenido .btn {
                padding: 6px 12px;
                border-radius: 5px;
                font-size: 0.85rem;
                font-weight: 500;
                margin: 0 2px;
            }
            .card_contenido .btn-info {
                background-color: #17a2b8;
                border-color: #17a2b8;
            }
            .card_contenido .btn-info:hover {
                background-color: #138496;
                border-color: #117a8b;
            }
            .card_contenido .btn-warning {
                background-color: #ffc107;
                border-color: #ffc107;
                color: #212529;
            }
            .card_contenido .btn-warning:hover {
                background-color: #e0a800;
                border-color: #d39e00;
            }
            .card_contenido .btn-danger {
                background-color: #dc3545;
                border-color: #dc3545;
            }
            .card_contenido .btn-danger:hover {
                background-color: #c82333;
                border-color: #bd2130;
            }

            /* Contenedor responsivo para la tabla */
            .table-responsive {
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }

            /* Ajustes para el contenedor principal */
            .container-fluid {
                padding: 0;
            }
            .row.flex-nowrap {
                height: 100vh;
            }

            /* Estilos para badges de notas */
            .badge {
                font-size: 0.75rem;
                padding: 0.5em 0.75em;
            }
        </style>
    </head>
    
    <body>
        <%-- Instancia de NotaDao para interactuar con la base de datos --%>
        <jsp:useBean id="notaDao" class="pe.edu.dao.NotaDao" scope="session"></jsp:useBean>
        
        <div class="container-fluid">
            <div class="row flex-nowrap">
                
                <%-- Incluye el menú (sidebar) con todos los paneles --%>
                <%@include file="../menu.jsp" %>
                        
                <div class="col py-3">
                    <%
                        String mensaje = "";
                        String tipoMensaje = "";
                        LinkedList<Nota> listaNotas = null;
                        BigDecimal notaAprobatoria = new BigDecimal("11");
                        
                        // Mostrar mensajes de sesión
                        String mensajeSesion = (String) session.getAttribute("mensaje");
                        String errorSesion = (String) session.getAttribute("error");
                        
                        if (mensajeSesion != null) {
                            mensaje = mensajeSesion;
                            tipoMensaje = "success";
                            session.removeAttribute("mensaje");
                        } else if (errorSesion != null) {
                            mensaje = errorSesion;
                            tipoMensaje = "danger";
                            session.removeAttribute("error");
                        }
                        
                        // Crear instancia de NotaDao directamente
                        NotaDao notaDaoInstance = new NotaDao();
                        
                        try {
                            listaNotas = notaDaoInstance.listar();
                            if (listaNotas == null || listaNotas.isEmpty()) {
                                listaNotas = new LinkedList<Nota>();
                                if (mensaje.isEmpty()) {
                                    mensaje = "No se encontraron notas registradas.";
                                    tipoMensaje = "info";
                                }
                            }
                        } catch (Exception e) {
                            mensaje = "Error al cargar las notas: " + e.getMessage();
                            tipoMensaje = "danger";
                            listaNotas = new LinkedList<Nota>();
                            System.out.println("Error en listado.jsp: " + e.getMessage());
                            e.printStackTrace();
                        }
                    %>
                    
                    <center>
                        <!-- Mostrar mensajes si existen -->
                        <% if (!mensaje.isEmpty()) { %>
                            <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert" style="max-width: 1200px;">
                                <%= mensaje %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>

                        <div class="card card_tabla">
                            <div class="card-header card_titulo">
                                <h2><i class="fas fa-clipboard-check me-2"></i>Gestión de Notas</h2>
                            </div>
                            <br>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-sm-1">
                                        <a href="nuevo.jsp" class="btn btn-primary">
                                            <i class="fas fa-plus-circle me-2"></i>Nuevo
                                        </a>
                                    </div>
                                    <div class="col-sm-11"></div>
                                </div>
                                <br>
                                
                                <% if (listaNotas != null && !listaNotas.isEmpty()) { %>
                                    <div class="table-responsive">
                                        <table id="myTable" class="display table table-light table-striped table-hover card_contenido">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>ID Inscripción</th>
                                                    <th>Nota 1</th>
                                                    <th>Nota 2</th>
                                                    <th>Nota 3</th>
                                                    <th>Examen Parcial</th>
                                                    <th>Examen Final</th>
                                                    <th>Nota Final</th>
                                                    <th>Estado</th>
                                                    <th>Fecha Registro</th>
                                                    <th>Ver</th>
                                                    <th>Editar</th>
                                                    <th>Eliminar</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% 
                                                for (Nota n : listaNotas) { 
                                                    // Variables para simplificar el código - usando métodos genéricos
                                                    String idNota = "-";
                                                    String idInscripcion = "-";
                                                    
                                                    try {
                                                        // Intenta diferentes nombres de métodos posibles
                                                        Object id = null;
                                                        try {
                                                            id = n.getClass().getMethod("getIdNota").invoke(n);
                                                        } catch (Exception e1) {
                                                            try {
                                                                id = n.getClass().getMethod("getId_nota").invoke(n);
                                                            } catch (Exception e2) {
                                                                try {
                                                                    id = n.getClass().getMethod("getId").invoke(n);
                                                                } catch (Exception e3) {
                                                                    // Si no encuentra el método, usa "-"
                                                                }
                                                            }
                                                        }
                                                        if (id != null) {
                                                            idNota = id.toString();
                                                        }
                                                        
                                                        // Para ID inscripción
                                                        Object idInsc = null;
                                                        try {
                                                            idInsc = n.getClass().getMethod("getIdInscripcion").invoke(n);
                                                        } catch (Exception e1) {
                                                            try {
                                                                idInsc = n.getClass().getMethod("getId_inscripcion").invoke(n);
                                                            } catch (Exception e2) {
                                                                // Si no encuentra el método, usa "-"
                                                            }
                                                        }
                                                        if (idInsc != null) {
                                                            idInscripcion = idInsc.toString();
                                                        }
                                                    } catch (Exception e) {
                                                        System.out.println("Error obteniendo IDs: " + e.getMessage());
                                                    }
                                                %>            
                                                <tr>
                                                    <td><%= idNota %></td>
                                                    <td><%= idInscripcion %></td>
                                                    
                                                    <!-- Nota 1 -->
                                                    <td class="text-center">
                                                        <% if (n.getNota1() != null) { %>
                                                            <% boolean esAprobado1 = n.getNota1().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge <%= esAprobado1 ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getNota1().toString() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Nota 2 -->
                                                    <td class="text-center">
                                                        <% if (n.getNota2() != null) { %>
                                                            <% boolean esAprobado2 = n.getNota2().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge <%= esAprobado2 ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getNota2().toString() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Nota 3 -->
                                                    <td class="text-center">
                                                        <% if (n.getNota3() != null) { %>
                                                            <% boolean esAprobado3 = n.getNota3().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge <%= esAprobado3 ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getNota3().toString() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Examen Parcial -->
                                                    <td class="text-center">
                                                        <% if (n.getExamen_parcial() != null) { %>
                                                            <% boolean esAprobadoP = n.getExamen_parcial().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge <%= esAprobadoP ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getExamen_parcial().toString() %>           
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Examen Final -->
                                                    <td class="text-center">
                                                        <% if (n.getExamen_final() != null) { %>
                                                            <% boolean esAprobadoF = n.getExamen_final().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge <%= esAprobadoF ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getExamen_final().toString() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Nota Final -->
                                                    <td class="text-center">
                                                        <% if (n.getNota_final() != null) { %>
                                                            <% boolean esAprobadoFinal = n.getNota_final().compareTo(notaAprobatoria) >= 0; %>
                                                            <span class="badge fs-6 <%= esAprobadoFinal ? "bg-success" : "bg-danger" %>">
                                                                <%= n.getNota_final().toString() %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
                                                    </td>
                                                    
                                                    <!-- Estado -->
                                                    <td class="text-center">
                                                        <% 
                                                            String estado = (n.getEstado() != null) ? n.getEstado() : "pendiente";
                                                            String badgeClass = "";
                                                            String iconClass = "";
                                                            
                                                            if ("aprobado".equals(estado)) {
                                                                badgeClass = "badge bg-success";
                                                                iconClass = "fas fa-check-circle";
                                                            } else if ("desaprobado".equals(estado)) {
                                                                badgeClass = "badge bg-danger";
                                                                iconClass = "fas fa-times-circle";
                                                            } else {
                                                                badgeClass = "badge bg-warning text-dark";
                                                                iconClass = "fas fa-clock";
                                                            }
                                                        %>
                                                        <span class="<%= badgeClass %>">
                                                            <i class="<%= iconClass %> me-1"></i><%= estado.toUpperCase() %>
                                                        </span>
                                                    </td>
                                                    
                                                    <!-- Fecha Registro -->
                                                    <td class="text-center">
                                                        <small class="text-muted">
                                                            <%
                                                            try {
                                                                Object fecha = null;
                                                                // Intenta diferentes nombres de métodos para fecha
                                                                try {
                                                                    fecha = n.getClass().getMethod("getFechaRegistro").invoke(n);
                                                                } catch (Exception e1) {
                                                                    try {
                                                                        fecha = n.getClass().getMethod("getFecha_registro").invoke(n);
                                                                    } catch (Exception e2) {
                                                                        try {
                                                                            fecha = n.getClass().getMethod("getFecha").invoke(n);
                                                                        } catch (Exception e3) {
                                                                            // Si no encuentra el método, usa "-"
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                if (fecha != null && fecha instanceof java.util.Date) {
                                                                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                                                                    out.print(sdf.format((java.util.Date)fecha));
                                                                } else {
                                                                    out.print("-");
                                                                }
                                                            } catch (Exception e) {
                                                                out.print("Error");
                                                            }
                                                            %>
                                                        </small>
                                                    </td>
                                                    
                                                    <!-- Acciones -->
                                                    <td><a href="ver.jsp?id=<%= idNota %>" class="btn btn-info"><i class="bi bi-eye-fill"></i></a></td>
                                                    <td><a href="editar.jsp?id=<%= idNota %>" class="btn btn-warning"><i class="bi bi-pencil-square"></i></a></td>
                                                    <td><a href="eliminar.jsp?id=<%= idNota %>" class="btn btn-danger" onclick="return confirm('¿Está seguro que desea eliminar esta nota?')"><i class="bi bi-trash-fill"></i></a></td>
                                                </tr>
                                                <% } %>            
                                            </tbody>
                                        </table> 
                                    </div>
                                <% } else { %>
                                    <div class="alert alert-info mt-3" role="alert">
                                        <i class="fas fa-info-circle me-2"></i>
                                        No hay notas registradas en el sistema.
                                        <div class="mt-3">
                                            <a href="nuevo.jsp" class="btn btn-success">
                                                <i class="fas fa-plus-circle me-2"></i>Registrar Primera Nota
                                            </a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </center>
                </div>
            </div>
        </div>
        
        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- jQuery y DataTables -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
        <script src="https://cdn.datatables.net/2.3.1/js/dataTables.js"></script>
        <script src="https://cdn.datatables.net/2.3.1/js/dataTables.bootstrap5.min.js"></script>

        <script type="text/javascript">
            $(document).ready(function() {
                $('#myTable').DataTable({
                    "language": {
                        "url": "https://cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json"
                    },
                    "responsive": true,
                    "pageLength": 10,
                    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "Todos"]]
                });
            });
        </script>
    </body>
</html>