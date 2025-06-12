package pe.edu.entity;

public class Facultad {
    private String idFacultad; // Usamos String porque tu tabla lo muestra así, si es int, cambia a int.
    private String nombreFacultad;

    // Constructor vacío (opcional pero recomendado)
    public Facultad() {
    }

    // Constructor con todos los campos (opcional)
    public Facultad(String idFacultad, String nombreFacultad) {
        this.idFacultad = idFacultad;
        this.nombreFacultad = nombreFacultad;
    }

    // Getters y Setters
    public String getIdFacultad() {
        return idFacultad;
    }

    public void setIdFacultad(String idFacultad) {
        this.idFacultad = idFacultad;
    }

    public String getNombreFacultad() {
        return nombreFacultad;
    }

    public void setNombreFacultad(String nombreFacultad) {
        this.nombreFacultad = nombreFacultad;
    }
}