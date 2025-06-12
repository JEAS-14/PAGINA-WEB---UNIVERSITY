package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.dao.InscripcionDao;
import pe.edu.entity.Inscripcion;

@WebServlet(name = "InscripcionController", urlPatterns = {"/InscripcionController"})
public class InscripcionController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");
        String id = request.getParameter("id");

        if (pagina != null) {
            if (pagina.equals("nuevo")) {
                request.getRequestDispatcher("inscripcion/nuevo.jsp").forward(request, response);
            } else {
                request.setAttribute("id", id);
                request.getRequestDispatcher("inscripcion/" + pagina + ".jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("inscripcion/listado.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Inscripcion inscripcion = new Inscripcion();
        InscripcionDao inscripcionDao = new InscripcionDao();
        String accion = request.getParameter("accion");

        String idInscripcionStr = request.getParameter("idInscripcion");
        String idAlumnoStr = request.getParameter("idAlumno");
        String idClaseStr = request.getParameter("idClase");
        String fechaInscripcion = request.getParameter("fechaInscripcion");
        String estado = request.getParameter("estado");

        try {
            switch (accion) {
                case "nuevo":
                    if (datosCompletos(idAlumnoStr, idClaseStr, fechaInscripcion, estado)) {
                        Inscripcion nueva = new Inscripcion();
                        nueva.setIdAlumno(Integer.parseInt(idAlumnoStr));
                        nueva.setIdClase(Integer.parseInt(idClaseStr));
                        nueva.setFechaInscripcion(fechaInscripcion);
                        nueva.setEstado(estado);
                        inscripcionDao.insertar(nueva);
                        request.getSession().setAttribute("mensaje", "Inscripción creada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "Faltan datos para la inscripción");
                    }
                    break;

                case "editar":
                    if (idInscripcionStr != null && datosCompletos(idAlumnoStr, idClaseStr, fechaInscripcion, estado)) {
                        Inscripcion editar = new Inscripcion();
                        editar.setIdInscripcion(Integer.parseInt(idInscripcionStr));
                        editar.setIdAlumno(Integer.parseInt(idAlumnoStr));
                        editar.setIdClase(Integer.parseInt(idClaseStr));
                        editar.setFechaInscripcion(fechaInscripcion);
                        editar.setEstado(estado);
                        inscripcionDao.editar(editar);
                        request.getSession().setAttribute("mensaje", "Inscripción editada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "Datos incompletos o ID faltante");
                    }
                    break;

                case "eliminar":
                    if (idInscripcionStr != null && !idInscripcionStr.isEmpty()) {
                        inscripcionDao.eliminar(idInscripcionStr);
                        request.getSession().setAttribute("mensaje", "Inscripción eliminada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "ID no proporcionado para eliminar");
                    }
                    break;

                default:
                    request.getSession().setAttribute("error", "Acción no reconocida");
                    break;
            }
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect("inscripcion/listado.jsp");
    }

    private boolean datosCompletos(String alumno, String clase, String fecha, String estado) {
        return alumno != null && !alumno.isEmpty() &&
               clase != null && !clase.isEmpty() &&
               fecha != null && !fecha.isEmpty() &&
               estado != null && !estado.isEmpty();
    }

    @Override
    public String getServletInfo() {
        return "Controlador para la gestión de Inscripciones";
    }
}
