<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.LinkedList, pe.edu.entity.Facultad, pe.edu.dao.FacultadDao" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <%@include file="../util/referencias.jsp" %>
        <title>Listado de Facultades</title>        
    </head>
    
    <%-- Instancia de FacultadDao para interactuar con la base de datos --%>
    <jsp:useBean id="facultadDao" class="pe.edu.dao.FacultadDao" scope="session"></jsp:useBean>
    
    <body>            
        <div class="container-fluid">
            <div class="row flex-nowrap">
                <%@include file="../menu.jsp" %>
                    
                <div class="col py-3">            
                    <center>
                        <div class="card card_tabla shadow-sm">
                            <div class="card-header card_titulo bg-primary text-white">
                                <h2 class="mb-0">
                                    <i class="fas fa-building me-2"></i>Gestión de Facultades
                                </h2>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-sm-auto">
                                        <%-- Enlace para crear una nueva facultad --%>
                                        <a href="../FacultadController?pagina=nuevo" class="btn btn-success d-flex align-items-center">
                                            <i class="fas fa-plus-circle me-2"></i>Nueva Facultad
                                        </a>
                                    </div>
                                    <div class="col"></div> <%-- Columna para espacio --%>
                                </div>
                                <br>
                                <div class="table-responsive">
                                    <table id="myTable" class="display table table-light table-striped table-hover card_contenido align-middle">
                                        <thead>
                                            <tr>
                                                <th>ID Facultad</th>
                                                <th>Nombre de la Facultad</th>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                LinkedList<Facultad> listaFacultades = facultadDao.listar();
                                                if (listaFacultades == null) {
                                                    listaFacultades = new LinkedList<Facultad>();
                                                }
                                                for (Facultad fac : listaFacultades) {
                                            %>            
                                            <tr>
                                                <td><%= fac.getIdFacultad() %></td>
                                                <td><%= fac.getNombreFacultad() %></td>
                                                <td class="text-center">
                                                    <%-- Enlaces para Ver, Editar y Eliminar --%>
                                                    <a href="../FacultadController?pagina=ver&id=<%= fac.getIdFacultad() %>" 
                                                       class="btn btn-info btn-sm me-1" title="Ver detalles">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="../FacultadController?pagina=editar&id=<%= fac.getIdFacultad() %>" 
                                                       class="btn btn-warning btn-sm me-1" title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="../FacultadController?pagina=eliminar&id=<%= fac.getIdFacultad() %>" 
                                                       class="btn btn-danger btn-sm" title="Eliminar"
                                                       onclick="return confirm('¿Está seguro que desea eliminar esta facultad? Esta acción no se puede deshacer.')">
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