package Profesor.Packages;

import java.util.List;
import java.util.Map;

public class Home {
    // Datos del profesor (tabla 'profesores')
    private int idProfesor;                // profesores.id_profesor
    private String dni;                    // profesores.dni
    private String nombreCompleto;         // profesores.nombre + apellidos
    private String facultad;               // facultades.nombre (relacionado por id_facultad)
    private String telefono;               // profesores.telefono

    // Datos derivados de profesores_cursos y otras relaciones
    private int totalCursos;               // número total de cursos asignados al profesor
    private int cursosActivos;            // cursos donde estado = 'activo'
    private int totalAlumnos;             // alumnos en sus cursos (relacional)
    private int evaluacionesPendientes;   // evaluaciones con estado = 'pendiente'

    // Listas para mostrar en el panel del profesor
    private List<Map<String, String>> cursosList;         // Detalles de cursos asignados
    private List<Map<String, String>> alumnosList;        // Detalles de alumnos por curso
    private List<Map<String, String>> evaluacionesList;   // Detalles de evaluaciones pendientes

    // Getters y Setters
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
}
