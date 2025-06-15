<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%
    Object idProfesorObj = session.getAttribute("id_profesor");
    String rolUsuario = (String) session.getAttribute("rol");

    if (idProfesorObj == null || !"profesor".equalsIgnoreCase(rolUsuario)) {
        out.print("[]");
        return;
    }
    int idProfesor = (Integer) idProfesorObj;

    StringBuilder jsonResponse = new StringBuilder();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Conexion conUtil = new Conexion();
        conn = conUtil.conecta();

        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }

        String sql = "SELECT DISTINCT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, a.email "
                     + "FROM alumnos a "
                     + "INNER JOIN inscripciones i ON a.id_alumno = i.id_alumno "
                     + "INNER JOIN clases cl ON i.id_clase = cl.id_clase "
                     + "WHERE cl.id_profesor = ? AND cl.estado = 'activo' AND i.estado = 'inscrito' "
                     + "ORDER BY a.apellido_paterno, a.nombre";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idProfesor);
        rs = pstmt.executeQuery();

        jsonResponse.append("[");

        boolean first = true;
        while (rs.next()) {
            if (!first) {
                jsonResponse.append(",");
            }
            jsonResponse.append("{");

            int idAlumno = rs.getInt("id_alumno");
            String dni = rs.getString("dni");
            String nombre = rs.getString("nombre");
            String apellidoPaterno = rs.getString("apellido_paterno");
            String apellidoMaterno = rs.getString("apellido_materno");
            String email = rs.getString("email");

            String nombreCompleto = nombre + " " + apellidoPaterno;
            if (apellidoMaterno != null && !apellidoMaterno.trim().isEmpty()) {
                nombreCompleto += " " + apellidoMaterno;
            }

            // Escapar cadenas para JSON
            String escapedNombreCompleto = nombreCompleto.replace("\\", "\\\\").replace("\"", "\\\"");
            String escapedDni = dni.replace("\\", "\\\\").replace("\"", "\\\"");
            String escapedEmail = email.replace("\\", "\\\\").replace("\"", "\\\"");

            jsonResponse.append("\"id_alumno\":").append(idAlumno).append(",");
            jsonResponse.append("\"dni\":\"").append(escapedDni).append("\",");
            jsonResponse.append("\"nombre_completo\":\"").append(escapedNombreCompleto).append("\",");
            jsonResponse.append("\"email\":\"").append(escapedEmail).append("\"");

            jsonResponse.append("}");
            first = false;
        }

        jsonResponse.append("]");

    } catch (SQLException e) {
        System.err.println("Error SQL en obtener_alumnos_por_profesor.jsp: " + e.getMessage());
        e.printStackTrace();
        jsonResponse.setLength(0);
        jsonResponse.append("[]");
    } catch (ClassNotFoundException e) {
        System.err.println("Error ClassNotFound en obtener_alumnos_por_profesor.jsp: " + e.getMessage());
        e.printStackTrace();
        jsonResponse.setLength(0);
        jsonResponse.append("[]");
    } finally {
        if (rs != null) { try { rs.close(); } catch (SQLException ignore) {} }
        if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
        if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
    }

    out.print(jsonResponse.toString());
    out.flush();
%>