<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Nota, pe.edu.dao.NotaDao" %>
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
        <title>Editar Nota</title>        
    </head>
    
    <body>            
        <div class="container-fluid">
            <div class="row">
                <!-- Aquí iría tu menú -->
                    
                <div class="col py-3">            
                    <%
                        String mensaje = "";
                        String tipoMensaje = "";
                        Nota nota = null;
                        NotaDao notaDao = new NotaDao();
                        
                        // Obtener el ID de la nota a editar
                        String id = request.getParameter("id");
                        
                        if (id != null && !id.isEmpty()) {
                            try {
                                // Convertir String a Integer para el método buscarPorId
                                Integer idNota = Integer.parseInt(id);
                                nota = notaDao.buscarPorId(idNota);
                                
                                if (nota == null) {
                                    mensaje = "No se encontró la nota con ID: " + id;
                                    tipoMensaje = "danger";
                                }
                            } catch (NumberFormatException e) {
                                mensaje = "ID de nota inválido: " + id;
                                tipoMensaje = "danger";
                                System.out.println("Error de formato en ID: " + e.getMessage());
                            } catch (Exception e) {
                                mensaje = "Error al cargar la nota: " + e.getMessage();
                                tipoMensaje = "danger";
                                System.out.println("Error en editar.jsp: " + e.getMessage());
                                e.printStackTrace();
                            }
                        } else {
                            mensaje = "ID de nota no proporcionado";
                            tipoMensaje = "danger";
                        }
                        
                        // Si hay error, redirigir al listado
                        if (nota == null) {
                            session.setAttribute("error", mensaje);
                            response.sendRedirect("listado.jsp");
                            return;
                        }
                        
                        // Usar directamente los métodos del DAO que coinciden con la entidad
                        String idNotaStr = String.valueOf(nota.getId_nota());
                        String idInscripcionStr = String.valueOf(nota.getId_inscripcion());
                    %>
                    
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-lg-8 col-md-10">
                                <!-- Mostrar mensajes si existen -->
                                <% if (!mensaje.isEmpty()) { %>
                                    <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show" role="alert">
                                        <%= mensaje %>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                <% } %>

                                <div class="card shadow">
                                    <div class="card-header bg-warning text-dark">
                                        <h4 class="mb-0">
                                            <i class="fas fa-edit me-2"></i>Editar Nota
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <form action="../NotaController" method="post">        
                                            <input type="hidden" name="accion" value="editar">
                                            <!-- CORRECCIÓN: Usar los nombres exactos que espera el controlador -->
                                            <input type="hidden" name="id_nota" value="<%= idNotaStr %>">
                                            <input type="hidden" name="id_inscripcion" value="<%= idInscripcionStr %>">
                                                                                        
                                            <%-- Campo ID Nota (solo lectura para visualización) --%>
                                            <div class="mb-3">
                                                <label for="displayIdNota" class="form-label">
                                                    <i class="fas fa-fingerprint me-1"></i>ID Nota:
                                                </label>
                                                <input type="text" id="displayIdNota" class="form-control" readonly 
                                                       value="<%= idNotaStr %>">
                                            </div>

                                            <%-- Campo ID Inscripción (solo lectura para visualización) --%>
                                            <div class="mb-3">
                                                <label for="displayIdInscripcion" class="form-label">
                                                    <i class="fas fa-id-badge me-1"></i>ID Inscripción:
                                                </label>
                                                <input type="text" id="displayIdInscripcion" class="form-control" readonly 
                                                       value="<%= idInscripcionStr %>">
                                            </div>

                                            <%-- Campo Nota 1 --%>
                                            <div class="mb-3">
                                                <label for="nota1" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 1:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="nota1" name="nota1" class="form-control" 
                                                       value="<%= nota.getNota1() != null ? nota.getNota1().toString() : "" %>">
                                            </div>

                                            <%-- Campo Nota 2 --%>
                                            <div class="mb-3">
                                                <label for="nota2" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 2:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="nota2" name="nota2" class="form-control" 
                                                       value="<%= nota.getNota2() != null ? nota.getNota2().toString() : "" %>">
                                            </div>

                                            <%-- Campo Nota 3 --%>
                                            <div class="mb-3">
                                                <label for="nota3" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 3:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="nota3" name="nota3" class="form-control" 
                                                       value="<%= nota.getNota3() != null ? nota.getNota3().toString() : "" %>">
                                            </div>

                                            <%-- Campo Examen Parcial --%>
                                            <div class="mb-3">
                                                <label for="examen_parcial" class="form-label">
                                                    <i class="fas fa-file-alt me-1"></i>Examen Parcial:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="examen_parcial" name="examen_parcial" class="form-control" 
                                                       value="<%= nota.getExamen_parcial() != null ? nota.getExamen_parcial().toString() : "" %>">
                                            </div>

                                            <%-- Campo Examen Final --%>
                                            <div class="mb-3">
                                                <label for="examen_final" class="form-label">
                                                    <i class="fas fa-file-alt me-1"></i>Examen Final:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="examen_final" name="examen_final" class="form-control" 
                                                       value="<%= nota.getExamen_final() != null ? nota.getExamen_final().toString() : "" %>">
                                            </div>

                                            <%-- Campo Nota Final --%>
                                            <div class="mb-3">
                                                <label for="nota_final" class="form-label">
                                                    <i class="fas fa-trophy me-1"></i>Nota Final:
                                                </label>
                                                <input type="number" step="0.01" min="0" max="20" 
                                                       id="nota_final" name="nota_final" class="form-control" 
                                                       value="<%= nota.getNota_final() != null ? nota.getNota_final().toString() : "" %>">
                                                <div class="form-text">
                                                    <i class="fas fa-info-circle me-1"></i>
                                                    Se calculará automáticamente si se deja vacío
                                                </div>
                                            </div>
                                            
                                            <%-- Campo Estado --%>
                                            <div class="mb-3">
                                                <label for="estado" class="form-label">
                                                    <i class="fas fa-check-circle me-1"></i>Estado: *
                                                </label>
                                                <select id="estado" name="estado" class="form-select" required>
                                                    <option value="">-- Seleccionar Estado --</option>
                                                    <% 
                                                        String estadoActual = (nota.getEstado() != null) ? nota.getEstado().toLowerCase() : "";
                                                    %>
                                                    <option value="aprobado" <%= "aprobado".equals(estadoActual) ? "selected" : "" %>>
                                                        Aprobado
                                                    </option>
                                                    <option value="desaprobado" <%= "desaprobado".equals(estadoActual) ? "selected" : "" %>>
                                                        Desaprobado
                                                    </option>
                                                    <option value="pendiente" <%= "pendiente".equals(estadoActual) ? "selected" : "" %>>
                                                        Pendiente
                                                    </option>
                                                </select>
                                            </div>
                                                                                        
                                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                                <a href="listado.jsp" class="btn btn-secondary me-md-2">
                                                    <i class="fas fa-arrow-left me-2"></i>Volver al Listado
                                                </a>
                                                <button type="submit" class="btn btn-warning">
                                                    <i class="fas fa-save me-2"></i>Actualizar Nota
                                                </button>
                                            </div>
                                        </form>
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
        
        <!-- Script para calcular nota final automáticamente -->
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const nota1Input = document.getElementById('nota1');
                const nota2Input = document.getElementById('nota2');
                const nota3Input = document.getElementById('nota3');
                const examenParcialInput = document.getElementById('examen_parcial'); // CORREGIDO
                const examenFinalInput = document.getElementById('examen_final');     // CORREGIDO
                const notaFinalInput = document.getElementById('nota_final');         // CORREGIDO
                const estadoSelect = document.getElementById('estado');
                
                function calcularNotaFinal() {
                    const nota1 = parseFloat(nota1Input.value) || 0;
                    const nota2 = parseFloat(nota2Input.value) || 0;
                    const nota3 = parseFloat(nota3Input.value) || 0;
                    const examenParcial = parseFloat(examenParcialInput.value) || 0;
                    const examenFinal = parseFloat(examenFinalInput.value) || 0;
                    
                    // Fórmula de cálculo (ajusta según tu necesidad)
                    // Ejemplo: promedio de todas las notas ingresadas
                    let contador = 0;
                    let suma = 0;
                    
                    if (nota1 > 0) { suma += nota1; contador++; }
                    if (nota2 > 0) { suma += nota2; contador++; }
                    if (nota3 > 0) { suma += nota3; contador++; }
                    if (examenParcial > 0) { suma += examenParcial; contador++; }
                    if (examenFinal > 0) { suma += examenFinal; contador++; }
                    
                    if (contador > 0) {
                        const promedio = suma / contador;
                        notaFinalInput.value = promedio.toFixed(2);
                        
                        // Actualizar estado automáticamente
                        if (promedio >= 11) {
                            estadoSelect.value = 'aprobado';
                        } else {
                            estadoSelect.value = 'desaprobado';
                        }
                    } else {
                        notaFinalInput.value = '';
                        estadoSelect.value = 'pendiente';
                    }
                }
                
                // Agregar event listeners
                [nota1Input, nota2Input, nota3Input, examenParcialInput, examenFinalInput].forEach(input => {
                    input.addEventListener('input', calcularNotaFinal);
                    input.addEventListener('blur', calcularNotaFinal);
                });
                
                // Debug: Mostrar valores en consola para verificar
                console.log('Form debug info:');
                console.log('ID Nota hidden:', document.querySelector('input[name="id_nota"]').value);
                console.log('ID Inscripción hidden:', document.querySelector('input[name="id_inscripcion"]').value);
            });
        </script>
    </body>
</html>