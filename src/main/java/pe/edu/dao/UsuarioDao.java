package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Usuario;
import pe.edu.util.Conexion;

public class UsuarioDao implements DaoCrud<Usuario> {

    @Override
    public LinkedList<Usuario> listar() {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            LinkedList<Usuario> lista = new LinkedList<>();
            String query = "Select * from usuario;";
            Statement sentencia = cnx.createStatement();
            ResultSet resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Usuario u = new Usuario();
                u.setId(resultado.getString("id"));
                u.setPassword(resultado.getString("password"));
                u.setNombre(resultado.getString("nombre"));
                lista.add(u);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(UsuarioDao.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    @Override
    public void insertar(Usuario obj) {        
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "insert into usuario values(?,?,?)";
            PreparedStatement sentencia = cnx.prepareStatement(query);
            sentencia.setString(1, obj.getId());
            sentencia.setString(2, obj.getPassword());
            sentencia.setString(3, obj.getNombre());
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(UsuarioDao.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public Usuario leer(String id) {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            Usuario u = new Usuario();
            String query = "Select * from usuario ";
            query += " where id='" + id + "'";
            Statement sentencia = cnx.createStatement();
            ResultSet resultado = sentencia.executeQuery(query);

            resultado.next();
            u.setId(resultado.getString("id"));
            u.setPassword(resultado.getString("password"));
            u.setNombre(resultado.getString("nombre"));

            return u;
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(UsuarioDao.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    @Override
    public void editar(Usuario obj) {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "update usuario set password=?, nombre=? where id=?";
            PreparedStatement sentencia = cnx.prepareStatement(query);            
            sentencia.setString(1, obj.getPassword());
            sentencia.setString(2, obj.getNombre());
            sentencia.setString(3, obj.getId());
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(UsuarioDao.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public void eliminar(String id) {
        try {
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "delete from usuario where id=?";
            PreparedStatement sentencia = cnx.prepareStatement(query);            
            sentencia.setString(1, id);
            sentencia.executeUpdate();
            sentencia.close();
            cnx.close();
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(UsuarioDao.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public int getLogueado(Usuario u) throws ClassNotFoundException {
        try {
            int contador = 0;
            Conexion c = new Conexion();
            Connection cnx = c.conecta();
            String query = "Select * from usuario ";
            query += " where id='" + u.getId() + "' and ";
            query += " password='" + u.getPassword() + "';";
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
}
