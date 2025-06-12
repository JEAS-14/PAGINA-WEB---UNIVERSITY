package pe.edu.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Nota {
    private Integer id_nota;
    private Integer id_inscripcion;
    private BigDecimal nota1;
    private BigDecimal nota2;
    private BigDecimal nota3;
    private BigDecimal examen_parcial;
    private BigDecimal examen_final;
    private BigDecimal nota_final;
    private String estado;
    private Timestamp fecha_registro;
    private Timestamp fecha_actualizacion;
    
    // Constructores
    public Nota() {
    }
    
    public Nota(Integer id_nota, Integer id_inscripcion, BigDecimal nota1, BigDecimal nota2, 
                BigDecimal nota3, BigDecimal examen_parcial, BigDecimal examen_final, 
                BigDecimal nota_final, String estado, Timestamp fecha_registro, 
                Timestamp fecha_actualizacion) {
        this.id_nota = id_nota;
        this.id_inscripcion = id_inscripcion;
        this.nota1 = nota1;
        this.nota2 = nota2;
        this.nota3 = nota3;
        this.examen_parcial = examen_parcial;
        this.examen_final = examen_final;
        this.nota_final = nota_final;
        this.estado = estado;
        this.fecha_registro = fecha_registro;
        this.fecha_actualizacion = fecha_actualizacion;
    }
    
    // Getters y Setters
    public Integer getId_nota() {
        return id_nota;
    }
    
    public void setId_nota(Integer id_nota) {
        this.id_nota = id_nota;
    }
    
    public Integer getId_inscripcion() {
        return id_inscripcion;
    }
    
    public void setId_inscripcion(Integer id_inscripcion) {
        this.id_inscripcion = id_inscripcion;
    }
    
    public BigDecimal getNota1() {
        return nota1;
    }
    
    public void setNota1(BigDecimal nota1) {
        this.nota1 = nota1;
    }
    
    public BigDecimal getNota2() {
        return nota2;
    }
    
    public void setNota2(BigDecimal nota2) {
        this.nota2 = nota2;
    }
    
    public BigDecimal getNota3() {
        return nota3;
    }
    
    public void setNota3(BigDecimal nota3) {
        this.nota3 = nota3;
    }
    
    public BigDecimal getExamen_parcial() {
        return examen_parcial;
    }
    
    public void setExamen_parcial(BigDecimal examen_parcial) {
        this.examen_parcial = examen_parcial;
    }
    
    public BigDecimal getExamen_final() {
        return examen_final;
    }
    
    public void setExamen_final(BigDecimal examen_final) {
        this.examen_final = examen_final;
    }
    
    public BigDecimal getNota_final() {
        return nota_final;
    }
    
    public void setNota_final(BigDecimal nota_final) {
        this.nota_final = nota_final;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public Timestamp getFecha_registro() {
        return fecha_registro;
    }
    
    public void setFecha_registro(Timestamp fecha_registro) {
        this.fecha_registro = fecha_registro;
    }
    
    public Timestamp getFecha_actualizacion() {
        return fecha_actualizacion;
    }
    
    public void setFecha_actualizacion(Timestamp fecha_actualizacion) {
        this.fecha_actualizacion = fecha_actualizacion;
    }
    
    // Método para calcular la nota final automáticamente
    public void calcularNotaFinal() {
        if (nota1 != null && nota2 != null && nota3 != null && 
            examen_parcial != null && examen_final != null) {
            
            // Fórmula: (nota1 + nota2 + nota3) * 0.4 + examen_parcial * 0.3 + examen_final * 0.3
            BigDecimal promedioNotas = nota1.add(nota2).add(nota3).divide(new BigDecimal("3"), 2, BigDecimal.ROUND_HALF_UP);
            BigDecimal notaCalculada = promedioNotas.multiply(new BigDecimal("0.4"))
                                      .add(examen_parcial.multiply(new BigDecimal("0.3")))
                                      .add(examen_final.multiply(new BigDecimal("0.3")));
            
            this.nota_final = notaCalculada.setScale(2, BigDecimal.ROUND_HALF_UP);
            
            // Actualizar estado automáticamente (nota mínima 11 para aprobar)
            if (this.nota_final.compareTo(new BigDecimal("11")) >= 0) {
                this.estado = "aprobado";
            } else {
                this.estado = "desaprobado";
            }
        }
    }
    
    // Método toString para debugging
    @Override
    public String toString() {
        return "Nota{" +
                "id_nota=" + id_nota +
                ", id_inscripcion=" + id_inscripcion +
                ", nota1=" + nota1 +
                ", nota2=" + nota2 +
                ", nota3=" + nota3 +
                ", examen_parcial=" + examen_parcial +
                ", examen_final=" + examen_final +
                ", nota_final=" + nota_final +
                ", estado='" + estado + '\'' +
                ", fecha_registro=" + fecha_registro +
                ", fecha_actualizacion=" + fecha_actualizacion +
                '}';
    }
}