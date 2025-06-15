package com.edu.pe.login;

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
        // Obtener los parámetros del formulario de inicio de sesión
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String userType = request.getParameter("userType"); // Tipo de usuario (alumno, profesor, apoderado, admin)

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        HttpSession session = request.getSession(); // Obtener la sesión para guardar mensajes de error o datos de usuario

        try {
            // Inicializa tu clase de conexión y obtén la conexión a la base de datos
            Conexion conexionUtil = new Conexion();
            conn = conexionUtil.conecta();

            String sql = ""; // Variable para almacenar la consulta SQL

            // Seleccionar la tabla y la consulta SQL basada en el tipo de usuario
            switch (userType) {
                case "alumno":
                    // Consulta para alumnos: busca por email y contraseña
                    sql = "SELECT * FROM alumnos WHERE email = ? AND password = ?";
                    break;
                case "profesor":
                    // Consulta para profesores: busca por email y contraseña
                    sql = "SELECT * FROM profesores WHERE email = ? AND password = ?";
                    break;
                case "apoderado":
                    // ¡NUEVO! Consulta para apoderados: busca por email y contraseña
                    // Asegúrate de que tu tabla se llame 'apoderados' y tenga columnas 'email' y 'password'
                    sql = "SELECT * FROM apoderados WHERE email = ? AND password = ?";
                    break;
                case "admin":
                    // Consulta para administradores: busca por email y contraseña
                    sql = "SELECT * FROM admin WHERE email = ? AND password = ?";
                    break;
                default:
                    // Si el tipo de usuario es desconocido, establece un error y redirige
                    session.setAttribute("loginError", "Rol de usuario desconocido.");
                    response.sendRedirect("Plataforma.jsp");
                    return; // Termina la ejecución del Servlet
            }

            // Preparar la declaración SQL para evitar inyecciones SQL
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            // ¡IMPORTANTE! Las contraseñas NO DEBEN guardarse en texto plano en la base de datos.
            // Debes HASHEAR las contraseñas antes de guardarlas y comparar el hash aquí.
            pstmt.setString(2, password);

            // Ejecutar la consulta
            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("email", username);
                session.setAttribute("rol", userType);
                session.removeAttribute("loginError");

                // ⚠️ GUARDAR ID SEGÚN TIPO
                switch (userType) {
                    case "alumno":
                        session.setAttribute("id_alumno", rs.getInt("id_alumno"));
                        response.sendRedirect("INTERFAZ_ALUMNO/home_alumno.jsp");
                        break;
                    case "profesor":
                        session.setAttribute("id_profesor", rs.getInt("id_profesor")); // 💥 AQUÍ LO GUARDAS
                        response.sendRedirect("INTERFAZ_PROFESOR/home_profesor.jsp");
                        break;
                    case "apoderado":
                        session.setAttribute("id_apoderado", rs.getInt("id_apoderado"));
                        response.sendRedirect("INTERFAZ_APODERADO/home_apoderado.jsp");
                        break;
                    case "admin":
                        session.setAttribute("id_admin", rs.getInt("id_admin"));
                        response.sendRedirect("admin/listado.jsp");
                        break;
                }
            } else {
                // Autenticación fallida:
                // Establece un mensaje de error en la sesión
                session.setAttribute("loginError", "Credenciales inválidas. Por favor, verifique su usuario y contraseña.");
                // Redirige de vuelta a la página principal (donde se muestra el modal de error)
                response.sendRedirect("Plataforma.jsp");
            }

        } catch (SQLException e) {
            // Manejo de errores de SQL (ej. problema de conexión, consulta errónea)
            e.printStackTrace(); // Imprime el stack trace para depuración
            session.setAttribute("loginError", "Error al conectar o consultar la base de datos. Por favor, intente más tarde.");
            response.sendRedirect("Plataforma.jsp");
        } catch (ClassNotFoundException e) {
            // Manejo de error si el driver de la base de datos no se encuentra
            e.printStackTrace();
            session.setAttribute("loginError", "Error interno del servidor: Driver de base de datos no encontrado.");
            response.sendRedirect("Plataforma.jsp");
        } finally {
            // Asegúrate de cerrar todos los recursos de la base de datos para evitar fugas de memoria
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            try {
                if (pstmt != null) {
                    pstmt.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
