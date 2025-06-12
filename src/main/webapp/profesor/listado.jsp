<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Profesor, pe.edu.dao.ProfesorDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Listado de Profesores</title>        
    </head>
    
    <%-- Instancia de ProfesorDao para interactuar con la base de datos --%>
    <jsp:useBean id="profesorDao" class="pe.edu.dao.ProfesorDao" scope="session"></jsp:useBean>
    
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                    <center>
                        <div class="card card_tabla shadow-sm">
                            <div class="card-header card_titulo bg-primary text-white">
                                <h2 class="mb-0">
                                    <i class="fas fa-chalkboard-teacher me-2"></i>Gestión de Profesores
                                </h2>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-sm-auto">
                                        <%-- Enlace para crear un nuevo profesor --%>
                                        <a href="../ProfesorController?pagina=nuevo" class="btn btn-success d-flex align-items-center">
                                            <i class="fas fa-plus-circle me-2"></i>Nuevo Profesor
                                        </a>
                                    </div>
                                    <div class="col"></div> <%-- Columna para espacio --%>
                                </div>
                                <br>
                                <div class="table-responsive">
                                    <table id="myTable" class="display table table-light table-striped table-hover card_contenido align-middle">
                                        <thead>
                                            <tr>
                                                <th>ID Profesor</th>
                                                <th>Nombre</th>
                                                <th>Apellido Paterno</th>
                                                <th>Apellido Materno</th>
                                                <th>Email</th>
                                                <th>Facultad</th>
                                                <th>Rol</th>
                                                <th>Password</th>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                LinkedList<Profesor> listaProfesores = profesorDao.listar();
                                                if (listaProfesores == null) {
                                                    listaProfesores = new LinkedList<Profesor>();
                                                }
                                                for (Profesor p : listaProfesores) {
                                            %>            
                                            <tr>
                                                <td><%= p.getIdProfesor() %></td>
                                                <td><%= p.getNombre() %></td>
                                                <td><%= p.getApellidoPaterno() %></td>
                                                <td><%= p.getApellidoMaterno() %></td>
                                                <td><%= p.getEmail() %></td>
                                                <td><%= p.getNombreFacultad() %></td>
                                                <td><%= p.getRol() %></td>
                                                <td><%= p.getPassword() %></td>
                                                <td class="text-center">
                                                    <%-- Enlaces para Ver, Editar y Eliminar --%>
                                                    <a href="../ProfesorController?pagina=ver&id=<%= p.getIdProfesor() %>" 
                                                       class="btn btn-info btn-sm me-1" title="Ver detalles">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="../ProfesorController?pagina=editar&id=<%= p.getIdProfesor() %>" 
                                                       class="btn btn-warning btn-sm me-1" title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="../ProfesorController?pagina=eliminar&id=<%= p.getIdProfesor() %>" 
                                                       class="btn btn-danger btn-sm" title="Eliminar"
                                                       onclick="return confirm('¿Está seguro que desea eliminar este profesor? Esta acción no se puede deshacer.')">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </a>
                                                </td>
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
<script src="https://cdn.datatables.net/2.3.1/js/dataTables.bootstrap5.js"></script> <%-- Para estilos Bootstrap en DataTables --%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script> <%-- Font Awesome --%>

<script type="text/javascript">
    let table = new DataTable('#myTable');
</script>