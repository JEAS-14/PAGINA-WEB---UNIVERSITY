<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Nota, pe.edu.dao.NotaDao" %>
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
        <title>Confirmar Eliminación de Nota</title>        
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

                        try {
                            // Crear instancia de NotaDao directamente
                            NotaDao notaDao = new NotaDao();
                            
                            // Obtener el ID de la nota desde la URL
                            String id = request.getParameter("id");
                            
                            // Si el ID no es nulo, cargar los datos de la nota de la base de datos
                            if (id != null && !id.isEmpty()) {
                                nota = notaDao.leer(id);
                                if (nota != null) {
                                    notaEncontrada = true;
                                } else {
                                    mensaje = "No se encontró la nota con ID: " + id + ".";
                                    tipoMensaje = "danger";
                                }
                            } else {
                                mensaje = "ID de nota no proporcionado para confirmar eliminación.";
                                tipoMensaje = "warning";
                            }
                        } catch (Exception e) {
                            mensaje = "Error al cargar los datos de la nota: " + e.getMessage();
                            tipoMensaje = "danger";
                            System.out.println("Error en eliminar.jsp: " + e.getMessage());
                            e.printStackTrace();
                        }
                    %>
                    
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-12 col-md-8 col-lg-6">
                                <!-- Mostrar mensajes si existen -->
                                <% if (!mensaje.isEmpty()) { %>
                                    <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                                        <%= mensaje %>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                <% } %>

                                <div class="card shadow">
                                    <div class="card-header bg-danger text-white">
                                        <h4 class="mb-0">
                                            <i class="fas fa-exclamation-triangle me-2"></i>Confirmar Eliminación
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <% if (!notaEncontrada) { %>
                                            <div class="d-grid gap-2">
                                                <a href="listado.jsp" class="btn btn-primary d-flex align-items-center justify-content-center mt-3">
                                                    <i class="fas fa-arrow-left me-2"></i>Volver al Listado
                                                </a>
                                            </div>
                                        <% } else { %>
                                            <p class="text-danger lead mb-4">
                                                ¿Está seguro que desea eliminar la siguiente nota?
                                                Esta acción no se puede deshacer.
                                            </p>
                                            
                                            <div class="row mb-4">
                                                <div class="col-md-6">
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold">
                                                            <i class="fas fa-fingerprint me-1"></i>ID Nota:
                                                        </label>
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
                                                                                idNota = "-";
                                                                            }
                                                                        }
                                                                    }
                                                                    out.print(idNota != null ? idNota.toString() : "-");
                                                                } catch (Exception e) {
                                                                    out.print("-");
                                                                }
                                                            %>
                                                        </p>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold">
                                                            <i class="fas fa-id-badge me-1"></i>ID Inscripción:
                                                        </label>
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
                                                                            idInscripcion = "-";
                                                                        }
                                                                    }
                                                                    out.print(idInscripcion != null ? idInscripcion.toString() : "-");
                                                                } catch (Exception e) {
                                                                    out.print("-");
                                                                }
                                                            %>
                                                        </p>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold">
                                                            <i class="fas fa-calendar me-1"></i>Fecha Registro:
                                                        </label>
                                                        <p class="form-control-plaintext">
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
                                                                            fecha = null;
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
                                                                out.print("-");
                                                            }
                                                            %>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Notas -->
                                            <div class="row mb-4">
                                                <div class="col-12">
                                                    <h6 class="fw-bold mb-3">
                                                        <i class="fas fa-clipboard-check me-2"></i>Calificaciones:
                                                    </h6>
                                                    <div class="row">
                                                        <!-- Nota 1 -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Nota 1:</label>
                                                            <div>
                                                                <% if (nota.getNota1() != null) { %>
                                                                    <% boolean esAprobado1 = nota.getNota1().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge <%= esAprobado1 ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getNota1().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Nota 2 -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Nota 2:</label>
                                                            <div>
                                                                <% if (nota.getNota2() != null) { %>
                                                                    <% boolean esAprobado2 = nota.getNota2().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge <%= esAprobado2 ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getNota2().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Nota 3 -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Nota 3:</label>
                                                            <div>
                                                                <% if (nota.getNota3() != null) { %>
                                                                    <% boolean esAprobado3 = nota.getNota3().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge <%= esAprobado3 ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getNota3().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Examen Parcial -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Ex. Parcial:</label>
                                                            <div>
                                                                <% if (nota.getExamen_parcial() != null) { %>
                                                                    <% boolean esAprobadoP = nota.getExamen_parcial().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge <%= esAprobadoP ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getExamen_parcial().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Examen Final -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Ex. Final:</label>
                                                            <div>
                                                                <% if (nota.getExamen_final() != null) { %>
                                                                    <% boolean esAprobadoF = nota.getExamen_final().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge <%= esAprobadoF ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getExamen_final().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Nota Final -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Nota Final:</label>
                                                            <div>
                                                                <% if (nota.getNota_final() != null) { %>
                                                                    <% boolean esAprobadoFinal = nota.getNota_final().compareTo(notaAprobatoria) >= 0; %>
                                                                    <span class="badge fs-6 <%= esAprobadoFinal ? "bg-success" : "bg-danger" %>">
                                                                        <%= nota.getNota_final().toString() %>
                                                                    </span>
                                                                <% } else { %>
                                                                    <span class="text-muted">-</span>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- Estado -->
                                                        <div class="col-6 col-md-3 mb-2">
                                                            <label class="form-label fw-bold">Estado:</label>
                                                            <div>
                                                                <% 
                                                                    String estado = (nota.getEstado() != null) ? nota.getEstado() : "pendiente";
                                                                    String badgeClass = "";
                                                                    String iconClass = "";
                                                                    
                                                                    if ("aprobado".equals(estado.toLowerCase())) {
                                                                        badgeClass = "badge bg-success";
                                                                        iconClass = "fas fa-check-circle";
                                                                    } else if ("desaprobado".equals(estado.toLowerCase())) {
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
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Formulario para confirmar la eliminación -->
                                            <form action="../NotaController" method="post">        
                                                <input type="hidden" name="accion" value="eliminar">
                                                <input type="hidden" name="id" value="<%= request.getParameter("id") %>">
                                                                                        
                                                <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                                    <a href="listado.jsp" class="btn btn-secondary d-flex align-items-center me-md-2">
                                                        <i class="fas fa-times-circle me-2"></i>Cancelar
                                                    </a>
                                                    <button type="submit" class="btn btn-danger d-flex align-items-center">
                                                        <i class="fas fa-trash-alt me-2"></i>Confirmar Eliminación
                                                    </button>
                                                </div>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
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