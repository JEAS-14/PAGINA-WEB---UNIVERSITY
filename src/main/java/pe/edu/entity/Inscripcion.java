package pe.edu.entity;

// Importar Date o Timestamp si vas a manejar fechas/horas como objetos Java.
// Por simplicidad en JSP, usaremos String para fecha_inscripcion.
// import java.sql.Timestamp;
// import java.util.Date;

public class Inscripcion {
    private int idInscripcion; // id_inscripcion en la base de datos
    private int idAlumno;     // id_alumno en la base de datos
    private int idClase;       // id_clase en la base de datos
    private String fechaInscripcion; // fecha_inscripcion en la base de datos (lo manejo como String)
    private String estado;       // estado en la base de datos

    // Constructor vacío
    public Inscripcion() {
    }

    // Constructor con todos los campos (opcional)
    public Inscripcion(int idInscripcion, int idAlumno, int idClase, String fechaInscripcion, String estado) {
        this.idInscripcion = idInscripcion;
        this.idAlumno = idAlumno;
        this.idClase = idClase;
        this.fechaInscripcion = fechaInscripcion;
        this.estado = estado;
    }

    // Getters y Setters
    public int getIdInscripcion() {
        return idInscripcion;
    }

    public void setIdInscripcion(int idInscripcion) {
        this.idInscripcion = idInscripcion;
    }

    public int getIdAlumno() {
        return idAlumno;
    }

    public void setIdAlumno(int idAlumno) {
        this.idAlumno = idAlumno;
    }

    public int getIdClase() {
        return idClase;
    }

    public void setIdClase(int idClase) {
        this.idClase = idClase;
    }

    public String getFechaInscripcion() {
        return fechaInscripcion;
    }

    public void setFechaInscripcion(String fechaInscripcion) {
        this.fechaInscripcion = fechaInscripcion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}