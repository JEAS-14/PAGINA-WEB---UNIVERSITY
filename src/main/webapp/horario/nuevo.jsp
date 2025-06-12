<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="pe.edu.entity.Horario, pe.edu.dao.HorarioDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Nuevo Horario</title>        
    </head>
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                    <center>
                        <div class="card card_login shadow">
                            <div class="card-header card_titulo bg-success text-white">
                                <h2 class="mb-0">
                                    <i class="fas fa-plus-circle me-2"></i>Registrar Nuevo Horario
                                </h2>
                            </div>
                            <div class="card-body">
                                <%-- El action del formulario apunta a HorarioController --%>
                                <form action="../HorarioController" method="post">        
                                    <input type="hidden" name="accion" value="nuevo">
                                                                            
                                    <%-- Campo Día de la Semana --%>
                                    <div class="mb-3 text-start">
                                        <label for="diaSemana" class="form-label"><i class="fas fa-calendar-day me-1"></i>Día de la Semana:</label>
                                        <select id="diaSemana" name="diaSemana" class="form-select" required="true">
                                            <option value="">Seleccione un día</option>
                                            <option value="Lunes">Lunes</option>
                                            <option value="Martes">Martes</option>
                                            <option value="Miércoles">Miércoles</option>
                                            <option value="Jueves">Jueves</option>
                                            <option value="Viernes">Viernes</option>
                                            <option value="Sábado">Sábado</option>
                                            <option value="Domingo">Domingo</option>
                                        </select>
                                    </div>

                                    <%-- Campo Hora Inicio --%>
                                    <div class="mb-3 text-start">
                                        <label for="horaInicio" class="form-label"><i class="fas fa-clock me-1"></i>Hora de Inicio:</label>
                                        <input type="time" id="horaInicio" name="horaInicio" class="form-control" required="true">
                                    </div>

                                    <%-- Campo Hora Fin --%>
                                    <div class="mb-3 text-start">
                                        <label for="horaFin" class="form-label"><i class="fas fa-clock me-1"></i>Hora de Fin:</label>
                                        <input type="time" id="horaFin" name="horaFin" class="form-control" required="true">
                                    </div>

                                    <%-- Campo Aula --%>
                                    <div class="mb-3 text-start">
                                        <label for="aula" class="form-label"><i class="fas fa-school me-1"></i>Aula:</label>
                                        <input type="text" id="aula" name="aula" class="form-control" required="true" placeholder="Ej: A-101">
                                    </div>
                                                                            
                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                        <a href="listado.jsp" class="btn btn-danger d-flex align-items-center me-md-2">
                                            <i class="fas fa-times-circle me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-success d-flex align-items-center">
                                            <i class="fas fa-save me-2"></i>Guardar Horario
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </center>
                </div>
            </div>
        </div>
    </body>
</html>

<%-- Scripts (no necesarios en esta página, ya incluidos en referencias.jsp) --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
<script type="text/javascript">
    let table = new DataTable('#myTable');
</script>   