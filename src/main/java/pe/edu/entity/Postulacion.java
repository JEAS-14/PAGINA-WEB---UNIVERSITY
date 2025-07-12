package pe.edu.entity;

import java.util.Date;

public class Postulacion {

    private String nombreCompleto;
    private String dni;
    private Date fechaNacimiento;
    private String email;
    private String telefono;
    private String direccion;
    private int carreraInteresId;
    private String documentosAdjuntosUrl;

    // Constructor
    public Postulacion(String nombreCompleto, String dni, Date fechaNacimiento, String email, String telefono,
            String direccion, int carreraInteresId, String documentosAdjuntosUrl) {
        this.nombreCompleto = nombreCompleto;
        this.dni = dni;
        this.fechaNacimiento = fechaNacimiento;
        this.email = email;
        this.telefono = telefono;
        this.direccion = direccion;
        this.carreraInteresId = carreraInteresId;
        this.documentosAdjuntosUrl = documentosAdjuntosUrl;
    }

    // Getters and Setters
    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public int getCarreraInteresId() {
        return carreraInteresId;
    }

    public void setCarreraInteresId(int carreraInteresId) {
        this.carreraInteresId = carreraInteresId;
    }

    public String getDocumentosAdjuntosUrl() {
        return documentosAdjuntosUrl;
    }

    public void setDocumentosAdjuntosUrl(String documentosAdjuntosUrl) {
        this.documentosAdjuntosUrl = documentosAdjuntosUrl;
    }
}
