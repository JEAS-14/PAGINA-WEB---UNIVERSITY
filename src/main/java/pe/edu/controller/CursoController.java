package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;
// Importa las clases de Curso y CursoDao
import pe.edu.entity.Curso; // Asegúrate de que esta ruta sea correcta
import pe.edu.dao.CursoDao; // Asegúrate de que esta ruta sea correcta

@WebServlet(name = "CursoController", urlPatterns = {"/CursoController"})
public class CursoController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pagina = request.getParameter("pagina");
        String idCurso = request.getParameter("id"); // ID del curso

        if (pagina != null) {
            if (pagina.equals("nuevo")) {
                pagina = "curso/" + pagina + ".jsp"; // Redirige a la página para crear un nuevo curso
                response.sendRedirect(pagina);
            } else {
                // Para editar o ver un curso existente, se pasa el ID
                pagina = "curso/" + pagina + ".jsp?id=" + idCurso;
                response.sendRedirect(pagina);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Curso curso = new Curso();
        CursoDao cursoDao = new CursoDao();
        String accion = request.getParameter("accion");

        // Obtener todos los parámetros necesarios del formulario para un objeto Curso
        String idCurso = request.getParameter("idCurso"); // ID del curso
        String nombreCurso = request.getParameter("nombreCurso");
        String codigoCurso = request.getParameter("codigoCurso");
        int creditos = Integer.parseInt(request.getParameter("creditos")); // Convertir a int
        int idCarrera = Integer.parseInt(request.getParameter("idCarrera")); // Convertir a int

        // Establecer los atributos del objeto Curso
        curso.setIdCurso(idCurso); // Si idCurso es auto-generado por la BD, no lo establecerías al insertar
        curso.setNombreCurso(nombreCurso);
        curso.setCodigoCurso(codigoCurso);
        curso.setCreditos(creditos);
        curso.setIdCarrera(idCarrera);

        try {
            switch (accion) {
                case "nuevo":
                    // Si el ID del curso es generado por la BD (auto-increment),
                    // no lo pasas al método `agregar`. El método `agregar` en CursoDao
                    // debería manejar la inserción sin el ID si es auto-generado.
                    // Si no es auto-generado, asegúrate de que el formulario provea idCurso y de que tu método 'agregar' lo acepte.
                    cursoDao.agregar(curso);
                    break;
                case "leer":
                    // El método leer en CursoDao devuelve un Curso por ID,
                    // aquí no se necesita una acción directa ya que se maneja en doGet
                    break;
                case "editar":
                    cursoDao.actualizar(curso); // Usar el método 'actualizar' del DAO
                    break;
                case "eliminar":
                    cursoDao.eliminar(idCurso); // Eliminar por ID
                    break;
                default:
                    break;
            }
        } catch (Exception ex) { // Captura cualquier excepción para loguear
            Logger.getLogger(CursoController.class.getName()).log(Level.SEVERE, null, ex);
        }

        // Redirige siempre al listado de cursos después de una operación POST
        response.sendRedirect("curso/listado.jsp");
    }
}