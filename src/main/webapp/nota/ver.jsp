<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Nota, pe.edu.dao.NotaDao" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.math.BigDecimal" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <title>Ver Nota</title>        
    </head>
    
    <body>            
        <div class="container-fluid">
            <div class="row">
                <!-- Aquí iría tu menú -->
                <div class="col py-3">    
                    <%
                        String mensaje = "";
                        String tipoMensaje = "";
                        boolean notaEncontrada = false;
                        Nota nota = null;
                        BigDecimal notaAprobatoria = new BigDecimal("11");

                        // DEBUG: Mostrar información de la sesión y parámetros
                        String debugInfo = "";
                        
                        try {
                            // Obtener el ID de la nota desde la URL
                            String id = request.getParameter("id");
                            debugInfo = "ID recibido: " + id + " | ";
                            
                            // Verificar si hay mensajes de éxito de edición
                            String mensajeExito = (String) session.getAttribute("mensajeExito");
                            String mensajeError = (String) session.getAttribute("mensajeError");
                            
                            if (mensajeExito != null) {
                                mensaje = mensajeExito;
                                tipoMensaje = "success";
                                session.removeAttribute("mensajeExito");
                                debugInfo += "Mensaje éxito encontrado | ";
                            }
                            
                            if (mensajeError != null) {
                                mensaje = mensajeError;
                                tipoMensaje = "danger";
                                session.removeAttribute("mensajeError");
                                debugInfo += "Mensaje error encontrado | ";
                            }
                            
                            // Si el ID no es nulo, cargar los datos de la nota de la base de datos
                            if (id != null && !id.isEmpty()) {
                                NotaDao notaDao = new NotaDao();
                                nota = notaDao.buscarPorId(Integer.parseInt(id));
                                debugInfo += "DAO creado | ";
                                
                                if (nota != null) {
                                    notaEncontrada = true;
                                    debugInfo += "Nota encontrada | ";
                                } else {
                                    if (mensaje.isEmpty()) { // Solo mostrar si no hay mensaje de sesión
                                        mensaje = "No se encontró la nota con ID: " + id + ".";
                                        tipoMensaje = "danger";
                                    }
                                    debugInfo += "Nota NO encontrada | ";
                                }
                            } else {
                                if (mensaje.isEmpty()) { // Solo mostrar si no hay mensaje de sesión
                                    mensaje = "ID de nota no proporcionado para ver detalles.";
                                    tipoMensaje = "warning";
                                }
                                debugInfo += "ID vacío o nulo | ";
                            }
                        } catch (NumberFormatException e) {
                            mensaje = "ID de nota inválido: " + e.getMessage();
                            tipoMensaje = "danger";
                            debugInfo += "Error NumberFormat: " + e.getMessage() + " | ";
                        } catch (Exception e) {
                            mensaje = "Error al cargar los datos de la nota: " + e.getMessage();
                            tipoMensaje = "danger";
                            debugInfo += "Error general: " + e.getMessage() + " | ";
                            e.printStackTrace();
                        }
                    %>
                    
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-md-10 col-lg-8">
                                <!-- DEBUG INFO (QUITAR EN PRODUCCIÓN) -->
                                <div class="alert alert-info" role="alert">
                                    <small><strong>Debug:</strong> <%= debugInfo %></small>
                                </div>
                                
                                <!-- Mostrar mensajes de error o información -->
                                <% if (!mensaje.isEmpty()) { %>
                                    <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                                        <%= mensaje %>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                <% } %>

                                <% if (notaEncontrada && nota != null) { %>
                                    <div class="card shadow">
                                        <div class="card-header bg-info text-white">
                                            <h4 class="mb-0">
                                                <i class="fas fa-eye me-2"></i>Detalles de la Nota
                                            </h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-fingerprint me-1"></i>ID Nota:</label>
                                                        <p class="form-control-plaintext">
                                                            <%
                                                                try {
                                                                    Object idNota = null;
                                                                    try {
                                                                        idNota = nota.getClass().getMethod("getIdNota").invoke(nota);
                                                                    } catch (Exception e1) {
                                                                        try {
                                                                            idNota = nota.getClass().getMethod("getId_nota").invoke(nota);
                                                                        } catch (Exception e2) {
                                                                            try {
                                                                                idNota = nota.getClass().getMethod("getId").invoke(nota);
                                                                            } catch (Exception e3) {
                                                                                idNota = "N/A";
                                                                            }
                                                                        }
                                                                    }
                                                                    out.print(idNota != null ? idNota.toString() : "N/A");
                                                                } catch (Exception e) {
                                                                    out.print("N/A");
                                                                }
                                                            %>
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-id-badge me-1"></i>ID Inscripción:</label>
                                                        <p class="form-control-plaintext">
                                                            <%
                                                                try {
                                                                    Object idInscripcion = null;
                                                                    try {
                                                                        idInscripcion = nota.getClass().getMethod("getIdInscripcion").invoke(nota);
                                                                    } catch (Exception e1) {
                                                                        try {
                                                                            idInscripcion = nota.getClass().getMethod("getId_inscripcion").invoke(nota);
                                                                        } catch (Exception e2) {
                                                                            idInscripcion = "N/A";
                                                                        }
                                                                    }
                                                                    out.print(idInscripcion != null ? idInscripcion.toString() : "N/A");
                                                                } catch (Exception e) {
                                                                    out.print("N/A");
                                                                }
                                                            %>
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-calculator me-1"></i>Nota 1:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getNota1() != null) { %>
                                                                <% boolean esAprobado1 = nota.getNota1().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge <%= esAprobado1 ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getNota1().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-calculator me-1"></i>Nota 2:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getNota2() != null) { %>
                                                                <% boolean esAprobado2 = nota.getNota2().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge <%= esAprobado2 ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getNota2().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-calculator me-1"></i>Nota 3:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getNota3() != null) { %>
                                                                <% boolean esAprobado3 = nota.getNota3().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge <%= esAprobado3 ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getNota3().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>
                                                </div>
                                                
                                                <div class="col-md-6">
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-clipboard-check me-1"></i>Examen Parcial:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getExamen_parcial() != null) { %>
                                                                <% boolean esAprobadoP = nota.getExamen_parcial().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge <%= esAprobadoP ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getExamen_parcial().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-graduation-cap me-1"></i>Examen Final:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getExamen_final() != null) { %>
                                                                <% boolean esAprobadoF = nota.getExamen_final().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge <%= esAprobadoF ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getExamen_final().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-trophy me-1"></i>Nota Final:</label>
                                                        <p class="form-control-plaintext">
                                                            <% if (nota.getNota_final() != null) { %>
                                                                <% boolean esAprobadoFinal = nota.getNota_final().compareTo(notaAprobatoria) >= 0; %>
                                                                <span class="badge fs-5 <%= esAprobadoFinal ? "bg-success" : "bg-danger" %>">
                                                                    <%= nota.getNota_final().toString() %>
                                                                </span>
                                                            <% } else { %>
                                                                <span class="text-muted">N/A</span>
                                                            <% } %>
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-check-circle me-1"></i>Estado:</label>
                                                        <% 
                                                            String estado = (nota.getEstado() != null) ? nota.getEstado() : "pendiente";
                                                            String estadoClass = "";
                                                            String estadoIcon = "";
                                                            
                                                            if ("aprobado".equals(estado.toLowerCase())) {
                                                                estadoClass = "text-success";
                                                                estadoIcon = "fas fa-check-circle";
                                                            } else if ("desaprobado".equals(estado.toLowerCase())) {
                                                                estadoClass = "text-danger";
                                                                estadoIcon = "fas fa-times-circle";
                                                            } else {
                                                                estadoClass = "text-warning";
                                                                estadoIcon = "fas fa-clock";
                                                            }
                                                        %>
                                                        <p class="form-control-plaintext <%= estadoClass %> fw-bold">
                                                            <i class="<%= estadoIcon %> me-1"></i><%= estado.toUpperCase() %>
                                                        </p>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold"><i class="fas fa-calendar-plus me-1"></i>Fecha Registro:</label>
                                                        <p class="form-control-plaintext">
                                                            <small class="text-muted">
                                                                <%
                                                                try {
                                                                    Object fecha = null;
                                                                    try {
                                                                        fecha = nota.getClass().getMethod("getFechaRegistro").invoke(nota);
                                                                    } catch (Exception e1) {
                                                                        try {
                                                                            fecha = nota.getClass().getMethod("getFecha_registro").invoke(nota);
                                                                        } catch (Exception e2) {
                                                                            try {
                                                                                fecha = nota.getClass().getMethod("getFecha").invoke(nota);
                                                                            } catch (Exception e3) {
                                                                                // Si no encuentra el método, usa null
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    if (fecha != null && fecha instanceof java.util.Date) {
                                                                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                                                                        out.print(sdf.format((java.util.Date)fecha));
                                                                    } else {
                                                                        out.print("N/A");
                                                                    }
                                                                } catch (Exception e) {
                                                                    out.print("Error al mostrar fecha");
                                                                }
                                                                %>
                                                            </small>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <!-- BOTÓN PARA REGRESAR A LISTADO.JSP -->
                                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                                <!-- Botón Volver al Listado - RUTA DIRECTA A LISTADO.JSP -->
                                                <a href="listado.jsp" class="btn btn-primary">
                                                    <i class="fas fa-arrow-left me-2"></i>Volver al Listado
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                <% } else { %>
                                    <!-- MENSAJE DE ERROR TAMBIÉN ACTUALIZADO -->
                                    <div class="alert alert-info mt-3" role="alert">
                                        <i class="fas fa-info-circle me-2"></i>
                                        No hay datos de nota para mostrar. Por favor, asegúrese de que el ID sea válido.
                                        <div class="mt-3">
                                            <!-- Botón Volver - RUTA DIRECTA A LISTADO.JSP -->
                                            <a href="listado.jsp" class="btn btn-primary">
                                                <i class="fas fa-arrow-left me-2"></i>Volver al Listado
                                            </a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>