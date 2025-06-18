<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, pe.universidad.util.Conexion" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page session="true" %>

<%
    // --- VALIDACIÓN DE SESIÓN ---
    String emailSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idApoderadoObj = session.getAttribute("id_apoderado");

    if (emailSesion == null || !"apoderado".equalsIgnoreCase(rolUsuario) || idApoderadoObj == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int idApoderado = -1;
    try {
        idApoderado = Integer.parseInt(String.valueOf(idApoderadoObj));
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=" + URLEncoder.encode("ID de apoderado inválido en sesión.", StandardCharsets.UTF_8.toString()));
        return;
    }

    int idMensaje = -1;
    try {
        idMensaje = Integer.parseInt(request.getParameter("id_mensaje"));
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp?error=" + URLEncoder.encode("ID de mensaje inválido.", StandardCharsets.UTF_8.toString()));
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

        // Marcar el mensaje como leído si el destinatario es el apoderado logueado
        // Y el tipo de destinatario es 'apoderado'
        String sql = "UPDATE mensajes SET leido = 1 WHERE id_mensaje = ? AND id_destinatario = ? AND tipo_destinatario = 'apoderado'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idMensaje);
        pstmt.setInt(2, idApoderado);

        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp?message=" + URLEncoder.encode("Mensaje marcado como leído.", StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode("success", StandardCharsets.UTF_8.toString()));
        } else {
            response.sendRedirect(request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp?message=" + URLEncoder.encode("No se pudo marcar el mensaje como leído o no tienes permiso.", StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode("danger", StandardCharsets.UTF_8.toString()));
        }

    } catch (SQLException e) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp?error=" + URLEncoder.encode("Error de base de datos al marcar mensaje: " + e.getMessage(), StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode("danger", StandardCharsets.UTF_8.toString()));
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_APODERADO/mensajes_apoderado.jsp?error=" + URLEncoder.encode("Error: Driver JDBC no encontrado.", StandardCharsets.UTF_8.toString()) + "&type=" + URLEncoder.encode("danger", StandardCharsets.UTF_8.toString()));
        e.printStackTrace();
    } finally {
        if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
        if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
    }
%>