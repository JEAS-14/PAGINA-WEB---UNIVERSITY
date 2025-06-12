<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <title>Nueva Nota</title>        
    </head>
    <body>            
        <div class="container-fluid">
            <div class="row">
                <!-- Aquí iría tu menú -->
                    
                <div class="col py-3">            
                    <div class="container">
                        <div class="row justify-content-center">
                            <div class="col-md-8 col-lg-6">
                                <div class="card shadow">
                                    <div class="card-header bg-success text-white">
                                        <h4 class="mb-0">
                                            <i class="fas fa-plus-circle me-2"></i>Registrar Nueva Nota
                                        </h4>
                                    </div>
                                    <div class="card-body">
                                        <!-- Mostrar mensajes de error o éxito -->
                                        <%
                                            String error = (String) session.getAttribute("error");
                                            String mensaje = (String) session.getAttribute("mensaje");
                                            if (error != null) {
                                        %>
                                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                            <i class="fas fa-exclamation-triangle me-2"></i><%= error %>
                                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                        </div>
                                        <%
                                            session.removeAttribute("error");
                                            }
                                            if (mensaje != null) {
                                        %>
                                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                                            <i class="fas fa-check-circle me-2"></i><%= mensaje %>
                                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                        </div>
                                        <%
                                            session.removeAttribute("mensaje");
                                            }
                                        %>

                                        <!-- El action del formulario apunta a NotaController -->
                                        <form action="../NotaController" method="post" id="formNota">        
                                            <input type="hidden" name="accion" value="nuevo">
                                            
                                            <!-- Campo ID Inscripción (REQUERIDO) -->
                                            <div class="mb-3">
                                                <label for="idInscripcion" class="form-label">
                                                    <i class="fas fa-id-badge me-1"></i>ID Inscripción <span class="text-danger">*</span>
                                                </label>
                                                <input type="number" id="idInscripcion" name="idInscripcion" 
                                                       class="form-control" required 
                                                       placeholder="Ingrese el ID de inscripción" min="1">
                                                <div class="form-text">Debe ser un número entero positivo.</div>
                                            </div>

                                            <!-- Campo Nota 1 (REQUERIDO) -->
                                            <div class="mb-3">
                                                <label for="nota1" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 1 <span class="text-danger">*</span>
                                                </label>
                                                <input type="number" step="0.01" id="nota1" name="nota1" 
                                                       class="form-control" required 
                                                       placeholder="Ej: 15.50" min="0" max="20">
                                                <div class="form-text">Nota del 0 al 20 (puede incluir decimales).</div>
                                            </div>

                                            <!-- Campo Nota 2 (REQUERIDO) -->
                                            <div class="mb-3">
                                                <label for="nota2" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 2 <span class="text-danger">*</span>
                                                </label>
                                                <input type="number" step="0.01" id="nota2" name="nota2" 
                                                       class="form-control" required 
                                                       placeholder="Ej: 17.00" min="0" max="20">
                                                <div class="form-text">Nota del 0 al 20 (puede incluir decimales).</div>
                                            </div>

                                            <!-- Campo Nota 3 (OPCIONAL) -->
                                            <div class="mb-3">
                                                <label for="nota3" class="form-label">
                                                    <i class="fas fa-calculator me-1"></i>Nota 3
                                                </label>
                                                <input type="number" step="0.01" id="nota3" name="nota3" 
                                                       class="form-control" 
                                                       placeholder="Ej: 14.25" min="0" max="20">
                                                <div class="form-text">Nota opcional del 0 al 20 (puede incluir decimales).</div>
                                            </div>

                                            <!-- Campo Examen Parcial (OPCIONAL) -->
                                            <div class="mb-3">
                                                <label for="examenParcial" class="form-label">
                                                    <i class="fas fa-clipboard-check me-1"></i>Examen Parcial
                                                </label>
                                                <input type="number" step="0.01" id="examenParcial" name="examenParcial" 
                                                       class="form-control" 
                                                       placeholder="Ej: 16.00" min="0" max="20">
                                                <div class="form-text">Nota del examen parcial del 0 al 20.</div>
                                            </div>

                                            <!-- Campo Examen Final (OPCIONAL) -->
                                            <div class="mb-3">
                                                <label for="examenFinal" class="form-label">
                                                    <i class="fas fa-graduation-cap me-1"></i>Examen Final
                                                </label>
                                                <input type="number" step="0.01" id="examenFinal" name="examenFinal" 
                                                       class="form-control" 
                                                       placeholder="Ej: 18.50" min="0" max="20">
                                                <div class="form-text">Nota del examen final del 0 al 20.</div>
                                            </div>

                                            <!-- Campo Nota Final (REQUERIDO) -->
                                            <div class="mb-3">
                                                <label for="notaFinal" class="form-label">
                                                    <i class="fas fa-trophy me-1"></i>Nota Final <span class="text-danger">*</span>
                                                </label>
                                                <input type="number" step="0.01" id="notaFinal" name="notaFinal" 
                                                       class="form-control" required 
                                                       placeholder="Ej: 16.25" min="0" max="20">
                                                <div class="form-text">Nota final calculada del 0 al 20.</div>
                                            </div>
                                            
                                            <!-- Campo Estado (REQUERIDO) -->
                                            <div class="mb-3">
                                                <label for="estado" class="form-label">
                                                    <i class="fas fa-check-circle me-1"></i>Estado <span class="text-danger">*</span>
                                                </label>
                                                <select id="estado" name="estado" class="form-select" required>
                                                    <option value="">Seleccione el estado</option>
                                                    <option value="aprobado">Aprobado</option>
                                                    <option value="desaprobado">Desaprobado</option>
                                                    <option value="pendiente">Pendiente</option>
                                                </select>
                                                <div class="form-text">Estado actual de la evaluación.</div>
                                            </div>

                                            <!-- Botones de acción -->                                            
                                            <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                                <a href="listado.jsp" class="btn btn-secondary me-md-2">
                                                    <i class="fas fa-times-circle me-2"></i>Cancelar
                                                </a>
                                                <button type="submit" class="btn btn-success">
                                                    <i class="fas fa-save me-2"></i>Guardar Nota
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
        
        <!-- Script para validación y funcionalidad adicional -->
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById('formNota');
                const notaInputs = document.querySelectorAll('input[type="number"]');
                const notaFinalInput = document.getElementById('notaFinal');
                const estadoSelect = document.getElementById('estado');
                
                // Validación en tiempo real para notas
                notaInputs.forEach(input => {
                    if (input.name.includes('nota') || input.name.includes('examen')) {
                        input.addEventListener('input', function() {
                            const value = parseFloat(this.value);
                            if (this.value !== '' && (value < 0 || value > 20)) {
                                this.setCustomValidity('La nota debe estar entre 0 y 20');
                                this.classList.add('is-invalid');
                            } else {
                                this.setCustomValidity('');
                                this.classList.remove('is-invalid');
                                this.classList.add('is-valid');
                            }
                        });
                        
                        // Limpiar validación cuando el campo esté vacío (para campos opcionales)
                        input.addEventListener('blur', function() {
                            if (this.value === '' && !this.required) {
                                this.classList.remove('is-valid', 'is-invalid');
                            }
                        });
                    }
                });
                
                // Función para calcular nota final automáticamente (opcional)
                function calcularNotaFinal() {
                    const nota1 = parseFloat(document.getElementById('nota1').value) || 0;
                    const nota2 = parseFloat(document.getElementById('nota2').value) || 0;
                    const nota3 = parseFloat(document.getElementById('nota3').value) || 0;
                    const examenParcial = parseFloat(document.getElementById('examenParcial').value) || 0;
                    const examenFinal = parseFloat(document.getElementById('examenFinal').value) || 0;
                    
                    // Fórmula de ejemplo: promedio ponderado
                    // Puedes ajustar esta fórmula según tus necesidades
                    let notaFinal = 0;
                    let totalPesos = 0;
                    
                    if (nota1 > 0) { notaFinal += nota1 * 0.15; totalPesos += 0.15; }
                    if (nota2 > 0) { notaFinal += nota2 * 0.15; totalPesos += 0.15; }
                    if (nota3 > 0) { notaFinal += nota3 * 0.15; totalPesos += 0.15; }
                    if (examenParcial > 0) { notaFinal += examenParcial * 0.25; totalPesos += 0.25; }
                    if (examenFinal > 0) { notaFinal += examenFinal * 0.30; totalPesos += 0.30; }
                    
                    if (totalPesos > 0) {
                        notaFinal = notaFinal / totalPesos * (totalPesos <= 1 ? 1/totalPesos : 1);
                        notaFinalInput.value = Math.round(notaFinal * 100) / 100;
                    }
                }
                
                // Botón para calcular nota final automáticamente
                const btnCalcular = document.createElement('button');
                btnCalcular.type = 'button';
                btnCalcular.className = 'btn btn-outline-info btn-sm ms-2';
                btnCalcular.innerHTML = '<i class="fas fa-calculator"></i> Calcular';
                btnCalcular.onclick = calcularNotaFinal;
                
                notaFinalInput.parentNode.querySelector('label').appendChild(btnCalcular);
                
                // Auto-sugerir estado basado en nota final
                notaFinalInput.addEventListener('input', function() {
                    const notaFinal = parseFloat(this.value);
                    if (!isNaN(notaFinal)) {
                        if (notaFinal >= 11 && estadoSelect.value === '') {
                            estadoSelect.value = 'aprobado';
                            estadoSelect.classList.add('is-valid');
                        } else if (notaFinal < 11 && estadoSelect.value === '') {
                            estadoSelect.value = 'desaprobado';
                            estadoSelect.classList.add('is-valid');
                        }
                    }
                });
                
                // Validación de coherencia entre nota final y estado
                function validarCoherencia() {
                    const notaFinal = parseFloat(notaFinalInput.value);
                    const estado = estadoSelect.value;
                    
                    if (!isNaN(notaFinal) && estado) {
                        if (estado === 'aprobado' && notaFinal < 11) {
                            return 'Una nota final menor a 11 no puede tener estado "Aprobado"';
                        } else if (estado === 'desaprobado' && notaFinal >= 11) {
                            return 'Una nota final mayor o igual a 11 no puede tener estado "Desaprobado"';
                        }
                    }
                    return null;
                }
                
                // Validación en tiempo real de coherencia
                [notaFinalInput, estadoSelect].forEach(input => {
                    input.addEventListener('change', function() {
                        const error = validarCoherencia();
                        const alertContainer = document.getElementById('coherencia-alert');
                        
                        if (error) {
                            if (!alertContainer) {
                                const alert = document.createElement('div');
                                alert.id = 'coherencia-alert';
                                alert.className = 'alert alert-warning mt-2';
                                alert.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>' + error;
                                estadoSelect.parentNode.appendChild(alert);
                            } else {
                                alertContainer.innerHTML = '<i class="fas fa-exclamation-triangle me-2"></i>' + error;
                            }
                        } else if (alertContainer) {
                            alertContainer.remove();
                        }
                    });
                });
                
                // Validación al enviar el formulario
                form.addEventListener('submit', function(e) {
                    const error = validarCoherencia();
                    if (error) {
                        e.preventDefault();
                        alert(error);
                        return false;
                    }
                    
                    // Validación adicional de campos requeridos
                    const camposRequeridos = [
                        { campo: 'idInscripcion', nombre: 'ID Inscripción' },
                        { campo: 'nota1', nombre: 'Nota 1' },
                        { campo: 'nota2', nombre: 'Nota 2' },
                        { campo: 'notaFinal', nombre: 'Nota Final' },
                        { campo: 'estado', nombre: 'Estado' }
                    ];
                    
                    for (let i = 0; i < camposRequeridos.length; i++) {
                        const campo = document.getElementById(camposRequeridos[i].campo);
                        if (!campo.value || campo.value.trim() === '') {
                            e.preventDefault();
                            alert('El campo ' + camposRequeridos[i].nombre + ' es requerido');
                            campo.focus();
                            return false;
                        }
                    }
                });
            });
        </script>
    </body>
</html>