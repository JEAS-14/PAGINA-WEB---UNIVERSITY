package pe.edu.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import pe.edu.entity.Pago; // Importar la entidad Pago
import pe.universidad.util.Conexion; // Asegúrate de que esta ruta sea correcta

public class PagoDao implements DaoCrud<Pago> {

    @Override
    public LinkedList<Pago> listar() {
        LinkedList<Pago> lista = new LinkedList<>();
        Connection cnx = null;
        Statement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            // Columnas de tu tabla: id_pago, id_alumno, fecha_pago, concepto, monto, metodo_pago, referencia
            String query = "SELECT id_pago, id_alumno, fecha_pago, concepto, monto, metodo_pago, referencia FROM pagos;";
            sentencia = cnx.createStatement();
            resultado = sentencia.executeQuery(query);

            while (resultado.next()) {
                Pago pago = new Pago();
                pago.setIdPago(resultado.getInt("id_pago"));
                pago.setIdAlumno(resultado.getInt("id_alumno"));
                pago.setFechaPago(resultado.getString("fecha_pago")); // Lo obtenemos como String
                pago.setConcepto(resultado.getString("concepto"));
                pago.setMonto(resultado.getDouble("monto"));
                pago.setMetodoPago(resultado.getString("metodo_pago"));
                pago.setReferencia(resultado.getString("referencia"));
                lista.add(pago);
            }
            return lista;
        } catch (SQLException e) {
            System.out.println("Error SQL al listar pagos: " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al listar pagos: " + ex.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void insertar(Pago obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();

            // id_pago es AUTO_INCREMENT, no lo insertamos explícitamente.
            String query = "INSERT INTO pagos (id_alumno, fecha_pago, concepto, monto, metodo_pago, referencia) VALUES(?,?,?,?,?,?);";
            sentencia = cnx.prepareStatement(query);

            sentencia.setInt(1, obj.getIdAlumno());
            sentencia.setString(2, obj.getFechaPago()); // Formato 'YYYY-MM-DD'
            sentencia.setString(3, obj.getConcepto());
            sentencia.setDouble(4, obj.getMonto());
            sentencia.setString(5, obj.getMetodoPago());
            sentencia.setString(6, obj.getReferencia());

            sentencia.executeUpdate();
            System.out.println("Pago insertado correctamente");

        } catch (SQLException e) {
            System.out.println("Error SQL al insertar pago: " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al insertar pago: " + ex.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public Pago leer(String id) { // El ID del pago se pasa como String desde la URL
        Pago pago = null;
        Connection cnx = null;
        PreparedStatement sentencia = null;
        ResultSet resultado = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "SELECT id_pago, id_alumno, fecha_pago, concepto, monto, metodo_pago, referencia FROM pagos WHERE id_pago=?;";
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            resultado = sentencia.executeQuery();

            if (resultado.next()) {
                pago = new Pago();
                pago.setIdPago(resultado.getInt("id_pago"));
                pago.setIdAlumno(resultado.getInt("id_alumno"));
                pago.setFechaPago(resultado.getString("fecha_pago"));
                pago.setConcepto(resultado.getString("concepto"));
                pago.setMonto(resultado.getDouble("monto"));
                pago.setMetodoPago(resultado.getString("metodo_pago"));
                pago.setReferencia(resultado.getString("referencia"));
            }
            return pago;
        } catch (SQLException e) {
            System.out.println("Error SQL al leer pago: " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al leer pago: " + ex.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al leer pago (ID no es un entero): " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (resultado != null) resultado.close();
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return null;
    }

    @Override
    public void editar(Pago obj) {
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "UPDATE pagos SET id_alumno=?, fecha_pago=?, concepto=?, monto=?, metodo_pago=?, referencia=? WHERE id_pago=?;";
            sentencia = cnx.prepareStatement(query);
            
            sentencia.setInt(1, obj.getIdAlumno());
            sentencia.setString(2, obj.getFechaPago());
            sentencia.setString(3, obj.getConcepto());
            sentencia.setDouble(4, obj.getMonto());
            sentencia.setString(5, obj.getMetodoPago());
            sentencia.setString(6, obj.getReferencia());
            sentencia.setInt(7, obj.getIdPago()); // El ID para la condición WHERE
            
            sentencia.executeUpdate();
            System.out.println("Pago editado correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al editar pago: " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al editar pago: " + ex.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    @Override
    public void eliminar(String id) { // El ID del pago se pasa como String desde la URL
        Connection cnx = null;
        PreparedStatement sentencia = null;
        try {
            Conexion c = new Conexion();
            cnx = c.conecta();
            String query = "DELETE FROM pagos WHERE id_pago=?;";
            sentencia = cnx.prepareStatement(query);
            sentencia.setInt(1, Integer.parseInt(id)); // Convertir String a int para el ID
            sentencia.executeUpdate();
            
            System.out.println("Pago eliminado correctamente");
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar pago: " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } catch (ClassNotFoundException ex) {
            System.out.println("Error de clase no encontrada al eliminar pago: " + ex.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
        } catch (NumberFormatException e) {
            System.out.println("Error de formato de número al eliminar pago (ID no es un entero): " + e.getMessage());
            Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, e);
        } finally {
            try {
                if (sentencia != null) sentencia.close();
                if (cnx != null) cnx.close();
            } catch (SQLException ex) {
                Logger.getLogger(PagoDao.class.getName()).log(Level.SEVERE, null, ex);
            }
        }    
    }
}