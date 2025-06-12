package Profesor.Packages;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/home_profesor")
public class HomeController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HomeController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = (String) request.getSession().getAttribute("email");
        String rol = (String) request.getSession().getAttribute("rol");

        if (email == null || !"profesor".equalsIgnoreCase(rol)) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            HomeDaoProf dao = new HomeDaoProf();
            Home home = dao.obtenerDatosProfesor(email);

            request.setAttribute("home", home);
            request.getRequestDispatcher("home_profesor.jsp").forward(request, response);

        } catch (ServletException | IOException e) {
            LOGGER.log(Level.SEVERE, "Error al cargar los datos del profesor", e);
            response.sendRedirect("error.jsp");
        }
    }
}
