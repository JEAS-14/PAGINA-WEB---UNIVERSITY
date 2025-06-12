package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;
// Importa las clases de Profesor y ProfesorDao
import pe.edu.entity.Profesor;
import pe.edu.dao.ProfesorDao;

@WebServlet(name = "ProfesorController", urlPatterns = {"/ProfesorController"})
public class ProfesorController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");        
        String idProfesor = request.getParameter("id");
        
        if (pagina != null) {            
            if (pagina.equals("nuevo")) {
                pagina = "profesor/" + pagina + ".jsp"; // Redirige a la página para crear un nuevo profesor
                response.sendRedirect(pagina);
            } else {
                // Para editar, ver o eliminar un profesor existente, se pasa el ID
                if (idProfesor != null) {
                    pagina = "profesor/" + pagina + ".jsp?id=" + idProfesor;
                } else {
                    pagina = "profesor/" + pagina + ".jsp";
                }
                response.sendRedirect(pagina);
            }            
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Profesor profesor = new Profesor();
        ProfesorDao profesorDao = new ProfesorDao();
        String accion = request.getParameter("accion");
        
        // Obtener todos los parámetros necesarios del formulario para un objeto Profesor
        String id = request.getParameter("id");
        String nombre = request.getParameter("nombre");
        String apellidoPaterno = request.getParameter("apellidoPaterno");
        String apellidoMaterno = request.getParameter("apellidoMaterno");
        String email = request.getParameter("email");
        String idFacultad = request.getParameter("idFacultad");
        String rol = request.getParameter("rol");
        String password = request.getParameter("password");

        // Establecer los atributos del objeto Profesor
        if (id != null && !id.isEmpty()) {
            profesor.setIdProfesor(Integer.parseInt(id));
        }
        profesor.setNombre(nombre);
        profesor.setApellidoPaterno(apellidoPaterno);
        profesor.setApellidoMaterno(apellidoMaterno);
        profesor.setEmail(email);
        if (idFacultad != null && !idFacultad.isEmpty()) {
            profesor.setIdFacultad(Integer.parseInt(idFacultad));
        }
        profesor.setRol(rol);
        profesor.setPassword(password);

        try {
            switch (accion) {
                case "nuevo":
                    profesorDao.insertar(profesor);
                    break;
                case "leer":
                    // El método leer en ProfesorDao devuelve un Profesor por ID, 
                    // aquí no se necesita una acción directa ya que se maneja en doGet
                    break; 
                case "editar":
                    profesorDao.editar(profesor);
                    break;
                case "eliminar":
                    profesorDao.eliminar(id); // Eliminar por ID
                    break;
                default:
                    break;
            }
        } catch (Exception ex) { // Captura cualquier excepción para loguear
            Logger.getLogger(ProfesorController.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Redirige siempre al listado de profesores después de una operación POST
        response.sendRedirect("profesor/listado.jsp");
    }
}