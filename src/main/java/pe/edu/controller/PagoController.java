package pe.edu.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.logging.Level;
import java.util.logging.Logger;

import pe.edu.entity.Pago;
import pe.edu.dao.PagoDao;

@WebServlet(name = "PagoController", urlPatterns = {"/PagoController"})
public class PagoController extends HttpServlet {

    private PagoDao pagoDao = new PagoDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");
        String idPago = request.getParameter("id");

        if (pagina != null) {
            if (pagina.equals("nuevo")) {
                response.sendRedirect("pago/" + pagina + ".jsp");
            } else {
                response.sendRedirect("pago/" + pagina + ".jsp?id=" + idPago);
            }
        } else {
            // Por defecto ir al listado
            response.sendRedirect("pago/listado.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Pago pago = new Pago();
        String accion = request.getParameter("accion");

        String idPago = request.getParameter("idPago");
        String idAlumno = request.getParameter("idAlumno");
        String fechaPago = request.getParameter("fechaPago");
        String concepto = request.getParameter("concepto");
        String montoStr = request.getParameter("monto");
        String metodoPago = request.getParameter("metodoPago");
        String referencia = request.getParameter("referencia");

        try {
            // Parsear monto y validar fecha
            double monto = (montoStr != null && !montoStr.isEmpty()) ? Double.parseDouble(montoStr) : 0;
            // Validar formato de fecha
            LocalDate.parse(fechaPago, DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            if (idPago != null && !idPago.trim().isEmpty()) {
                pago.setIdPago(Integer.parseInt(idPago));
            }

            pago.setIdAlumno(Integer.parseInt(idAlumno));
            pago.setFechaPago(fechaPago);
            pago.setConcepto(concepto);
            pago.setMonto(monto);
            pago.setMetodoPago(metodoPago);
            pago.setReferencia(referencia);

            switch (accion) {
                case "nuevo":
                    pagoDao.insertar(pago);
                    break;
                case "editar":
                    pagoDao.editar(pago);
                    break;
                case "eliminar":
                    pagoDao.eliminar(idPago);
                    break;
                default:
                    // No hacer nada o manejar error
                    break;
            }

            request.getSession().setAttribute("mensaje", "Operación realizada exitosamente");

        } catch (NumberFormatException | DateTimeParseException e) {
            Logger.getLogger(PagoController.class.getName()).log(Level.SEVERE, null, e);
            request.getSession().setAttribute("error", "Error en los datos ingresados: " + e.getMessage());
        } catch (Exception ex) {
            Logger.getLogger(PagoController.class.getName()).log(Level.SEVERE, null, ex);
            request.getSession().setAttribute("error", "Error al realizar la operación: " + ex.getMessage());
        }

        response.sendRedirect("pago/listado.jsp");
    }
}
