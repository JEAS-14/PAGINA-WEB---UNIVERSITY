package com.edu.pe.login;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import pe.universidad.util.Conexion; // Importa tu clase de conexión

@WebServlet("/loginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Obtener la conexión a la base de datos
            // FIX: Create an instance of Conexion and call its conecta() method
            Conexion conexionUtil = new Conexion(); 
            conn = conexionUtil.conecta(); // Corrected line
            
            String sql = "";

            switch (userType) {
                case "alumno":
                    sql = "SELECT * FROM alumnos WHERE email = ? AND password = ?"; // ¡Cuidado! Inseguro
                    break;
                case "profesor":
                    sql = "SELECT * FROM profesores WHERE email = ? AND password = ?"; // ¡Cuidado! Inseguro
                    break;
                case "admin":
                    sql = "SELECT * FROM admin WHERE email = ? AND password = ?"; // ¡Cuidado! Inseguro
                    break;
                default:
                    HttpSession session = request.getSession();
                    session.setAttribute("loginError", "Rol de usuario desconocido.");
                    response.sendRedirect("Plataforma.jsp");
                    return;
            }

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password); // ¡Cuidado! Esto es inseguro en producción

            rs = pstmt.executeQuery();

            if (rs.next()) {
                // Autenticación exitosa, guardar información en la sesión
                HttpSession session = request.getSession();
                session.setAttribute("email", username);
                session.setAttribute("rol", userType);

                // Redirigir según el rol
                switch (userType) {
                    case "alumno":
                        response.sendRedirect("INTERFAZ_ALUMNO/home_alumno.jsp");
                        break;
                    case "profesor":
                        response.sendRedirect("INTERFAZ_PROFESOR/home_profesor.jsp");
                        break;
                    case "admin":
                        response.sendRedirect("alumno/listado.jsp");
                        break;
                }
            } else {
                // Autenticación fallida
                HttpSession session = request.getSession();
                session.setAttribute("loginError", "Credenciales inválidas.");
                response.sendRedirect("Plataforma.jsp"); // Redirige de vuelta a plataforma.jsp
            }

        } catch (SQLException e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("loginError", "Error al conectar o consultar la base de datos.");
            response.sendRedirect("Plataforma.jsp"); // Redirige de vuelta a plataforma.jsp
        } catch (ClassNotFoundException e) { // Catch ClassNotFoundException as well
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("loginError", "Error al cargar el driver de la base de datos.");
            response.sendRedirect("Plataforma.jsp");
        } finally {
            // Cerrar recursos
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            // Ensure connection is closed too
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}