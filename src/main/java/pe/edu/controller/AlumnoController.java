package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;
// Importa las clases de Alumno y AlumnoDao
import pe.edu.entity.Alumno; // Asegúrate de que esta ruta sea correcta
import pe.edu.dao.AlumnoDao; // Asegúrate de que esta ruta sea correcta

@WebServlet(name = "AlumnoController", urlPatterns = {"/AlumnoController"})
public class AlumnoController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");        
        String idAlumno = request.getParameter("id"); // Cambiado de 'usr' a 'id' para ser más explícito con Alumno
        
        if (pagina != null) {            
            if (pagina.equals("nuevo")) {
                pagina = "alumno/" + pagina + ".jsp"; // Redirige a la página para crear un nuevo alumno
                response.sendRedirect(pagina);
            } else {
                // Para editar o ver un alumno existente, se pasa el ID
                pagina = "alumno/" + pagina + ".jsp?id=" + idAlumno;
                response.sendRedirect(pagina);
            }            
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Alumno alumno = new Alumno();
        AlumnoDao alumnoDao = new AlumnoDao();
        String accion = request.getParameter("accion");
        
        // Obtener todos los parámetros necesarios del formulario para un objeto Alumno
        String id = request.getParameter("id"); // ID del alumno
        String dni = request.getParameter("dni");
        String nombre = request.getParameter("nombre");
        String apellidoPaterno = request.getParameter("apellidoPaterno"); // Corregido: era "apellido"
        String apellidoMaterno = request.getParameter("apellidoMaterno"); // Agregado: nuevo campo
        String direccion = request.getParameter("direccion");
        String telefono = request.getParameter("telefono");
        String fechaNacimiento = request.getParameter("fechaNacimiento");
        String email = request.getParameter("email");
        String idCarrera = request.getParameter("idCarrera");
        String rol = request.getParameter("rol");
        String password = request.getParameter("password");
        String estado = request.getParameter("estado"); // Agregado: nuevo campo

        // Establecer los atributos del objeto Alumno
        if (id != null && !id.trim().isEmpty()) {
            alumno.setId(id);
        }
        
        alumno.setDni(dni);
        alumno.setNombre(nombre);
        alumno.setApellidoPaterno(apellidoPaterno); // Cambié de setApellido() a setApellidoPaterno()
        alumno.setApellidoMaterno(apellidoMaterno); // Agregado nuevo método
        alumno.setDireccion(direccion);
        alumno.setTelefono(telefono);
        alumno.setFechaNacimiento(fechaNacimiento);
        alumno.setEmail(email);
        alumno.setIdCarrera(idCarrera);
        alumno.setRol(rol);
        alumno.setPassword(password);
        alumno.setEstado(estado); // Agregado nuevo método

        try {
            switch (accion) {
                case "nuevo":
                    // Para nuevo alumno, no establecer ID (será auto-generado)
                    alumno.setId(null);
                    // El estado por defecto será 'activo' si no se especifica
                    if (estado == null || estado.trim().isEmpty()) {
                        alumno.setEstado("activo");
                    }
                    // El rol por defecto será 'alumno' si no se especifica
                    if (rol == null || rol.trim().isEmpty()) {
                        alumno.setRol("alumno");
                    }
                    alumnoDao.insertar(alumno);
                    request.getSession().setAttribute("mensaje", "Alumno creado exitosamente");
                    break;
                    
                case "leer":
                    // El método leer en AlumnoDao devuelve un Alumno por ID, 
                    // aquí no se necesita una acción directa ya que se maneja en doGet
                    break; 
                    
                case "editar":
                    // Validar que el ID no sea nulo para editar
                    if (id == null || id.trim().isEmpty()) {
                        throw new IllegalArgumentException("ID de alumno requerido para editar");
                    }
                    alumnoDao.editar(alumno);
                    request.getSession().setAttribute("mensaje", "Alumno editado exitosamente");
                    break;
                    
                case "eliminar":
                    // Validar que el ID no sea nulo para eliminar
                    if (id == null || id.trim().isEmpty()) {
                        throw new IllegalArgumentException("ID de alumno requerido para eliminar");
                    }
                    alumnoDao.eliminar(id); // Eliminar por ID
                    request.getSession().setAttribute("mensaje", "Alumno eliminado exitosamente");
                    break;
                    
                case "ver":
                    // Para ver un alumno, generalmente se maneja en doGet,
                    // pero si llega por POST, no hacer nada especial
                    break;
                    
                default:
                    request.getSession().setAttribute("error", "Acción no reconocida: " + accion);
                    break;
            }
            
        } catch (IllegalArgumentException ex) {
            // Errores de validación
            Logger.getLogger(AlumnoController.class.getName()).log(Level.WARNING, "Error de validación", ex);
            request.getSession().setAttribute("error", "Error de validación: " + ex.getMessage());
            
        } catch (Exception ex) {
            // Captura cualquier excepción para loguear
            Logger.getLogger(AlumnoController.class.getName()).log(Level.SEVERE, "Error en operación de alumno", ex);
            request.getSession().setAttribute("error", "Error al realizar la operación: " + ex.getMessage());
        }
        
        // Redirige siempre al listado de alumnos después de una operación POST
        response.sendRedirect("alumno/listado.jsp");
    }
}