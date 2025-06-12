package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.dao.DaoCrud;
import pe.edu.entity.Alumno;
import pe.universidad.util.Conexion;

public class AlumnoDao implements DaoCrud<Alumno> {

    @Override
    public LinkedList<Alumno> listar() {
        LinkedList<Alumno> lista = new LinkedList<>();
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // Consulta con JOIN para obtener el nombre de la carrera
            String query = "SELECT a.id_alumno, a.dni, a.nombre, a.apellido_paterno, a.apellido_materno, " +
                           "a.direccion, a.telefono, a.fecha_nacimiento, a.email, a.id_carrera, " +
                           "a.rol, a.password, a.estado, a.fecha_registro, ca.nombre_carrera " +
                           "FROM alumnos a " +
                           "LEFT JOIN carreras ca ON a.id_carrera = ca.id_carrera " +
                           "ORDER BY a.id_alumno";

            sentencia = cnx.prepareStatement(query);
            resultado = sentencia.executeQuery();

            while (resultado.next()) {
                Alumno a = new Alumno();
                a.setId(resultado.getString("id_alumno"));
                a.setDni(resultado.getString("dni"));
                a.setNombre(resultado.getString("nombre"));
                a.setApellidoPaterno(resultado.getString("apellido_paterno"));
                a.setApellidoMaterno(resultado.getString("apellido_materno"));
                a.setDireccion(resultado.getString("direccion"));
                a.setTelefono(resultado.getString("telefono"));
                
                // Manejo seguro de la fecha
                if (resultado.getDate("fecha_nacimiento") != null) {
                    a.setFechaNacimiento(resultado.getDate("fecha_nacimiento").toString());
                }
                
                a.setEmail(resultado.getString("email"));
                a.setIdCarrera(String.valueOf(resultado.getInt("id_carrera")));
                a.setRol(resultado.getString("rol"));
                a.setPassword(resultado.getString("password"));
                a.setEstado(resultado.getString("estado"));
                
                // Manejo seguro del timestamp
                if (resultado.getTimestamp("fecha_registro") != null) {
                    a.setFechaRegistro(resultado.getTimestamp("fecha_registro").toString());
                }

                // Setear el nombre de la carrera (puede ser null)
                a.setNombreCarrera(resultado.getString("nombre_carrera"));

                lista.add(a);
            }

        } catch (SQLException e) {
            System.out.println("Error SQL al listar alumnos: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al listar alumnos: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            // Cerrar recursos en orden inverso
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }
        return lista;
    }

    @Override
    public void insertar(Alumno obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // Query corregida - 12 columnas y 12 placeholders
            String query = "INSERT INTO alumnos (dni, nombre, apellido_paterno, apellido_materno, " +
                          "direccion, telefono, fecha_nacimiento, email, id_carrera, rol, password, estado) " +
                          "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

            sentencia = cnx.prepareStatement(query);

            sentencia.setString(1, obj.getDni());
            sentencia.setString(2, obj.getNombre());
            sentencia.setString(3, obj.getApellidoPaterno());
            sentencia.setString(4, obj.getApellidoMaterno());
            sentencia.setString(5, obj.getDireccion());
            sentencia.setString(6, obj.getTelefono());
            
            // Manejo seguro de la fecha
            if (obj.getFechaNacimiento() != null && !obj.getFechaNacimiento().isEmpty()) {
                sentencia.setDate(7, java.sql.Date.valueOf(obj.getFechaNacimiento()));
            } else {
                sentencia.setDate(7, null);
            }
            
            sentencia.setString(8, obj.getEmail());
            
            // Conversión segura de String a int
            if (obj.getIdCarrera() != null && !obj.getIdCarrera().isEmpty()) {
                sentencia.setInt(9, Integer.parseInt(obj.getIdCarrera()));
            } else {
                sentencia.setNull(9, java.sql.Types.INTEGER);
            }
            
            sentencia.setString(10, obj.getRol());
            sentencia.setString(11, obj.getPassword());
            sentencia.setString(12, obj.getEstado() != null && !obj.getEstado().isEmpty() ? obj.getEstado() : "activo");

            int filasAfectadas = sentencia.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Alumno insertado correctamente");
            } else {
                System.out.println("No se pudo insertar el alumno");
            }

        } catch (SQLException e) {
            System.out.println("Error SQL al insertar alumno: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al insertar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException ex) {
            System.out.println("Error de formato numérico al insertar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    }

    @Override
    public Alumno leer(String id) {
        Alumno a = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            
            String query = "SELECT a.*, ca.nombre_carrera " +
                          "FROM alumnos a " +
                          "LEFT JOIN carreras ca ON a.id_carrera = ca.id_carrera " +
                          "WHERE a.id_alumno = ?";
            
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id));
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                a = new Alumno();
                a.setId(resultado.getString("id_alumno"));
                a.setDni(resultado.getString("dni"));
                a.setNombre(resultado.getString("nombre"));
                a.setApellidoPaterno(resultado.getString("apellido_paterno"));
                a.setApellidoMaterno(resultado.getString("apellido_materno"));
                a.setDireccion(resultado.getString("direccion"));
                a.setTelefono(resultado.getString("telefono"));
                
                // Manejo seguro de la fecha
                if (resultado.getDate("fecha_nacimiento") != null) {
                    a.setFechaNacimiento(resultado.getDate("fecha_nacimiento").toString());
                }
                
                a.setEmail(resultado.getString("email"));
                a.setIdCarrera(String.valueOf(resultado.getInt("id_carrera")));
                a.setRol(resultado.getString("rol"));
                a.setPassword(resultado.getString("password"));
                a.setEstado(resultado.getString("estado"));
                
                // Manejo seguro del timestamp
                if (resultado.getTimestamp("fecha_registro") != null) {
                    a.setFechaRegistro(resultado.getTimestamp("fecha_registro").toString());
                }
                
                // Nombre de carrera
                a.setNombreCarrera(resultado.getString("nombre_carrera"));
            }
            
        } catch (SQLException e) {
            System.out.println("Error SQL al leer alumno: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException ex) {
            System.out.println("Error de formato numérico al leer alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }
        return a;
    }

    @Override
    public void editar(Alumno obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            
            String query = "UPDATE alumnos SET dni=?, nombre=?, apellido_paterno=?, apellido_materno=?, " +
                          "direccion=?, telefono=?, fecha_nacimiento=?, email=?, id_carrera=?, " +
                          "rol=?, password=?, estado=? WHERE id_alumno=?";
            
            sentencia = cnx.prepareStatement(query);
            
            sentencia.setString(1, obj.getDni());
            sentencia.setString(2, obj.getNombre());
            sentencia.setString(3, obj.getApellidoPaterno());
            sentencia.setString(4, obj.getApellidoMaterno());
            sentencia.setString(5, obj.getDireccion());
            sentencia.setString(6, obj.getTelefono());
            
            // Manejo seguro de fecha
            if (obj.getFechaNacimiento() != null && !obj.getFechaNacimiento().isEmpty()) {
                sentencia.setDate(7, java.sql.Date.valueOf(obj.getFechaNacimiento()));
            } else {
                sentencia.setDate(7, null);
            }
            
            sentencia.setString(8, obj.getEmail());
            
            // Conversión segura de String a int
            if (obj.getIdCarrera() != null && !obj.getIdCarrera().isEmpty()) {
                sentencia.setInt(9, Integer.parseInt(obj.getIdCarrera()));
            } else {
                sentencia.setNull(9, java.sql.Types.INTEGER);
            }
            
            sentencia.setString(10, obj.getRol());
            sentencia.setString(11, obj.getPassword());
            sentencia.setString(12, obj.getEstado());
            sentencia.setInt(13, Integer.parseInt(obj.getId()));
            
            int filasAfectadas = sentencia.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Alumno editado correctamente");
            } else {
                System.out.println("No se encontró el alumno para editar");
            }
            
        } catch (SQLException e) {
            System.out.println("Error SQL al editar alumno: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al editar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException ex) {
            System.out.println("Error de formato numérico al editar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
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
            
            String query = "DELETE FROM alumnos WHERE id_alumno=?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id));
            
            int filasAfectadas = sentencia.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Alumno eliminado correctamente");
            } else {
                System.out.println("No se encontró el alumno para eliminar");
            }
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar alumno: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException ex) {
            System.out.println("Error de formato numérico al eliminar alumno: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }    
    }
    
    // Método adicional para verificar si existe un alumno por DNI
    public boolean existeAlumnoPorDni(String dni) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        boolean existe = false;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            
            String query = "SELECT COUNT(*) as total FROM alumnos WHERE dni = ?";
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, dni);
            resultado = sentencia.executeQuery();
            
            if (resultado.next()) {
                existe = resultado.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.out.println("Error SQL al verificar DNI: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al verificar DNI: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }
        return existe;
    }
    
    // Método adicional para buscar alumno por DNI
    public Alumno buscarPorDni(String dni) {
        Alumno a = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            
            String query = "SELECT a.*, ca.nombre_carrera " +
                          "FROM alumnos a " +
                          "LEFT JOIN carreras ca ON a.id_carrera = ca.id_carrera " +
                          "WHERE a.dni = ?";
            
            sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, dni);
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                a = new Alumno();
                a.setId(resultado.getString("id_alumno"));
                a.setDni(resultado.getString("dni"));
                a.setNombre(resultado.getString("nombre"));
                a.setApellidoPaterno(resultado.getString("apellido_paterno"));
                a.setApellidoMaterno(resultado.getString("apellido_materno"));
                a.setDireccion(resultado.getString("direccion"));
                a.setTelefono(resultado.getString("telefono"));
                
                if (resultado.getDate("fecha_nacimiento") != null) {
                    a.setFechaNacimiento(resultado.getDate("fecha_nacimiento").toString());
                }
                
                a.setEmail(resultado.getString("email"));
                a.setIdCarrera(String.valueOf(resultado.getInt("id_carrera")));
                a.setRol(resultado.getString("rol"));
                a.setPassword(resultado.getString("password"));
                a.setEstado(resultado.getString("estado"));
                
                if (resultado.getTimestamp("fecha_registro") != null) {
                    a.setFechaRegistro(resultado.getTimestamp("fecha_registro").toString());
                }
                
                a.setNombreCarrera(resultado.getString("nombre_carrera"));
            }
            
        } catch (SQLException e) {
            System.out.println("Error SQL al buscar alumno por DNI: " + e.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al buscar alumno por DNI: " + ex.getMessage());
            Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException e) {
                Logger.getLogger(AlumnoDao.class.getName()).log(Level.SEVERE, null, e);
            }
        }
        return a;
    }
}