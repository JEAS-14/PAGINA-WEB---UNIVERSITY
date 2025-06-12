package Profesor.Packages;

import java.util.ArrayList; // Importar para inicializar las listas
import java.util.List;
import java.util.Map;
import java.util.Date; // Importar para el campo 'today'

public class Home {
    // Datos del profesor (tabla 'profesores')
    private int idProfesor;
    private String dni;
    private String nombreCompleto;
    private String facultad;
    private String telefono;

    // Datos derivados de profesores_cursos y otras relaciones
    private int totalCursos;
    private int cursosActivos;
    private int totalAlumnos;
    private int evaluacionesPendientes;

    // Listas para mostrar en el panel del profesor
    private List<Map<String, String>> cursosList;
    private List<Map<String, String>> alumnosList;
    private List<Map<String, String>> evaluacionesList;

    // Campo para la fecha actual o de último acceso
    private Date today; // Usado para formatear la fecha en el JSP

    // CONSTRUCTOR: ¡IMPORTANTE! Inicializar las listas aquí
    public Home() {
        this.cursosList = new ArrayList<>();
        this.alumnosList = new ArrayList<>();
        this.evaluacionesList = new ArrayList<>();
        // this.today = new Date(); // Puedes inicializarlo aquí o en el controlador
    }

    // --- Getters y Setters ---

    public int getIdProfesor() {
        return idProfesor;
    }

    public void setIdProfesor(int idProfesor) {
        this.idProfesor = idProfesor;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getFacultad() {
        return facultad;
    }

    public void setFacultad(String facultad) {
        this.facultad = facultad;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public int getTotalCursos() {
        return totalCursos;
    }

    public void setTotalCursos(int totalCursos) {
        this.totalCursos = totalCursos;
    }

    public int getCursosActivos() {
        return cursosActivos;
    }

    public void setCursosActivos(int cursosActivos) {
        this.cursosActivos = cursosActivos;
    }

    public int getTotalAlumnos() {
        return totalAlumnos;
    }

    public void setTotalAlumnos(int totalAlumnos) {
        this.totalAlumnos = totalAlumnos;
    }

    public int getEvaluacionesPendientes() {
        return evaluacionesPendientes;
    }

    public void setEvaluacionesPendientes(int evaluacionesPendientes) {
        this.evaluacionesPendientes = evaluacionesPendientes;
    }

    public List<Map<String, String>> getCursosList() {
        return cursosList;
    }

    public void setCursosList(List<Map<String, String>> cursosList) {
        this.cursosList = cursosList;
    }

    public List<Map<String, String>> getAlumnosList() {
        return alumnosList;
    }

    public void setAlumnosList(List<Map<String, String>> alumnosList) {
        this.alumnosList = alumnosList;
    }

    public List<Map<String, String>> getEvaluacionesList() {
        return evaluacionesList;
    }

    public void setEvaluacionesList(List<Map<String, String>> evaluacionesList) {
        this.evaluacionesList = evaluacionesList;
    }

    public Date getToday() {
        return today;
    }

    public void setToday(Date today) {
        this.today = today;
    }
}