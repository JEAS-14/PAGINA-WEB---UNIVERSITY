package pe.edu.controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.dao.UsuarioDao;
import pe.edu.entity.Usuario;

@WebServlet(name = "Autentica", urlPatterns = {"/Autentica"})
public class Autentica extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Usuario u = new Usuario();
        UsuarioDao udao = new UsuarioDao();        
        String usr = request.getParameter("usr");
        String psw = request.getParameter("psw");
        u.setId(usr);
        u.setPassword(psw);
        int log = 0;
        try {
            log = udao.getLogueado(u);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(Autentica.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        if (log != 0) {
            response.sendRedirect("usuario/listado.jsp");
        } else {
            response.sendRedirect("index.jsp");
        }
    }
}
