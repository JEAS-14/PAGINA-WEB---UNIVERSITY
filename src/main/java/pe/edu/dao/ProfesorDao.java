package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Profesor; // Make sure this import is correct for your Profesor class
import pe.universidad.util.Conexion; // Make sure this import is correct for your Conexion class

public class ProfesorDao implements DaoCrud<Profesor> {

    @Override
   public LinkedList<Profesor> listar() {
    LinkedList<Profesor> lista = new LinkedList<>();

    try {
        Conexion c = new Conexion();
        Connection cnx = c.conecta();

        String query = "SELECT p.id_profesor, p.nombre, p.apellido_paterno, p.apellido_materno, " +
                       "p.email, p.id_facultad, f.nombre_facultad AS nombre_facultad, p.rol, p.password " +
                       "FROM profesores p " +
                       "JOIN facultades f ON p.id_facultad = f.id_facultad;";

        Statement sentencia = cnx.createStatement();
        ResultSet resultado = sentencia.executeQuery(query);

        while (resultado.next()) {
            Profesor profesor = new Profesor();
            profesor.setIdProfesor(resultado.getInt("id_profesor"));
            profesor.setNombre(resultado.getString("nombre"));
            profesor.setApellidoPaterno(resultado.getString("apellido_paterno"));
            profesor.setApellidoMaterno(resultado.getString("apellido_materno"));
            profesor.setEmail(resultado.getString("email"));
            profesor.setIdFacultad(resultado.getInt("id_facultad"));
            profesor.setNombreFacultad(resultado.getString("nombre_facultad")); // Nuevo campo
            profesor.setRol(resultado.getString("rol"));
            profesor.setPassword(resultado.getString("password"));

            lista.add(profesor);
        }

        resultado.close();
        sentencia.close();
        cnx.close();
        return lista;

    } catch (SQLException e) {
        System.out.println("Error SQL al listar profesores: " + e.getMessage());
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, e);
    } catch (ClassNotFoundException ex) {
        System.out.println("Error de clase no encontrada al listar profesores: " + ex.getMessage());
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, ex);
    }

    return null;
}


   @Override
public void insertar(Profesor obj) {
    Connection cnx = null;
    PreparedStatement sentencia = null;
    try {
        Conexion c = new Conexion();
        cnx = c.conecta();
        
        // Configurar auto-commit para asegurar que se guarde
        cnx.setAutoCommit(true);

        // SQL query - asegúrate de que coincida con tu estructura de tabla
        String query = "INSERT INTO profesores (nombre, apellido_paterno, apellido_materno, "
                     + "email, id_facultad, rol, password) "
                     + "VALUES(?,?,?,?,?,?,?)";

        sentencia = cnx.prepareStatement(query);

        // Validar que los datos no sean nulos antes de insertar
        sentencia.setString(1, obj.getNombre() != null ? obj.getNombre() : "");
        sentencia.setString(2, obj.getApellidoPaterno() != null ? obj.getApellidoPaterno() : "");
        sentencia.setString(3, obj.getApellidoMaterno() != null ? obj.getApellidoMaterno() : "");
        sentencia.setString(4, obj.getEmail() != null ? obj.getEmail() : "");
        sentencia.setInt(5, obj.getIdFacultad());
        sentencia.setString(6, obj.getRol() != null ? obj.getRol() : "");
        sentencia.setString(7, obj.getPassword() != null ? obj.getPassword() : "");

        int rowsAffected = sentencia.executeUpdate();
        
        if (rowsAffected > 0) {
            System.out.println("Profesor insertado correctamente. Filas afectadas: " + rowsAffected);
        } else {
            System.out.println("No se pudo insertar el profesor.");
        }

    } catch (SQLException e) {
        System.out.println("Error SQL al insertar profesor: " + e.getMessage());
        e.printStackTrace(); // Para ver el error completo
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, e);
    } catch (ClassNotFoundException ex) {
        System.out.println("Error de clase no encontrada al insertar profesor: " + ex.getMessage());
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        // Cerrar recursos en bloque finally para asegurar que siempre se cierren
        try {
            if (sentencia != null) sentencia.close();
            if (cnx != null) cnx.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar conexiones: " + e.getMessage());
        }
    }
}
    @Override
    public Profesor leer(String id) {
        Profesor profesor = null;
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            // SQL query to read a professor, based on your provided image columns
            String query = "SELECT id_profesor, nombre, apellido_paterno, apellido_materno, "
                         + "email, id_facultad, rol, password "
                         + "FROM profesores WHERE id_profesor=?"; // Using PreparedStatement for safety
            PreparedStatement sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convert String ID from DaoCrud to int for Profesor ID

            ResultSet resultado = sentencia.executeQuery();

            if (resultado.next()) {
                profesor = new Profesor();
                profesor.setIdProfesor(resultado.getInt("id_profesor"));
                profesor.setNombre(resultado.getString("nombre"));
                profesor.setApellidoPaterno(resultado.getString("apellido_paterno"));
                profesor.setApellidoMaterno(resultado.getString("apellido_materno"));
                profesor.setEmail(resultado.getString("email"));
                profesor.setIdFacultad(resultado.getInt("id_facultad"));
                profesor.setRol(resultado.getString("rol"));
                profesor.setPassword(resultado.getString("password"));
            }
            resultado.close();
            sentencia.close();
            cnx.close();
            return profesor;
        } catch (SQLException e) {
            System.out.println("Error SQL al leer profesor: " + e.getMessage());
            Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer profesor: " + ex.getMessage());
            Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    @Override
public void editar(Profesor obj) {
    Connection cnx = null;
    PreparedStatement sentencia = null;
    try {
        Conexion c = new Conexion();
        cnx = c.conecta();
        
        // Configurar auto-commit
        cnx.setAutoCommit(true);
        
        // Verificar que el ID del profesor no sea 0 o nulo
        if (obj.getIdProfesor() <= 0) {
            System.out.println("Error: ID de profesor inválido para editar: " + obj.getIdProfesor());
            return;
        }

        String query = "UPDATE profesores SET nombre=?, apellido_paterno=?, apellido_materno=?, "
                     + "email=?, id_facultad=?, rol=?, password=? "
                     + "WHERE id_profesor=?";

        sentencia = cnx.prepareStatement(query);

        // Validar datos antes de actualizar
        sentencia.setString(1, obj.getNombre() != null ? obj.getNombre() : "");
        sentencia.setString(2, obj.getApellidoPaterno() != null ? obj.getApellidoPaterno() : "");
        sentencia.setString(3, obj.getApellidoMaterno() != null ? obj.getApellidoMaterno() : "");
        sentencia.setString(4, obj.getEmail() != null ? obj.getEmail() : "");
        sentencia.setInt(5, obj.getIdFacultad());
        sentencia.setString(6, obj.getRol() != null ? obj.getRol() : "");
        sentencia.setString(7, obj.getPassword() != null ? obj.getPassword() : "");
        sentencia.setInt(8, obj.getIdProfesor()); // ID para WHERE clause

        int rowsAffected = sentencia.executeUpdate();
        
        if (rowsAffected > 0) {
            System.out.println("Profesor editado correctamente. Filas afectadas: " + rowsAffected);
        } else {
            System.out.println("No se encontró el profesor con ID " + obj.getIdProfesor() + " para editar.");
        }

    } catch (SQLException e) {
        System.out.println("Error SQL al editar profesor: " + e.getMessage());
        e.printStackTrace(); // Para ver el error completo
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, e);
    } catch (ClassNotFoundException ex) {
        System.out.println("Error de clase no encontrada al editar profesor: " + ex.getMessage());
        Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        // Cerrar recursos en bloque finally
        try {
            if (sentencia != null) sentencia.close();
            if (cnx != null) cnx.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar conexiones: " + e.getMessage());
        }
    }
}

// Método adicional para debugging - verificar estructura de tabla
public void verificarEstructuraTabla() {
    Connection cnx = null;
    PreparedStatement sentencia = null;
    ResultSet resultado = null;
    try {
        Conexion c = new Conexion();
        cnx = c.conecta();
        
        // Verificar estructura de la tabla
        String query = "DESCRIBE profesores";
        sentencia = cnx.prepareStatement(query);
        resultado = sentencia.executeQuery();
        
        System.out.println("Estructura de la tabla profesores:");
        while (resultado.next()) {
            System.out.println("Campo: " + resultado.getString("Field") + 
                             " - Tipo: " + resultado.getString("Type") + 
                             " - Nulo: " + resultado.getString("Null") + 
                             " - Key: " + resultado.getString("Key"));
        }
        
    } catch (SQLException e) {
        System.out.println("Error al verificar estructura: " + e.getMessage());
    } catch (ClassNotFoundException ex) {
        System.out.println("Error de conexión: " + ex.getMessage());
    } finally {
        try {
            if (resultado != null) resultado.close();
            if (sentencia != null) sentencia.close();
            if (cnx != null) cnx.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar conexiones: " + e.getMessage());
        }
    }
}

    @Override
    public void eliminar(String id) {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            // SQL query to delete a professor, based on your provided image columns
            String query = "DELETE FROM profesores WHERE id_profesor=?"; // Delete by id_profesor
            PreparedStatement sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convert String ID to int

            int rowsAffected = sentencia.executeUpdate(); // Execute the delete
            if (rowsAffected > 0) {
                System.out.println("Profesor eliminado correctamente. Filas afectadas: " + rowsAffected);
            } else {
                System.out.println("No se encontró el profesor con ID " + id + " para eliminar. Filas afectadas: " + rowsAffected);
            }
            
            sentencia.close();
            cnx.close();

        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar profesor: " + e.getMessage());
            Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar profesor: " + ex.getMessage());
            Logger.getLogger(ProfesorDao.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}