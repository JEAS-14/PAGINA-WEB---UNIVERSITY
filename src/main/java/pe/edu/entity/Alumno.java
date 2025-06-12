package pe.edu.entity;

/**
 *
 * @author LENOVO
 */
public class Alumno {   
    private String id = "";
    private String dni = "";
    private String nombre = "";
    private String apellidoPaterno = ""; // Separado en paterno y materno
    private String apellidoMaterno = ""; // Campo agregado
    private String direccion = "";
    private String telefono = "";
    private String fechaNacimiento = "";
    private String email = "";
    private String idCarrera = "";
    private String rol = "";
    private String password = "";
    private String estado = ""; // Campo agregado
    private String fechaRegistro = ""; // Campo agregado
    private String nombreCarrera; // Campo extra para joins
    
    public Alumno() {
    }
  
    // --- Getters y Setters ---
    
    public String getId() {
        return id;
    }
    
    public void setId(String id) {    
        this.id = id;
    }
    
    public String getDni() {
        return dni;
    }
    
    public void setDni(String dni) {
        this.dni = dni;
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
    
    // Método de conveniencia para obtener apellido completo
    public String getApellido() {
        return (apellidoPaterno + " " + (apellidoMaterno != null ? apellidoMaterno : "")).trim();
    }
    
    // Método de conveniencia para setear apellido completo (por compatibilidad)
    public void setApellido(String apellido) {
        String[] partes = apellido.split(" ", 2);
        this.apellidoPaterno = partes[0];
        this.apellidoMaterno = partes.length > 1 ? partes[1] : "";
    }
    
    public String getDireccion() {
        return direccion;
    }
    
    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
    
    public String getTelefono() {
        return telefono;
    }
    
    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
    
    public String getFechaNacimiento() {
        return fechaNacimiento;
    }
    
    public void setFechaNacimiento(String fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getIdCarrera() {
        return idCarrera;
    }
    
    public void setIdCarrera(String idCarrera) {
        this.idCarrera = idCarrera;
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
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public String getFechaRegistro() {
        return fechaRegistro;
    }
    
    public void setFechaRegistro(String fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    public String getNombreCarrera() {
        return nombreCarrera;
    }
    
    public void setNombreCarrera(String nombreCarrera) {
        this.nombreCarrera = nombreCarrera;
    }
}