package pe.edu.entity;

public class Pago {
    private int idPago;         // id_pago en la base de datos
    private int idAlumno;       // id_alumno en la base de datos
    private String fechaPago;   // fecha_pago en la base de datos (lo manejo como String "YYYY-MM-DD")
    private String concepto;    // concepto en la base de datos
    private double monto;       // monto en la base de datos
    private String metodoPago;  // metodo_pago en la base de datos
    private String referencia;  // referencia en la base de datos

    // Constructor vacío
    public Pago() {
    }

    // Constructor con todos los campos (opcional)
    public Pago(int idPago, int idAlumno, String fechaPago, String concepto, double monto, String metodoPago, String referencia) {
        this.idPago = idPago;
        this.idAlumno = idAlumno;
        this.fechaPago = fechaPago;
        this.concepto = concepto;
        this.monto = monto;
        this.metodoPago = metodoPago;
        this.referencia = referencia;
    }

    // Getters y Setters
    public int getIdPago() {
        return idPago;
    }

    public void setIdPago(int idPago) {
        this.idPago = idPago;
    }

    public int getIdAlumno() {
        return idAlumno;
    }

    public void setIdAlumno(int idAlumno) {
        this.idAlumno = idAlumno;
    }

    public String getFechaPago() {
        return fechaPago;
    }

    public void setFechaPago(String fechaPago) {
        this.fechaPago = fechaPago;
    }

    public String getConcepto() {
        return concepto;
    }

    public void setConcepto(String concepto) {
        this.concepto = concepto;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }
}