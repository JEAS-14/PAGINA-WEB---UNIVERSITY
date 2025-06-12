package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Horario; // Importar la entidad Horario
import pe.universidad.util.Conexion; // Asegúrate de que esta ruta sea correcta

public class HorarioDao implements DaoCrud<Horario> {

    @Override
    public LinkedList<Horario> listar() {
        LinkedList<Horario> lista = new LinkedList<>();
        Connection cnx = null;
        Statement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_horario, dia_semana, hora_inicio, hora_fin, aula FROM horarios;"; // Columnas de tu tabla
            sentencia = cnx.createStatement();
            resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Horario horario = new Horario();
                horario.setIdHorario(resultado.getInt("id_horario"));
                horario.setDiaSemana(resultado.getString("dia_semana"));
                horario.setHoraInicio(resultado.getString("hora_inicio"));
                horario.setHoraFin(resultado.getString("hora_fin"));
                horario.setAula(resultado.getString("aula"));
                lista.add(horario);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println("Error SQL al listar horarios: " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al listar horarios: " + ex.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void insertar(Horario obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // id_horario es AUTO_INCREMENT, no lo insertamos explícitamente.
            String query = "INSERT INTO horarios (dia_semana, hora_inicio, hora_fin, aula) VALUES(?,?,?,?);"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);

            sentencia.setString(1, obj.getDiaSemana());
            sentencia.setString(2, obj.getHoraInicio());
            sentencia.setString(3, obj.getHoraFin());
            sentencia.setString(4, obj.getAula());

            sentencia.executeUpdate();
            System.out.println("Horario insertado correctamente");

        } catch (SQLException e) {
            System.out.println("Error SQL al insertar horario: " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al insertar horario: " + ex.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public Horario leer(String id) { // El ID del horario se pasa como String desde la URL
        Horario horario = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_horario, dia_semana, hora_inicio, hora_fin, aula FROM horarios WHERE id_horario=?;"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                horario = new Horario();
                horario.setIdHorario(resultado.getInt("id_horario"));
                horario.setDiaSemana(resultado.getString("dia_semana"));
                horario.setHoraInicio(resultado.getString("hora_inicio"));
                horario.setHoraFin(resultado.getString("hora_fin"));
                horario.setAula(resultado.getString("aula"));
            }
            return horario;
        } catch (SQLException e) {
            System.out.println("Error SQL al leer horario: " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer horario: " + ex.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al leer horario (ID no es un entero): " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void editar(Horario obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "UPDATE horarios SET dia_semana=?, hora_inicio=?, hora_fin=?, aula=? WHERE id_horario=?;"; // Columnas de tu tabla
            sentencia = cnx.prepareStatement(query);
            
            sentencia.setString(1, obj.getDiaSemana());
            sentencia.setString(2, obj.getHoraInicio());
            sentencia.setString(3, obj.getHoraFin());
            sentencia.setString(4, obj.getAula());
            sentencia.setInt(5, obj.getIdHorario()); // El ID para la condición WHERE
            
            sentencia.executeUpdate();
            System.out.println("Horario editado correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al editar horario: " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al editar horario: " + ex.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public void eliminar(String id) { // El ID del horario se pasa como String desde la URL
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "DELETE FROM horarios WHERE id_horario=?;"; // SQL para eliminar por ID
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            sentencia.executeUpdate();
            
            System.out.println("Horario eliminado correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar horario: " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar horario: " + ex.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al eliminar horario (ID no es un entero): " + e.getMessage());
            Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(HorarioDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }    
    }
}