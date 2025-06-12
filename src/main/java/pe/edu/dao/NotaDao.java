package pe.edu.dao;

import java.sql.*;
import java.util.LinkedList;
import pe.edu.entity.Nota;
import pe.universidad.util.Conexion;

public class NotaDao {

    private Connection connection;

    // CONSTRUCTOR - Inicializa la conexión
    public NotaDao() {
        try {
            Conexion conexion = new Conexion();
            this.connection = conexion.conecta();
            
            if (this.connection != null) {
                System.out.println("✅ Conexión inicializada correctamente en NotaDao");
            } else {
                System.err.println("❌ Error: La conexión es null en NotaDao");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error al inicializar conexión: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Método alternativo para inicializar conexión si es necesario
    private void inicializarConexion() {
        if (this.connection == null) {
            try {
                Conexion conexion = new Conexion();
                this.connection = conexion.conecta();
                System.out.println("🔄 Conexión reinicializada");
            } catch (ClassNotFoundException e) {
                System.err.println("❌ Error al reinicializar conexión: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    // Verificar si la conexión está activa
    private boolean verificarConexion() {
        try {
            if (connection == null || connection.isClosed()) {
                System.out.println("🔄 Reconectando...");
                inicializarConexion();
            }
            return connection != null && !connection.isClosed();
        } catch (SQLException e) {
            System.err.println("❌ Error verificando conexión: " + e.getMessage());
            return false;
        }
    }

    // Listar todas las notas
    public LinkedList<Nota> listar() {
        LinkedList<Nota> lista = new LinkedList<>();

        // Verificar conexión antes de usar
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return lista;
        }

        String sql = "SELECT id_nota, id_inscripcion, nota1, nota2, nota3, "
                + "examen_parcial, examen_final, nota_final, estado, "
                + "fecha_registro, fecha_actualizacion FROM notas ORDER BY id_nota DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            System.out.println("🔍 Ejecutando consulta: " + sql);

            while (rs.next()) {
                Nota nota = new Nota();
                nota.setId_nota(rs.getInt("id_nota"));
                nota.setId_inscripcion(rs.getInt("id_inscripcion"));
                nota.setNota1(rs.getBigDecimal("nota1"));
                nota.setNota2(rs.getBigDecimal("nota2"));
                nota.setNota3(rs.getBigDecimal("nota3"));
                nota.setExamen_parcial(rs.getBigDecimal("examen_parcial"));
                nota.setExamen_final(rs.getBigDecimal("examen_final"));
                nota.setNota_final(rs.getBigDecimal("nota_final"));
                nota.setEstado(rs.getString("estado"));
                nota.setFecha_registro(rs.getTimestamp("fecha_registro"));
                nota.setFecha_actualizacion(rs.getTimestamp("fecha_actualizacion"));

                lista.add(nota);
            }

            System.out.println("✅ Se encontraron " + lista.size() + " notas");

        } catch (SQLException e) {
            System.err.println("❌ Error al listar notas: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    // Buscar nota por ID
    public Nota buscarPorId(int idNota) {
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return null;
        }

        Nota nota = null;
        String sql = "SELECT id_nota, id_inscripcion, nota1, nota2, nota3, "
                + "examen_parcial, examen_final, nota_final, estado, "
                + "fecha_registro, fecha_actualizacion FROM notas WHERE id_nota = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idNota);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    nota = new Nota();
                    nota.setId_nota(rs.getInt("id_nota"));
                    nota.setId_inscripcion(rs.getInt("id_inscripcion"));
                    nota.setNota1(rs.getBigDecimal("nota1"));
                    nota.setNota2(rs.getBigDecimal("nota2"));
                    nota.setNota3(rs.getBigDecimal("nota3"));
                    nota.setExamen_parcial(rs.getBigDecimal("examen_parcial"));
                    nota.setExamen_final(rs.getBigDecimal("examen_final"));
                    nota.setNota_final(rs.getBigDecimal("nota_final"));
                    nota.setEstado(rs.getString("estado"));
                    nota.setFecha_registro(rs.getTimestamp("fecha_registro"));
                    nota.setFecha_actualizacion(rs.getTimestamp("fecha_actualizacion"));
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al buscar nota por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return nota;
    }

    // Insertar nueva nota
    public boolean insertar(Nota nota) {
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return false;
        }

        String sql = "INSERT INTO notas (id_inscripcion, nota1, nota2, nota3, "
                + "examen_parcial, examen_final, nota_final, estado) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, nota.getId_inscripcion());

            // Manejar valores nulos
            if (nota.getNota1() != null) {
                ps.setBigDecimal(2, nota.getNota1());
            } else {
                ps.setNull(2, Types.DECIMAL);
            }

            if (nota.getNota2() != null) {
                ps.setBigDecimal(3, nota.getNota2());
            } else {
                ps.setNull(3, Types.DECIMAL);
            }

            if (nota.getNota3() != null) {
                ps.setBigDecimal(4, nota.getNota3());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }

            if (nota.getExamen_parcial() != null) {
                ps.setBigDecimal(5, nota.getExamen_parcial());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }

            if (nota.getExamen_final() != null) {
                ps.setBigDecimal(6, nota.getExamen_final());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }

            if (nota.getNota_final() != null) {
                ps.setBigDecimal(7, nota.getNota_final());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            ps.setString(8, nota.getEstado() != null ? nota.getEstado() : "pendiente");

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al insertar nota: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Actualizar nota existente
    public boolean actualizar(Nota nota) {
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return false;
        }

        String sql = "UPDATE notas SET id_inscripcion = ?, nota1 = ?, nota2 = ?, "
                + "nota3 = ?, examen_parcial = ?, examen_final = ?, "
                + "nota_final = ?, estado = ? WHERE id_nota = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, nota.getId_inscripcion());

            // Manejar valores nulos
            if (nota.getNota1() != null) {
                ps.setBigDecimal(2, nota.getNota1());
            } else {
                ps.setNull(2, Types.DECIMAL);
            }

            if (nota.getNota2() != null) {
                ps.setBigDecimal(3, nota.getNota2());
            } else {
                ps.setNull(3, Types.DECIMAL);
            }

            if (nota.getNota3() != null) {
                ps.setBigDecimal(4, nota.getNota3());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }

            if (nota.getExamen_parcial() != null) {
                ps.setBigDecimal(5, nota.getExamen_parcial());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }

            if (nota.getExamen_final() != null) {
                ps.setBigDecimal(6, nota.getExamen_final());
            } else {
                ps.setNull(6, Types.DECIMAL);
            }

            if (nota.getNota_final() != null) {
                ps.setBigDecimal(7, nota.getNota_final());
            } else {
                ps.setNull(7, Types.DECIMAL);
            }

            ps.setString(8, nota.getEstado() != null ? nota.getEstado() : "pendiente");
            ps.setInt(9, nota.getId_nota());

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar nota: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Eliminar nota
    public boolean eliminar(int idNota) {
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return false;
        }

        String sql = "DELETE FROM notas WHERE id_nota = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idNota);

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("Error al eliminar nota: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Buscar notas por inscripción
    public LinkedList<Nota> buscarPorInscripcion(int idInscripcion) {
        LinkedList<Nota> lista = new LinkedList<>();
        
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return lista;
        }

        String sql = "SELECT id_nota, id_inscripcion, nota1, nota2, nota3, "
                + "examen_parcial, examen_final, nota_final, estado, "
                + "fecha_registro, fecha_actualizacion FROM notas "
                + "WHERE id_inscripcion = ? ORDER BY id_nota DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, idInscripcion);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Nota nota = new Nota();
                    nota.setId_nota(rs.getInt("id_nota"));
                    nota.setId_inscripcion(rs.getInt("id_inscripcion"));
                    nota.setNota1(rs.getBigDecimal("nota1"));
                    nota.setNota2(rs.getBigDecimal("nota2"));
                    nota.setNota3(rs.getBigDecimal("nota3"));
                    nota.setExamen_parcial(rs.getBigDecimal("examen_parcial"));
                    nota.setExamen_final(rs.getBigDecimal("examen_final"));
                    nota.setNota_final(rs.getBigDecimal("nota_final"));
                    nota.setEstado(rs.getString("estado"));
                    nota.setFecha_registro(rs.getTimestamp("fecha_registro"));
                    nota.setFecha_actualizacion(rs.getTimestamp("fecha_actualizacion"));

                    lista.add(nota);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al buscar notas por inscripción: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    // Contar notas por estado
    public int contarPorEstado(String estado) {
        if (!verificarConexion()) {
            System.err.println("❌ No se pudo establecer conexión a la base de datos");
            return 0;
        }

        String sql = "SELECT COUNT(*) as total FROM notas WHERE estado = ?";
        int total = 0;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, estado);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al contar notas por estado: " + e.getMessage());
            e.printStackTrace();
        }

        return total;
    }

    // Método para cerrar la conexión
    public void cerrarConexion() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("🔐 Conexión cerrada correctamente");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
            e.printStackTrace();
        }
    }
}