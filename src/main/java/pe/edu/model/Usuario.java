package pe.edu.model;

import java.util.LinkedList;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import pe.edu.util.Conexion;

/**
 *
 * @author Estudiante
 */
public class Usuario {

    private String id = "";
    private String password = "";
    private String nombre = "";

    public Usuario() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void crear(String id, String psw, String nombre) {
        this.id = id;
        this.password = psw;
        this.nombre = nombre;
    }

    public Usuario leer() {
        return this;
    }

    public void actualiza(String id, String psw) {
        this.password = psw;
    }

    public void elimina() {
        this.id = "";
        this.password = "";
        this.nombre = "";
    }

    public int getLogueado() throws ClassNotFoundException {
        try {
            int contador = 0;
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "Select * from usuario ";
            query += " where id='" + this.id + "' and ";
            query += " password='" + this.password + "';";
            Statement sentencia = cnx.createStatement();
            ResultSet resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                contador++;
            }
            if (contador != 0) {
                return 1;
            } else {
                return 0;
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return 0;
    }

    public LinkedList<Usuario> muestraUsuarios() throws ClassNotFoundException {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            LinkedList<Usuario> lista = new LinkedList<>();
            String query = "Select * from usuario;";
            Statement sentencia = cnx.createStatement();
            ResultSet resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Usuario u = new Usuario();
                u.id = resultado.getString("id");
                u.password = resultado.getString("password");
                u.nombre = resultado.getString("nombre");
                lista.add(u);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return null;
    }

    public void ver() throws ClassNotFoundException {
        try {
            int contador = 0;
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "Select * from usuario ";
            query += " where id='" + this.id + "'";
            Statement sentencia = cnx.createStatement();
            ResultSet resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                this.id = resultado.getString("id");
                this.password = resultado.getString("password");
                this.nombre = resultado.getString("nombre");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void agregar(String usr, String psw, String nom) throws ClassNotFoundException {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "insert into usuario values(?,?,?)";
            PreparedStatement sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, usr);
            sentencia.setString(2, psw);
            sentencia.setString(3, nom);
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void actualizar(String usr, String psw, String nom) throws ClassNotFoundException {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "update usuario set password=?, nombre=? where id=?";
            PreparedStatement sentencia = cnx.prepareStatement(query);            
            sentencia.setString(1, psw);
            sentencia.setString(2, nom);
            sentencia.setString(3, usr);
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void eliminar(String usr) throws ClassNotFoundException {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "delete from usuario where id=?";
            PreparedStatement sentencia = cnx.prepareStatement(query);            
            sentencia.setString(1, usr);
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }    
}
