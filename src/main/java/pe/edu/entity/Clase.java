/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pe.edu.entity;

/**
 *
 * @author LENOVO
 */
public class Clase {
    private String idClase = "";
    private String idCurso = "";
    private String idProfesor = "";
    private String idHorario = "";
    private String ciclo = "";
    private String nombreCurso;
    private String nombreProfesor;


    public Clase() {
    }
public String getNombreCurso() {
    return nombreCurso;
}
public void setNombreCurso(String nombreCurso) {
    this.nombreCurso = nombreCurso;
}

public String getNombreProfesor() {
    return nombreProfesor;
}
public void setNombreProfesor(String nombreProfesor) {
    this.nombreProfesor = nombreProfesor;
}

    // --- Getters ---
    public String getIdClase() {
        return idClase;
    }

    public String getIdCurso() {
        return idCurso;
    }

    public String getIdProfesor() {
        return idProfesor;
    }

    public String getIdHorario() {
        return idHorario;
    }

    public String getCiclo() {
        return ciclo;
    }

    // --- Setters ---
    public void setIdClase(String idClase) {
        this.idClase = idClase;
    }

    public void setIdCurso(String idCurso) {
        this.idCurso = idCurso;
    }

    public void setIdProfesor(String idProfesor) {
        this.idProfesor = idProfesor;
    }

    public void setIdHorario(String idHorario) {
        this.idHorario = idHorario;
    }

    public void setCiclo(String ciclo) {
        this.ciclo = ciclo;
    }
}
