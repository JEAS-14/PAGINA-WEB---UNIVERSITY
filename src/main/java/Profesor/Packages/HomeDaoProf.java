package Profesor.Packages;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
//import Profesor.Packages.Home;
import pe.universidad.util.Conexion;

public class HomeDaoProf {

    public Home obtenerDatosProfesor(String email) {
        Home home = new Home();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Conexion c = new Conexion();
            conn = c.conecta();

            String sqlProfesor = "SELECT p.id_profesor, p.dni, p.nombre, p.apellido_paterno, "
                    + "p.apellido_materno, p.telefono, f.nombre_facultad "
                    + "FROM profesores p "
                    + "JOIN facultades f ON p.id_facultad = f.id_facultad "
                    + "WHERE p.email = ?";

            pstmt = conn.prepareStatement(sqlProfesor);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                home.setIdProfesor(rs.getInt("id_profesor"));
                home.setDni(rs.getString("dni"));

                String nombreCompleto = rs.getString("nombre") + " " + rs.getString("apellido_paterno");
                if (rs.getString("apellido_materno") != null) {
                    nombreCompleto += " " + rs.getString("apellido_materno");
                }
                home.setNombreCompleto(nombreCompleto);
                home.setTelefono(rs.getString("telefono") != null ? rs.getString("telefono") : "No registrado");
                home.setFacultad(rs.getString("nombre_facultad"));
            }

            int idProfesor = home.getIdProfesor();
            if (idProfesor > 0) {
                home.setTotalCursos(obtenerTotalCursos(idProfesor, conn));
                home.setCursosActivos(obtenerCursosActivos(idProfesor, conn));
                home.setTotalAlumnos(obtenerTotalAlumnos(idProfesor, conn));
                home.setEvaluacionesPendientes(obtenerEvaluacionesPendientes(idProfesor, conn));
                home.setCursosList(obtenerCursos(idProfesor, conn));
                home.setAlumnosList(obtenerAlumnosRecientes(idProfesor, conn));
                home.setEvaluacionesList(obtenerEvaluacionesProximas(idProfesor, conn));
            }

        } catch (SQLException | ClassNotFoundException e) {
            Logger.getLogger(HomeDaoProf.class.getName()).log(Level.SEVERE, "Error al obtener datos del profesor", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                Logger.getLogger(HomeDaoProf.class.getName()).log(Level.SEVERE, "Error al cerrar recursos", e);
            }
        }

        return home;
    }

    private int obtenerTotalCursos(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) AS total FROM profesores_cursos WHERE id_profesor = ?";
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int obtenerCursosActivos(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) AS total FROM profesores_cursos WHERE id_profesor = ? AND estado = 'activo'";
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int obtenerTotalAlumnos(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT i.id_alumno) AS total "
                + "FROM inscripciones i "
                + "JOIN profesores_cursos pc ON i.id_curso = pc.id_curso "
                + "WHERE pc.id_profesor = ? AND i.estado = 'activo'";
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int obtenerEvaluacionesPendientes(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) AS total FROM evaluaciones "
                + "WHERE fecha_limite > NOW() AND id_curso IN "
                + "(SELECT id_curso FROM profesores_cursos WHERE id_profesor = ?)";
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int ejecutarConsultaCount(String sql, int idProfesor, Connection conn) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProfesor);
            rs = pstmt.executeQuery();
            return rs.next() ? rs.getInt("total") : 0;
        } finally {
            cerrarRecursos(rs, pstmt);
        }
    }

    private List<Map<String, String>> obtenerCursos(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso, c.creditos, "
                + "(SELECT COUNT(*) FROM inscripciones i WHERE i.id_curso = c.id_curso AND i.estado = 'activo') AS alumnos "
                + "FROM profesores_cursos pc "
                + "JOIN curso c ON pc.id_curso = c.id_curso "
                + "WHERE pc.id_profesor = ? AND pc.estado = 'activo'";
        return ejecutarConsultaLista(sql, idProfesor, conn);
    }

    private List<Map<String, String>> obtenerAlumnosRecientes(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT a.id_alumno, a.nombre, a.apellido_paterno, a.apellido_materno, c.nombre_curso "
                + "FROM alumnos a "
                + "JOIN inscripciones i ON a.id_alumno = i.id_alumno "
                + "JOIN profesores_cursos pc ON i.id_curso = pc.id_curso "
                + "JOIN curso c ON pc.id_curso = c.id_curso "
                + "WHERE pc.id_profesor = ? AND i.estado = 'activo' "
                + "ORDER BY i.fecha_inscripcion DESC LIMIT 5";
        return ejecutarConsultaLista(sql, idProfesor, conn);
    }

    private List<Map<String, String>> obtenerEvaluacionesProximas(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT e.id_evaluacion, e.nombre_evaluacion, e.fecha_limite, c.nombre_curso "
                + "FROM evaluaciones e "
                + "JOIN curso c ON e.id_curso = c.id_curso "
                + "JOIN profesores_cursos pc ON c.id_curso = pc.id_curso "
                + "WHERE pc.id_profesor = ? AND e.fecha_limite > NOW() "
                + "ORDER BY e.fecha_limite ASC LIMIT 5";
        return ejecutarConsultaLista(sql, idProfesor, conn);
    }

    private List<Map<String, String>> ejecutarConsultaLista(String sql, int idProfesor, Connection conn) throws SQLException {
        List<Map<String, String>> lista = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProfesor);
            rs = pstmt.executeQuery();
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();

            while (rs.next()) {
                Map<String, String> fila = new HashMap<>();
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = metaData.getColumnName(i);
                    String columnValue = rs.getString(i);

                    if ("fecha_limite".equalsIgnoreCase(columnName)) {
                        Timestamp timestamp = rs.getTimestamp(i);
                        if (timestamp != null) {
                            LocalDateTime localDateTime = timestamp.toLocalDateTime();
                            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
                            columnValue = localDateTime.format(formatter);
                        }
                    }

                    fila.put(columnName, columnValue != null ? columnValue : "");
                }
                lista.add(fila);
            }
        } finally {
            cerrarRecursos(rs, pstmt);
        }

        return lista;
    }

    private void cerrarRecursos(ResultSet rs, PreparedStatement pstmt) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        } catch (SQLException ex) {
            Logger.getLogger(HomeDaoProf.class.getName()).log(Level.SEVERE, "Error al cerrar recursos", ex);
        }
    }
}
