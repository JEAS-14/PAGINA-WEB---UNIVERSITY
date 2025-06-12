package pe.edu.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.dao.NotaDao;
import pe.edu.entity.Nota;

@WebServlet(name = "NotaController", urlPatterns = {"/NotaController"})
public class NotaController extends HttpServlet {

    private NotaDao notaDao = new NotaDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pagina = request.getParameter("pagina");
        String id = request.getParameter("id");

        try {
            if (pagina != null) {
                switch (pagina) {
                    case "nuevo":
                        // Redirigir a la página de nuevo registro
                        request.getRequestDispatcher("nota/nuevo.jsp").forward(request, response);
                        break;
                        
                    case "ver":
                        if (id != null && !id.trim().isEmpty()) {
                            int idNota = Integer.parseInt(id);
                            Nota nota = notaDao.buscarPorId(idNota);
                            if (nota != null) {
                                request.setAttribute("nota", nota);
                                request.getRequestDispatcher("nota/ver.jsp").forward(request, response);
                            } else {
                                request.getSession().setAttribute("error", "Nota no encontrada");
                                response.sendRedirect("nota/listado.jsp");
                            }
                        } else {
                            request.getSession().setAttribute("error", "ID de nota no proporcionado");
                            response.sendRedirect("nota/listado.jsp");
                        }
                        break;
                        
                    case "editar":
                        if (id != null && !id.trim().isEmpty()) {
                            int idNota = Integer.parseInt(id);
                            Nota nota = notaDao.buscarPorId(idNota);
                            if (nota != null) {
                                request.setAttribute("nota", nota);
                                request.getRequestDispatcher("nota/editar.jsp").forward(request, response);
                            } else {
                                request.getSession().setAttribute("error", "Nota no encontrada");
                                response.sendRedirect("nota/listado.jsp");
                            }
                        } else {
                            request.getSession().setAttribute("error", "ID de nota no proporcionado");
                            response.sendRedirect("nota/listado.jsp");
                        }
                        break;
                        
                    case "eliminar":
                        if (id != null && !id.trim().isEmpty()) {
                            int idNota = Integer.parseInt(id);
                            Nota nota = notaDao.buscarPorId(idNota);
                            if (nota != null) {
                                request.setAttribute("nota", nota);
                                request.getRequestDispatcher("nota/eliminar.jsp").forward(request, response);
                            } else {
                                request.getSession().setAttribute("error", "Nota no encontrada");
                                response.sendRedirect("nota/listado.jsp");
                            }
                        } else {
                            request.getSession().setAttribute("error", "ID de nota no proporcionado");
                            response.sendRedirect("nota/listado.jsp");
                        }
                        break;
                        
                    case "listado":
                        request.getRequestDispatcher("nota/listado.jsp").forward(request, response);
                        break;
                        
                    default:
                        request.getRequestDispatcher("nota/listado.jsp").forward(request, response);
                        break;
                }
            } else {
                // Si no hay parámetro página, ir al listado
                request.getRequestDispatcher("nota/listado.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "ID de nota inválido: " + e.getMessage());
            response.sendRedirect("nota/listado.jsp");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error: " + e.getMessage());
            response.sendRedirect("nota/listado.jsp");
            e.printStackTrace();
        }
    }

   @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String accion = request.getParameter("accion");

    try {
        switch (accion) {
            case "nuevo":
                // Usar el nombre exacto del JSP (idInscripcion)
                String idInscripcionStr = request.getParameter("idInscripcion");
                String nota1Str = request.getParameter("nota1");
                String nota2Str = request.getParameter("nota2");
                String nota3Str = request.getParameter("nota3");
                String examenParcialStr = request.getParameter("examenParcial");
                String examenFinalStr = request.getParameter("examenFinal");
                String notaFinalStr = request.getParameter("notaFinal");
                String estado = request.getParameter("estado");

                // Debugging: mostrar lo que se recibe
                System.out.println("DEBUG - Parámetros recibidos:");
                System.out.println("idInscripcion: " + idInscripcionStr);
                System.out.println("nota1: " + nota1Str);
                System.out.println("nota2: " + nota2Str);
                System.out.println("nota3: " + nota3Str);
                System.out.println("examenParcial: " + examenParcialStr);
                System.out.println("examenFinal: " + examenFinalStr);
                System.out.println("notaFinal: " + notaFinalStr);
                System.out.println("estado: " + estado);

                if (datosBasicosCompletos(idInscripcionStr, nota1Str, nota2Str, notaFinalStr, estado)) {
                    Nota nueva = new Nota();
                    nueva.setId_inscripcion(Integer.parseInt(idInscripcionStr));

                    // Asignar notas con validación
                    asignarNota(nueva, "nota1", nota1Str);
                    asignarNota(nueva, "nota2", nota2Str);
                    asignarNota(nueva, "nota3", nota3Str);
                    asignarNota(nueva, "examen_parcial", examenParcialStr);
                    asignarNota(nueva, "examen_final", examenFinalStr);

                    // La nota final es requerida en el JSP, así que usarla
                    if (notaFinalStr != null && !notaFinalStr.trim().isEmpty()) {
                        BigDecimal notaFinal = new BigDecimal(notaFinalStr.trim());
                        if (validarNota(notaFinal)) {
                            nueva.setNota_final(notaFinal);
                        } else {
                            throw new IllegalArgumentException("Nota final debe estar entre 0 y 20");
                        }
                    }

                    // El estado es requerido en el JSP, así que validarlo y asignarlo
                    if (estado != null && !estado.isEmpty() && validarEstado(estado)) {
                        nueva.setEstado(estado);
                    } else {
                        throw new IllegalArgumentException("Estado debe ser: aprobado, desaprobado o pendiente");
                    }

                    if (notaDao.insertar(nueva)) {
                        request.getSession().setAttribute("mensaje", "Nota registrada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "Error al registrar la nota");
                    }
                } else {
                    request.getSession().setAttribute("error", "Los campos requeridos no están completos (ID Inscripción, Nota 1, Nota 2, Nota Final y Estado)");
                }
                break;

            case "editar":
                // Mantener la lógica de editar como está (usando nombres con guiones bajos)
                String id_notaStr = request.getParameter("id_nota");
                String id_inscripcionStr = request.getParameter("id_inscripcion");
                String nota1StrEdit = request.getParameter("nota1");
                String nota2StrEdit = request.getParameter("nota2");
                String nota3StrEdit = request.getParameter("nota3");
                String examen_parcialStr = request.getParameter("examen_parcial");
                String examen_finalStr = request.getParameter("examen_final");
                String estadoEdit = request.getParameter("estado");

                if (id_notaStr != null && !id_notaStr.isEmpty() && datosBasicosCompletos(id_inscripcionStr)) {
                    Nota editar = new Nota();
                    editar.setId_nota(Integer.parseInt(id_notaStr));
                    editar.setId_inscripcion(Integer.parseInt(id_inscripcionStr));

                    // Asignar notas con validación
                    asignarNota(editar, "nota1", nota1StrEdit);
                    asignarNota(editar, "nota2", nota2StrEdit);
                    asignarNota(editar, "nota3", nota3StrEdit);
                    asignarNota(editar, "examen_parcial", examen_parcialStr);
                    asignarNota(editar, "examen_final", examen_finalStr);

                    // Calcular nota final automáticamente
                    editar.calcularNotaFinal();

                    // Si se proporciona estado manualmente, validarlo y asignarlo
                    if (estadoEdit != null && !estadoEdit.isEmpty() && validarEstado(estadoEdit)) {
                        editar.setEstado(estadoEdit);
                    }

                    if (notaDao.actualizar(editar)) {
                        request.getSession().setAttribute("mensaje", "Nota actualizada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "Error al actualizar la nota");
                    }
                } else {
                    request.getSession().setAttribute("error", "ID de nota e ID de inscripción son requeridos");
                }
                break;

            case "eliminar":
            case "confirmar_eliminar":
                String id_notaStrElim = request.getParameter("id_nota");
                if (id_notaStrElim != null && !id_notaStrElim.isEmpty()) {
                    int idNota = Integer.parseInt(id_notaStrElim);
                    if (notaDao.eliminar(idNota)) {
                        request.getSession().setAttribute("mensaje", "Nota eliminada correctamente");
                    } else {
                        request.getSession().setAttribute("error", "Error al eliminar la nota");
                    }
                } else {
                    request.getSession().setAttribute("error", "ID de nota no proporcionado");
                }
                break;

            default:
                request.getSession().setAttribute("error", "Acción no válida");
                break;
        }
    } catch (NumberFormatException e) {
        request.getSession().setAttribute("error", "Formato de número inválido: " + e.getMessage());
    } catch (IllegalArgumentException e) {
        request.getSession().setAttribute("error", e.getMessage());
    } catch (Exception e) {
        request.getSession().setAttribute("error", "Error: " + e.getMessage());
        e.printStackTrace();
    }

    response.sendRedirect("nota/listado.jsp");
}

    /**
     * Método auxiliar para asignar notas con validación
     */
    private void asignarNota(Nota nota, String tipoNota, String valorStr) throws IllegalArgumentException {
        if (valorStr != null && !valorStr.trim().isEmpty()) {
            try {
                BigDecimal valor = new BigDecimal(valorStr.trim());
                if (validarNota(valor)) {
                    switch (tipoNota) {
                        case "nota1":
                            nota.setNota1(valor);
                            break;
                        case "nota2":
                            nota.setNota2(valor);
                            break;
                        case "nota3":
                            nota.setNota3(valor);
                            break;
                        case "examen_parcial":
                            nota.setExamen_parcial(valor);
                            break;
                        case "examen_final":
                            nota.setExamen_final(valor);
                            break;
                    }
                } else {
                    throw new IllegalArgumentException(tipoNota + " debe estar entre 0 y 20");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Formato inválido para " + tipoNota);
            }
        }
    }

    /**
     * Valida que los datos básicos estén completos (solo para editar)
     */
    private boolean datosBasicosCompletos(String inscripcion) {
        return inscripcion != null && !inscripcion.trim().isEmpty();
    }

    /**
     * Valida que los datos básicos estén completos para nuevo registro
     */
    private boolean datosBasicosCompletos(String inscripcion, String nota1, String nota2, String notaFinal, String estado) {
        return inscripcion != null && !inscripcion.trim().isEmpty() &&
               nota1 != null && !nota1.trim().isEmpty() &&
               nota2 != null && !nota2.trim().isEmpty() &&
               notaFinal != null && !notaFinal.trim().isEmpty() &&
               estado != null && !estado.trim().isEmpty();
    }

    /**
     * Valida que una nota esté en el rango válido (0-20) usando BigDecimal
     */
    private boolean validarNota(BigDecimal nota) {
        if (nota == null) return false;
        BigDecimal min = BigDecimal.ZERO;
        BigDecimal max = new BigDecimal("20");
        return nota.compareTo(min) >= 0 && nota.compareTo(max) <= 0;
    }

    /**
     * Valida que el estado sea uno de los valores permitidos
     */
    private boolean validarEstado(String estado) {
        return estado != null && (estado.equals("aprobado") || estado.equals("desaprobado") || estado.equals("pendiente"));
    }

    @Override
    public String getServletInfo() {
        return "Controlador para la gestión de Notas";
    }
}