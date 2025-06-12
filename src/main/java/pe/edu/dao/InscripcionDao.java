package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Inscripcion; // Importar la entidad Inscripcion
import pe.universidad.util.Conexion; // Asegúrate de que esta ruta sea correcta

public class InscripcionDao implements DaoCrud<Inscripcion> {

    @Override
    public LinkedList<Inscripcion> listar() {
        LinkedList<Inscripcion> lista = new LinkedList<>();
        Connection cnx = null;
        Statement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            // Columnas de tu tabla: id_inscripcion, id_alumno, id_clase, fecha_inscripcion, estado
            String query = "SELECT id_inscripcion, id_alumno, id_clase, fecha_inscripcion, estado FROM inscripciones;";
            sentencia = cnx.createStatement();
            resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Inscripcion inscripcion = new Inscripcion();
                inscripcion.setIdInscripcion(resultado.getInt("id_inscripcion"));
                inscripcion.setIdAlumno(resultado.getInt("id_alumno"));
                inscripcion.setIdClase(resultado.getInt("id_clase"));
                inscripcion.setFechaInscripcion(resultado.getString("fecha_inscripcion"));
                inscripcion.setEstado(resultado.getString("estado"));
                lista.add(inscripcion);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println("Error SQL al listar inscripciones: " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al listar inscripciones: " + ex.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void insertar(Inscripcion obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // id_inscripcion es AUTO_INCREMENT, no lo insertamos explícitamente.
            String query = "INSERT INTO inscripciones (id_alumno, id_clase, fecha_inscripcion, estado) VALUES(?,?,?,?);";
            sentencia = cnx.prepareStatement(query);

            sentencia.setInt(1, obj.getIdAlumno());
            sentencia.setInt(2, obj.getIdClase());
            sentencia.setString(3, obj.getFechaInscripcion()); // Ojo: para String, el formato debe ser 'YYYY-MM-DD HH:MM:SS'
            sentencia.setString(4, obj.getEstado());

            sentencia.executeUpdate();
            System.out.println("Inscripción insertada correctamente");

        } catch (SQLException e) {
            System.out.println("Error SQL al insertar inscripción: " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al insertar inscripción: " + ex.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public Inscripcion leer(String id) { // El ID de la inscripción se pasa como String desde la URL
        Inscripcion inscripcion = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_inscripcion, id_alumno, id_clase, fecha_inscripcion, estado FROM inscripciones WHERE id_inscripcion=?;";
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                inscripcion = new Inscripcion();
                inscripcion.setIdInscripcion(resultado.getInt("id_inscripcion"));
                inscripcion.setIdAlumno(resultado.getInt("id_alumno"));
                inscripcion.setIdClase(resultado.getInt("id_clase"));
                inscripcion.setFechaInscripcion(resultado.getString("fecha_inscripcion"));
                inscripcion.setEstado(resultado.getString("estado"));
            }
            return inscripcion;
        } catch (SQLException e) {
            System.out.println("Error SQL al leer inscripción: " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer inscripción: " + ex.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al leer inscripción (ID no es un entero): " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void editar(Inscripcion obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "UPDATE inscripciones SET id_alumno=?, id_clase=?, fecha_inscripcion=?, estado=? WHERE id_inscripcion=?;";
            sentencia = cnx.prepareStatement(query);
            
            sentencia.setInt(1, obj.getIdAlumno());
            sentencia.setInt(2, obj.getIdClase());
            sentencia.setString(3, obj.getFechaInscripcion());
            sentencia.setString(4, obj.getEstado());
            sentencia.setInt(5, obj.getIdInscripcion()); // El ID para la condición WHERE
            
            sentencia.executeUpdate();
            System.out.println("Inscripción editada correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al editar inscripción: " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al editar inscripción: " + ex.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public void eliminar(String id) { // El ID de la inscripción se pasa como String desde la URL
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "DELETE FROM inscripciones WHERE id_inscripcion=?;";
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            sentencia.executeUpdate();
            
            System.out.println("Inscripción eliminada correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar inscripción: " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar inscripción: " + ex.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al eliminar inscripción (ID no es un entero): " + e.getMessage());
            Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(InscripcionDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }    
    }
}