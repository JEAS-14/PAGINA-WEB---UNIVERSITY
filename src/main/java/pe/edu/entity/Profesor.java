package pe.edu.entity;

public class Profesor {
    private int idProfesor;       // id_profesor en la base de datos
    private String nombre;        // nombre en la base de datos
    private String apellidoPaterno; // apellido_paterno en la base de datos
    private String apellidoMaterno; // apellido_materno en la base de datos
    private String email;         // email en la base de datos
    private int idFacultad;       // id_facultad en la base de datos
    private String rol;           // rol en la base de datos
    private String password;      // password en la base de datos

    // Constructor vacío
    public Profesor() {
    }

    // Constructor con todos los campos (opcional)
    public Profesor(int idProfesor, String nombre, String apellidoPaterno, String apellidoMaterno, String email, int idFacultad, String rol, String password) {
        this.idProfesor = idProfesor;
        this.nombre = nombre;
        this.apellidoPaterno = apellidoPaterno;
        this.apellidoMaterno = apellidoMaterno;
        this.email = email;
        this.idFacultad = idFacultad;
        this.rol = rol;
        this.password = password;
    }
    private String nombreFacultad;

    public String getNombreFacultad() {
    return nombreFacultad;
    }

    public void setNombreFacultad(String nombreFacultad) {
    this.nombreFacultad = nombreFacultad;
    }

    // Getters y Setters
    public int getIdProfesor() {
        return idProfesor;
    }

    public void setIdProfesor(int idProfesor) {
        this.idProfesor = idProfesor;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellidoPaterno() {
        return apellidoPaterno;
    }

    public void setApellidoPaterno(String apellidoPaterno) {
        this.apellidoPaterno = apellidoPaterno;
    }

    public String getApellidoMaterno() {
        return apellidoMaterno;
    }

    public void setApellidoMaterno(String apellidoMaterno) {
        this.apellidoMaterno = apellidoMaterno;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getIdFacultad() {
        return idFacultad;
    }

    public void setIdFacultad(int idFacultad) {
        this.idFacultad = idFacultad;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}