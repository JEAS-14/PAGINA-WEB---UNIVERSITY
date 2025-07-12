package pe.edu.dao;

import pe.edu.entity.Postulacion;

import java.sql.*;
import java.text.SimpleDateFormat;

public class PostulacionDAO {
    private String jdbcURL = "jdbc:mysql://localhost:3306/bd-uni?useSSL=false";
    private String jdbcUsername = "root";
    private String jdbcPassword = "";

    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
    }

    public boolean registrarPostulacion(Postulacion postulacion) {
        String callSP = "{CALL sp_registrar_postulacion(?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = getConnection();
             CallableStatement stmt = conn.prepareCall(callSP)) {
            stmt.setString(1, postulacion.getNombreCompleto());
            stmt.setString(2, postulacion.getDni());
            stmt.setDate(3, new java.sql.Date(postulacion.getFechaNacimiento().getTime()));
            stmt.setString(4, postulacion.getEmail());
            stmt.setString(5, postulacion.getTelefono());
            stmt.setString(6, postulacion.getDireccion());
            stmt.setInt(7, postulacion.getCarreraInteresId());
            stmt.setString(8, postulacion.getDocumentosAdjuntosUrl());
            stmt.execute();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
