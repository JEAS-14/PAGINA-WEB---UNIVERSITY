<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Curso, pe.edu.dao.CursoDao, pe.edu.entity.Carrera, pe.edu.dao.CarreraDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Listado de Cursos</title>        
    </head>
    
    <%-- Instancias de DAO para interactuar con la base de datos --%>
    <jsp:useBean id="cursoDao" class="pe.edu.dao.CursoDao" scope="session"></jsp:useBean>
    <jsp:useBean id="carreraDao" class="pe.edu.dao.CarreraDao" scope="session"></jsp:useBean>
    
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                    <center>
                        <div class="card card_tabla shadow-sm">
                            <div class="card-header card_titulo bg-primary text-white">
                                <h2 class="mb-0">
                                    <i class="fas fa-book me-2"></i>Gestión de Cursos
                                </h2>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-sm-auto">
                                        <%-- Enlace para crear un nuevo curso --%>
                                        <a href="../CursoController?pagina=nuevo" class="btn btn-success d-flex align-items-center">
                                            <i class="fas fa-plus-circle me-2"></i>Nuevo Curso
                                        </a>
                                    </div>
                                    <div class="col"></div> <%-- Columna para espacio --%>
                                </div>
                                <br>
                                <div class="table-responsive">
                                    <table id="myTable" class="display table table-light table-striped table-hover card_contenido align-middle">
                                        <thead>
                                            <tr>
                                                <th>ID Curso</th>
                                                <th>Nombre del Curso</th>
                                                <th>Código del Curso</th>
                                                <th>Créditos</th>
                                                <th>Carrera</th> <%-- Nueva columna para el nombre de la carrera --%>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                LinkedList<Curso> listaCursos = cursoDao.listar();
                                                if (listaCursos == null) {
                                                    listaCursos = new LinkedList<Curso>();
                                                }
                                                for (Curso cur : listaCursos) {
                                                    // Obtener la carrera asociada para mostrar su nombre
                                                    // SOLUCIÓN 1: Convertir el ID del curso (que es int) a String para que coincida con CarreraDao.leer(String)
                                                    Carrera carrera = carreraDao.leer(String.valueOf(cur.getIdCarrera()));
                                                    
                                                    // SOLUCIÓN 2: Usar el getter correcto para el nombre de la carrera: getNombreCarrera()
                                                    String nombreCarrera = (carrera != null) ? carrera.getNombreCarrera() : "N/A";
                                            %>            
                                            <tr>
                                                <td><%= cur.getIdCurso() %></td>
                                                <td><%= cur.getNombreCurso() %></td>
                                                <td><%= cur.getCodigoCurso() %></td>
                                                <td><%= cur.getCreditos() %></td>
                                                <td><%= nombreCarrera %></td>
                                                <td class="text-center">
                                                    <%-- Enlaces para Ver, Editar y Eliminar --%>
                                                    <a href="../CursoController?pagina=ver&id=<%= cur.getIdCurso() %>" 
                                                       class="btn btn-info btn-sm me-1" title="Ver detalles">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="../CursoController?pagina=editar&id=<%= cur.getIdCurso() %>" 
                                                       class="btn btn-warning btn-sm me-1" title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="../CursoController?pagina=eliminar&id=<%= cur.getIdCurso() %>" 
                                                       class="btn btn-danger btn-sm" title="Eliminar"
                                                       onclick="return confirm('¿Está seguro que desea eliminar este curso? Esta acción no se puede deshacer.')">
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