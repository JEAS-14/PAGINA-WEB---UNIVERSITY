package pe.edu.entity;

/**
 *
 * @author LENOVO
 */
public class Curso {
    private String idCurso;
    private String nombreCurso;
    private String codigoCurso;
    private int creditos;
    private int idCarrera;
    // Assuming 'imagen' and 'tipo_imagen' are handled elsewhere or not directly in the entity for simplicity,
    // as they are BLOBs and usually require special handling (e.g., streaming).
    // If you need them in the entity, they would typically be byte[] for image and String for image type.

    public Curso() {
    }

    public Curso(String idCurso, String nombreCurso, String codigoCurso, int creditos, int idCarrera) {
        this.idCurso = idCurso;
        this.nombreCurso = nombreCurso;
        this.codigoCurso = codigoCurso;
        this.creditos = creditos;
        this.idCarrera = idCarrera;
    }

    // Getters and Setters

    public String getIdCurso() {
        return idCurso;
    }

    public void setIdCurso(String idCurso) {
        this.idCurso = idCurso;
    }

    public String getNombreCurso() {
        return nombreCurso;
    }

    public void setNombreCurso(String nombreCurso) {
        this.nombreCurso = nombreCurso;
    }

    public String getCodigoCurso() {
        return codigoCurso;
    }

    public void setCodigoCurso(String codigoCurso) {
        this.codigoCurso = codigoCurso;
    }

    public int getCreditos() {
        return creditos;
    }

    public void setCreditos(int creditos) {
        this.creditos = creditos;
    }

    public int getIdCarrera() {
        return idCarrera;
    }

    public void setIdCarrera(int idCarrera) {
        this.idCarrera = idCarrera;
    }
}