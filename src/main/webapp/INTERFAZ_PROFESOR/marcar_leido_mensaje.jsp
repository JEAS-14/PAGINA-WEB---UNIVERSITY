<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page session="true" %>

<%
    // --- VALIDACIÓN DE SESIÓN ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idProfesorObj = session.getAttribute("id_profesor");

    if (emailSesion == null || !"profesor".equalsIgnoreCase(rolUsuario) || idProfesorObj == null) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
        return;
    }

    int idProfesor = -1;
    if (idProfesorObj instanceof Integer) {
        idProfesor = (Integer) idProfesorObj;
    } else {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp");
        return;
    }

    int idMensaje = -1;
    try {
        idMensaje = Integer.parseInt(request.getParameter("id_mensaje"));
    } catch (NumberFormatException e) {
        response.sendRedirect("mensaje_profesor.jsp?error=mensaje_invalido");
        return;
    }

    Conexion conUtil = null;
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conUtil = new Conexion();
        conn = conUtil.conecta();

        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }

        // Marcar el mensaje como leído si el destinatario es el profesor logueado
        String sql = "UPDATE mensajes SET leido = 1 WHERE id_mensaje = ? AND id_destinatario = ? AND tipo_destinatario = 'profesor'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idMensaje);
        pstmt.setInt(2, idProfesor);

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            // Éxito, redirigir de vuelta a la página de mensajería con un mensaje de éxito
            response.sendRedirect("mensaje_profesor.jsp?exito=Mensaje marcado como leído.");
        } else {
            // El mensaje no fue encontrado o no pertenece a este profesor
            response.sendRedirect("mensaje_profesor.jsp?error=No se pudo marcar el mensaje como leído o no tienes permiso.");
        }

    } catch (SQLException e) {
        response.sendRedirect("mensaje_profesor.jsp?error=Error de base de datos al marcar mensaje: " + e.getMessage());
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        response.sendRedirect("mensaje_profesor.jsp?error=Error: Driver JDBC no encontrado.");
        e.printStackTrace();
    } finally {
        if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
        if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
    }
%>