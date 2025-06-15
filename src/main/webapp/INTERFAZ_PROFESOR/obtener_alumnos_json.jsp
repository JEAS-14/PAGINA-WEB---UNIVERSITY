<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%
    String searchTerm = request.getParameter("term");
    StringBuilder jsonResponse = new StringBuilder();

    if (searchTerm == null || searchTerm.trim().isEmpty()) {
        jsonResponse.append("[]");
        out.print(jsonResponse.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Conexion conUtil = new Conexion();
        conn = conUtil.conecta();

        if (conn == null || conn.isClosed()) {
            throw new SQLException("No se pudo establecer conexión a la base de datos.");
        }

        // Búsqueda por nombre completo, DNI o EMAIL
        String sql = "SELECT id_alumno, dni, nombre, apellido_paterno, apellido_materno, email "
                     + "FROM alumnos "
                     + "WHERE estado = 'activo' AND ( "
                     + "    LOWER(CONCAT(nombre, ' ', apellido_paterno, ' ', IFNULL(apellido_materno, ''))) LIKE LOWER(?) OR "
                     + "    dni LIKE ? OR "
                     + "    LOWER(email) LIKE LOWER(?) "
                     + ") LIMIT 10";

        pstmt = conn.prepareStatement(sql);
        String searchPattern = "%" + searchTerm.trim() + "%";
        pstmt.setString(1, searchPattern);
        pstmt.setString(2, searchPattern);
        pstmt.setString(3, searchPattern);
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
        System.err.println("Error SQL en obtener_alumnos_json.jsp: " + e.getMessage());
        e.printStackTrace();
        jsonResponse.setLength(0);
        jsonResponse.append("[]");
    } catch (ClassNotFoundException e) {
        System.err.println("Error ClassNotFound en obtener_alumnos_json.jsp: " + e.getMessage());
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