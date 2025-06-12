package Profesor.Packages;

import Profesor.Packages.Home;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.universidad.util.Conexion; // Asegúrate de que esta ruta sea correcta

public class HomeDaoProf {

    // No uses este LOGGER para depuración rápida, usa System.out.println
    // private static final Logger LOGGER = Logger.getLogger(HomeDaoProf.class.getName());

    public Home obtenerDatosProfesor(String email) {
        Home home = new Home(); // El constructor de Home ya inicializa las listas
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        System.out.println("--- INICIO DEBUG HomeDaoProf ---");
        System.out.println("DEBUG DAO: Intentando obtener datos para email: " + email);

        try {
            Conexion c = new Conexion();
            conn = c.conecta(); // Intenta conectar a la DB
            if(conn == null) {
                System.out.println("DEBUG DAO: ¡ERROR! La conexión a la base de datos es NULA. Revisa tu clase Conexion y las credenciales.");
                return home; // Retorna un objeto Home vacío para evitar más errores
            }
            System.out.println("DEBUG DAO: Conexión a la BD exitosa.");

            String sqlProfesor = "SELECT p.id_profesor, p.dni, p.nombre, p.apellido_paterno, "
                                + "p.apellido_materno, p.telefono, f.nombre_facultad "
                                + "FROM profesores p "
                                + "JOIN facultades f ON p.id_facultad = f.id_facultad "
                                + "WHERE p.email = ?";

            pstmt = conn.prepareStatement(sqlProfesor);
            pstmt.setString(1, email.trim()); // Añadimos .trim() para quitar espacios al inicio y al final
            System.out.println("DEBUG DAO: Ejecutando consulta SQL principal para email: " + email);
            rs = pstmt.executeQuery();

            if (rs.next()) { // Verifica si se encontró una fila
                home.setIdProfesor(rs.getInt("id_profesor"));
                home.setDni(rs.getString("dni"));

                String nombreCompleto = rs.getString("nombre") + " " + rs.getString("apellido_paterno");
                if (rs.getString("apellido_materno") != null) {
                    nombreCompleto += " " + rs.getString("apellido_materno");
                }
                home.setNombreCompleto(nombreCompleto);
                home.setTelefono(rs.getString("telefono") != null ? rs.getString("telefono") : "No registrado");
                home.setFacultad(rs.getString("nombre_facultad"));

                System.out.println("DEBUG DAO: Profesor encontrado. Nombre: " + home.getNombreCompleto() + " (ID: " + home.getIdProfesor() + ")");
            } else {
                System.out.println("DEBUG DAO: *** ALERTA *** No se encontró profesor con el email: " + email + ". La consulta SQL principal no devolvió resultados.");
            }

            int idProfesor = home.getIdProfesor(); // Obtiene el ID del profesor encontrado (o 0 si no se encontró)
            if (idProfesor > 0) { // Solo si se encontró el profesor principal y su ID es válido
                System.out.println("DEBUG DAO: Obteniendo datos secundarios para idProfesor: " + idProfesor);
                home.setTotalCursos(obtenerTotalCursos(idProfesor, conn));
                System.out.println("DEBUG DAO:   Total Cursos: " + home.getTotalCursos());
                home.setCursosActivos(obtenerCursosActivos(idProfesor, conn));
                System.out.println("DEBUG DAO:   Cursos Activos: " + home.getCursosActivos());
                home.setTotalAlumnos(obtenerTotalAlumnos(idProfesor, conn));
                System.out.println("DEBUG DAO:   Total Alumnos: " + home.getTotalAlumnos());
                home.setEvaluacionesPendientes(obtenerEvaluacionesPendientes(idProfesor, conn));
                System.out.println("DEBUG DAO:   Evaluaciones Pendientes: " + home.getEvaluacionesPendientes());

                // Ahora las listas
                List<Map<String, String>> cursos = obtenerCursos(idProfesor, conn);
                home.setCursosList(cursos);
                System.out.println("DEBUG DAO:   Cursos en lista (tamaño): " + (cursos != null ? cursos.size() : "null"));

                List<Map<String, String>> alumnos = obtenerAlumnosRecientes(idProfesor, conn);
                home.setAlumnosList(alumnos);
                System.out.println("DEBUG DAO:   Alumnos en lista (tamaño): " + (alumnos != null ? alumnos.size() : "null"));

                List<Map<String, String>> evaluaciones = obtenerEvaluacionesProximas(idProfesor, conn);
                home.setEvaluacionesList(evaluaciones);
                System.out.println("DEBUG DAO:   Evaluaciones en lista (tamaño): " + (evaluaciones != null ? evaluaciones.size() : "null"));
            } else {
                System.out.println("DEBUG DAO: No se pueden obtener datos secundarios (idProfesor es 0 o menos).");
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("DEBUG DAO: ERROR CRÍTICO GENERAL en obtenerDatosProfesor: " + e.getMessage());
            e.printStackTrace(); // Imprime la traza completa del error
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.err.println("DEBUG DAO: Error al cerrar recursos en finally: " + e.getMessage());
            }
        }
        System.out.println("--- FIN DEBUG HomeDaoProf ---");
        return home;
    }

    // --- Métodos Auxiliares del DAO (sin cambios, solo se llaman desde obtenerDatosProfesor) ---

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
                + "JOIN profesor_curso pc ON i.id_curso = pc.id_curso "
                + "WHERE pc.id_profesor = ? AND i.estado = 'activo'"; // Asegúrate que 'estado' sea 'activo' si así lo manejas
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int obtenerEvaluacionesPendientes(int idProfesor, Connection conn) throws SQLException {
        // Asegúrate que tu columna fecha_limite sea de tipo DATETIME/TIMESTAMP
        // Y que tu servidor de BD use NOW() para la fecha actual
        String sql = "SELECT COUNT(*) AS total FROM evaluaciones "
                + "WHERE fecha_limite > NOW() AND id_curso IN "
                + "(SELECT id_curso FROM profesor_curso WHERE id_profesor = ?)";
        return ejecutarConsultaCount(sql, idProfesor, conn);
    }

    private int ejecutarConsultaCount(String sql, int idProfesor, Connection conn) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0; // Inicializar a 0 por si no hay resultados
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProfesor);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt("total");
            }
            System.out.println("DEBUG DAO:   Consulta COUNT ejecutada: " + sql.substring(0, Math.min(sql.length(), 80)) + "... Resultado: " + count);
            return count;
        } finally {
            cerrarRecursos(rs, pstmt);
        }
    }

    private List<Map<String, String>> obtenerCursos(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT c.id_curso, c.nombre_curso, c.codigo_curso, c.creditos, "
                + "(SELECT COUNT(*) FROM inscripciones i WHERE i.id_curso = c.id_curso AND i.estado = 'activo') AS alumnos "
                + "FROM profesor_curso pc "
                + "JOIN curso c ON pc.id_curso = c.id_curso "
                + "WHERE pc.id_profesor = ? AND pc.estado = 'activo'";
        return ejecutarConsultaLista(sql, idProfesor, conn);
    }

    private List<Map<String, String>> obtenerAlumnosRecientes(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT a.id_alumno, a.nombre, a.apellido_paterno, a.apellido_materno, c.nombre_curso "
                + "FROM alumnos a "
                + "JOIN inscripciones i ON a.id_alumno = i.id_alumno "
                + "JOIN profesor_curso pc ON i.id_curso = pc.id_curso "
                + "JOIN curso c ON pc.id_curso = c.id_curso "
                + "WHERE pc.id_profesor = ? AND i.estado = 'activo' "
                + "ORDER BY i.fecha_inscripcion DESC LIMIT 5";
        return ejecutarConsultaLista(sql, idProfesor, conn);
    }

    private List<Map<String, String>> obtenerEvaluacionesProximas(int idProfesor, Connection conn) throws SQLException {
        String sql = "SELECT e.id_evaluacion, e.nombre_evaluacion, e.fecha_limite, c.nombre_curso "
                + "FROM evaluaciones e "
                + "JOIN curso c ON e.id_curso = c.id_curso "
                + "JOIN profesor_curso pc ON c.id_curso = pc.id_curso "
                + "WHERE pc.id_profesor = ? AND e.fecha_limite > NOW() " // Asumiendo que NOW() es compatible con tu DB (ej. MySQL)
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

            System.out.println("DEBUG DAO:   Ejecutando consulta LISTA: " + sql.substring(0, Math.min(sql.length(), 80)) + "...");
            while (rs.next()) {
                Map<String, String> fila = new HashMap<>();
                for (int i = 1; i <= columnCount; i++) {
                    String columnName = metaData.getColumnName(i);
                    String columnValue = rs.getString(i);

                    // Formateo especial para fecha_limite si es necesario
                    if ("fecha_limite".equalsIgnoreCase(columnName) && rs.getTimestamp(i) != null) {
                        LocalDateTime localDateTime = rs.getTimestamp(i).toLocalDateTime();
                        // Ajusta este patrón si necesitas otro formato de fecha en el JSP
                        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                        columnValue = localDateTime.format(formatter);
                    }
                    fila.put(columnName, columnValue != null ? columnValue : "");
                }
                lista.add(fila);
            }
            System.out.println("DEBUG DAO:   Lista obtenida (tamaño): " + lista.size());
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
            // Usa System.err.println para errores críticos
            System.err.println("DEBUG DAO: Error al cerrar recursos en método auxiliar: " + ex.getMessage());
            // No uses Logger si no tienes un logger configurado, o si quieres que aparezca directamente en la consola
            // Logger.getLogger(HomeDaoProf.class.getName()).log(Level.SEVERE, "Error al cerrar recursos", ex);
        }
    }
}