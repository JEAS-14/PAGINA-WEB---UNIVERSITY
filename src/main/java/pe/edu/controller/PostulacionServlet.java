package pe.edu.controller;

import pe.edu.dao.PostulacionDAO;
import pe.edu.entity.Postulacion;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/postulacion")
public class PostulacionServlet extends HttpServlet {

    private PostulacionDAO postulacionDAO;

    @Override
    public void init() {
        postulacionDAO = new PostulacionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("postulacionForm.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String nombreCompleto = request.getParameter("nombreCompleto");
            String dni = request.getParameter("dni");
            String fechaNacimientoStr = request.getParameter("fechaNacimiento");
            String email = request.getParameter("email");
            String telefono = request.getParameter("telefono");
            String direccion = request.getParameter("direccion");
            int carreraInteresId = Integer.parseInt(request.getParameter("carreraInteresId"));
            String documentosAdjuntosUrl = request.getParameter("documentosAdjuntosUrl");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date fechaNacimiento = sdf.parse(fechaNacimientoStr);

            Postulacion postulacion = new Postulacion(nombreCompleto, dni, fechaNacimiento, email, telefono, direccion,
                    carreraInteresId, documentosAdjuntosUrl);

            boolean success = postulacionDAO.registrarPostulacion(postulacion);

            request.setAttribute("success", success);
            request.setAttribute("message", success ? "Postulación registrada exitosamente." : "Error al registrar la postulación.");
        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        request.getRequestDispatcher("postulacionResult.jsp").forward(request, response);
    }
}


