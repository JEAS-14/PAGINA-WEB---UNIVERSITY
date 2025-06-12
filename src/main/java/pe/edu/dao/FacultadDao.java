package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Facultad; // Importar la entidad Facultad
import pe.universidad.util.Conexion; // Asegúrate de que esta ruta sea correcta

public class FacultadDao implements DaoCrud<Facultad> {

    @Override
    public LinkedList<Facultad> listar() {
        LinkedList<Facultad> lista = new LinkedList<>();
        Connection cnx = null;
        Statement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_facultad, nombre_facultad FROM facultades;"; // Columnas de tu tabla
            sentencia = cnx.createStatement();
            resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Facultad facultad = new Facultad();
                facultad.setIdFacultad(resultado.getString("id_facultad")); // Asumiendo String para id_facultad
                facultad.setNombreFacultad(resultado.getString("nombre_facultad")); // Columnas de tu tabla
                lista.add(facultad);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println("Error SQL al listar facultades: " + e.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al listar facultades: " + ex.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void insertar(Facultad obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // id_facultad es AUTO_INCREMENT, no lo insertamos explícitamente si es así.
            // Si no es AUTO_INCREMENT y tú lo manejas, deberías incluirlo en la query.
            // Para este ejemplo, asumo que es AUTO_INCREMENT y solo insertamos nombre_facultad.
            String query = "INSERT INTO facultades (nombre_facultad) VALUES(?);"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);

            sentencia.setString(1, obj.getNombreFacultad());

            sentencia.executeUpdate();
            System.out.println("Facultad insertada correctamente");

        } catch (SQLException e) {
            System.out.println("Error SQL al insertar facultad: " + e.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al insertar facultad: " + ex.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public Facultad leer(String id) { // El ID de la facultad se muestra como String en tu tabla
        Facultad facultad = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_facultad, nombre_facultad FROM facultades WHERE id_facultad=?;"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, id);
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                facultad = new Facultad();
                facultad.setIdFacultad(resultado.getString("id_facultad")); // Asumiendo String para id_facultad
                facultad.setNombreFacultad(resultado.getString("nombre_facultad")); // Columnas de tu tabla
            }
            return facultad;
        } catch (SQLException e) {
            System.out.println("Error SQL al leer facultad: " + e.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer facultad: " + ex.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void editar(Facultad obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "UPDATE facultades SET nombre_facultad=? WHERE id_facultad=?;"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);
            
            sentencia.setString(1, obj.getNombreFacultad());
            sentencia.setString(2, obj.getIdFacultad());
            
            sentencia.executeUpdate();
            System.out.println("Facultad editada correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al editar facultad: " + e.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al editar facultad: " + ex.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public void eliminar(String id) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "DELETE FROM facultades WHERE id_facultad=?;"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, id);
            sentencia.executeUpdate();
            System.out.println("Facultad eliminada correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar facultad: " + e.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar facultad: " + ex.getMessage());
            Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(FacultadDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
}