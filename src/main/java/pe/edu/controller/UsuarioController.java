package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Usuario;
import pe.edu.dao.UsuarioDao;

@WebServlet(name = "UsuarioController", urlPatterns = {"/UsuarioController"})
public class UsuarioController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");        
        String usuario = request.getParameter("usr");        
        
        if (pagina != null) {            
            if (pagina.equals("nuevo")) {
                pagina = "usuario/" + pagina + ".jsp";
                response.sendRedirect(pagina);
            } else {
                pagina = "usuario/" +pagina + ".jsp?usr=" + usuario;
                response.sendRedirect(pagina);
            }            
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = new Usuario();
        UsuarioDao udao = new UsuarioDao();
        String accion = request.getParameter("accion");
        String id = request.getParameter("usr");
        String psw = request.getParameter("psw");
        String nom = request.getParameter("nom");
        usuario.setId(id);
        usuario.setPassword(psw);
        usuario.setNombre(nom);
        switch (accion) {
            case "nuevo":
                udao.insertar(usuario);
                break;
            case "leer":
                break;
            case "editar":
                udao.editar(usuario);
                break;
            case "eliminar":
                udao.eliminar(id);
                break;
            default:
                break;
        }
        response.sendRedirect("usuario/listado.jsp");
    }
}
