package pe.edu.dao; // Changed from pe.edu.model to pe.edu.dao based on your JSP usage

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import pe.edu.entity.Curso; // Import the Curso entity
import pe.universidad.util.Conexion;

/**
 *
 * @author LENOVO
 */
public class CursoDao { // Renamed from 'clase' to 'CursoDao'

    // This DAO should not hold state for a single Curso, as it's meant for operations.
    // The previous 'clase' class had properties like idClase, idCurso, etc., making it
    // an entity/model class acting as a DAO. We separate that here.

    // Retrieves all cursos from the database
    public LinkedList<Curso> listar() {
        LinkedList<Curso> lista = new LinkedList<>();
        Connection cnx = null;
        Statement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_curso, nombre_curso, codigo_curso, creditos, id_carrera FROM cursos ORDER BY id_curso;";
            sentencia = cnx.createStatement();
            resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Curso cur = new Curso();
                cur.setIdCurso(resultado.getString("id_curso"));
                cur.setNombreCurso(resultado.getString("nombre_curso"));
                cur.setCodigoCurso(resultado.getString("codigo_curso"));
                cur.setCreditos(resultado.getInt("creditos"));
                cur.setIdCarrera(resultado.getInt("id_carrera"));
                lista.add(cur);
            }
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al listar cursos: " + e.getMessage());
        } finally {
            // Close resources in a finally block to ensure they are closed even if an exception occurs
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        return lista;
    }

    // Reads a single Curso object from the database based on its ID
    public Curso leer(String idCurso) {
        Curso cur = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_curso, nombre_curso, codigo_curso, creditos, id_carrera FROM cursos WHERE id_curso = ?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, idCurso);
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                cur = new Curso();
                cur.setIdCurso(resultado.getString("id_curso"));
                cur.setNombreCurso(resultado.getString("nombre_curso"));
                cur.setCodigoCurso(resultado.getString("codigo_curso"));
                cur.setCreditos(resultado.getInt("creditos"));
                cur.setIdCarrera(resultado.getInt("id_carrera"));
            }
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al leer curso: " + e.getMessage());
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        return cur;
    }

    // Adds a new curso record to the database
    public boolean agregar(Curso curso) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "INSERT INTO cursos (nombre_curso, codigo_curso, creditos, id_carrera) VALUES(?,?,?,?)";
            sentencia = cnx.prepareStatement(query);
            // Assuming id_curso is AUTO_INCREMENT, so we don't insert it.
            // If it's not AUTO_INCREMENT and you need to provide it, adjust the query and parameters.
            sentencia.setString(1, curso.getNombreCurso());
            sentencia.setString(2, curso.getCodigoCurso());
            sentencia.setInt(3, curso.getCreditos());
            sentencia.setInt(4, curso.getIdCarrera());
            int filasAfectadas = sentencia.executeUpdate();
            return filasAfectadas > 0;
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al agregar curso: " + e.getMessage());
            return false;
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    // Updates an existing curso record in the database
    public boolean actualizar(Curso curso) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "UPDATE cursos SET nombre_curso=?, codigo_curso=?, creditos=?, id_carrera=? WHERE id_curso=?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, curso.getNombreCurso());
            sentencia.setString(2, curso.getCodigoCurso());
            sentencia.setInt(3, curso.getCreditos());
            sentencia.setInt(4, curso.getIdCarrera());
            sentencia.setString(5, curso.getIdCurso());
            int filasAfectadas = sentencia.executeUpdate();
            return filasAfectadas > 0;
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al actualizar curso: " + e.getMessage());
            return false;
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    // Deletes a curso record from the database
    public boolean eliminar(String idCurso) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "DELETE FROM cursos WHERE id_curso=?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, idCurso);
            int filasAfectadas = sentencia.executeUpdate();
            return filasAfectadas > 0;
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al eliminar curso: " + e.getMessage());
            return false;
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }

    // Checks if a curso exists by its ID
    public boolean existe(String idCurso) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT COUNT(*) FROM cursos WHERE id_curso=?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, idCurso);
            resultado = sentencia.executeQuery();
            if (resultado.next()) {
                return resultado.getInt(1) > 0;
            }
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al verificar si curso existe: " + e.getMessage());
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        return false;
    }

    // Example of searching by a specific attribute (e.g., nombre_curso)
    public LinkedList<Curso> buscarPorNombre(String nombre) {
        LinkedList<Curso> lista = new LinkedList<>();
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            // Use LIKE for partial matches
            String query = "SELECT id_curso, nombre_curso, codigo_curso, creditos, id_carrera FROM cursos WHERE nombre_curso LIKE ? ORDER BY nombre_curso;";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, "%" + nombre + "%"); // Add wildcards for partial match
            resultado = sentencia.executeQuery();

            while (resultado.next()) {
                Curso cur = new Curso();
                cur.setIdCurso(resultado.getString("id_curso"));
                cur.setNombreCurso(resultado.getString("nombre_curso"));
                cur.setCodigoCurso(resultado.getString("codigo_curso"));
                cur.setCreditos(resultado.getInt("creditos"));
                cur.setIdCarrera(resultado.getInt("id_carrera"));
                lista.add(cur);
            }
        } catch (ClassNotFoundException | SQLException e) {
            System.out.println("Error al buscar cursos por nombre: " + e.getMessage());
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
        return lista;
    }
}