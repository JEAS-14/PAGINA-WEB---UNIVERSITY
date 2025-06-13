<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, pe.universidad.util.Conexion" %>
<%-- Se elimina la importación de Gson: , com.google.gson.Gson --%>

<%
    // Validar sesión
    String emailProfesorSesion = (String) session.getAttribute("email");
    String rolUsuario = (String) session.getAttribute("rol");
    Object idProfesorObj = session.getAttribute("id_profesor");
    int idProfesor = (idProfesorObj instanceof Integer) ? (Integer) idProfesorObj : -1;

    // Redirigir si el usuario no es profesor o el ID no es válido
    if (!"profesor".equals(rolUsuario) || idProfesor == -1) {
        response.sendRedirect(request.getContextPath() + "/INTERFAZ_PROFESOR/login.jsp"); // Ajusta esta ruta si es diferente
        return;
    }

    String successMsg = null; // Mensaje de éxito o error de la solicitud
    
    // --- LÓGICA PARA PROCESAR ENVÍO POST DE LA SOLICITUD ---
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // Obtener parámetros del formulario
            String curso = request.getParameter("curso"); // Ahora es input type="text"
            String seccion = request.getParameter("seccion");
            String ciclo = request.getParameter("ciclo");
            String semestre = request.getParameter("semestre");
            int anio = Integer.parseInt(request.getParameter("anio"));
            String dia = request.getParameter("dia");
            String horaInicio = request.getParameter("hora_inicio");
            String horaFin = request.getParameter("hora_fin");
            String aula = request.getParameter("aula"); // Ahora es input type="text" o select estático
            int capacidad = Integer.parseInt(request.getParameter("capacidad")); // Ahora es editable por el profesor

            // Validaciones básicas de campos
            if (curso == null || curso.trim().isEmpty() || seccion == null || seccion.trim().isEmpty() ||
                ciclo == null || ciclo.trim().isEmpty() || semestre == null || semestre.trim().isEmpty() ||
                dia == null || dia.trim().isEmpty() || horaInicio == null || horaInicio.trim().isEmpty() ||
                horaFin == null || horaFin.trim().isEmpty() || aula == null || aula.trim().isEmpty()) {
                successMsg = "❌ Error: Por favor, completa todos los campos obligatorios.";
            } else if (anio < 1900 || anio > 2100) {
                successMsg = "❌ Error: Año académico inválido.";
            } else if (capacidad <= 0) {
                 successMsg = "❌ Error: La capacidad debe ser un número positivo.";
            } else {
                conn = new Conexion().conecta();
                if (conn == null || conn.isClosed()) {
                    throw new SQLException("Fallo al conectar con la base de datos.");
                }

                // Inserción en la tabla solicitudes_clases
                String sqlInsert = "INSERT INTO solicitudes_clases ("
                                 + "id_profesor, curso, seccion, ciclo, semestre, anio_academico, "
                                 + "dia_semana, hora_inicio, hora_fin, aula, capacidad, estado_solicitud) "
                                 + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                
                pstmt = conn.prepareStatement(sqlInsert);
                pstmt.setInt(1, idProfesor);
                pstmt.setString(2, curso);
                pstmt.setString(3, seccion);
                pstmt.setString(4, ciclo);
                pstmt.setString(5, semestre);
                pstmt.setInt(6, anio);
                pstmt.setString(7, dia);
                pstmt.setString(8, horaInicio);
                pstmt.setString(9, horaFin);
                pstmt.setString(10, aula);
                pstmt.setInt(11, capacidad);
                pstmt.setString(12, "pendiente"); // Estado inicial (en minúsculas según tu ENUM)

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    successMsg = "✅ Solicitud enviada correctamente. Espera la aprobación del administrador.";
                } else {
                    successMsg = "❌ No se pudo registrar la solicitud. Intenta de nuevo.";
                }
            }
        } catch (NumberFormatException e) {
            successMsg = "❌ Error en el formato de año o capacidad. Asegúrate de que sean números válidos.";
            e.printStackTrace();
        } catch (SQLException e) {
            successMsg = "❌ Error de base de datos al enviar la solicitud: " + e.getMessage();
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            successMsg = "❌ Error de configuración: Driver JDBC no encontrado.";
            e.printStackTrace();
        } finally {
            if (pstmt != null) { try { pstmt.close(); } catch (SQLException ignore) {} }
            if (conn != null) { try { conn.close(); } catch (SQLException ignore) {} }
        }
    }

    // --- Se elimina la lógica para cargar aulas y cursos para los dropdowns ---
    // porque eliminamos la dependencia de Gson y fetch.
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitar Clase - Sistema Universitario</title>
    <link rel="icon" type="image/x-icon" href="https://ejemplo.com/favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* CSS general para el diseño de tu sistema */
        :root {
            --primary-color: #002366; /* Azul universitario oscuro */
            --secondary-color: #FFD700; /* Dorado */
            --accent-color: #800000; /* Granate */
            --light-color: #F5F5F5;
            --dark-color: #333333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--light-color);
            color: var(--dark-color);
        }

        .header-main {
            background-color: var(--primary-color);
            color: white;
            padding: 1.5rem 2rem;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .header-main h1 {
            margin: 0;
            font-size: 2em;
            color: var(--secondary-color);
        }

        .form-container {
            max-width: 800px; /* Ancho un poco más amplio */
            margin: 30px auto;
            padding: 2rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-top: 5px solid var(--primary-color);
        }

        h2 {
            color: var(--primary-color);
            text-align: center;
            margin-bottom: 25px;
            font-size: 1.8em;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .form-row {
            display: flex;
            gap: 1.5rem; /* Espacio entre columnas */
            margin-bottom: 1rem;
        }

        .form-group {
            flex: 1; /* Distribuye el espacio equitativamente */
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: bold;
            color: var(--dark-color);
        }

        input[type="text"],
        input[type="number"],
        input[type="time"],
        select { /* select se mantiene por los dropdowns estáticos de día */
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 1rem;
            box-sizing: border-box; /* Incluye padding y border en el ancho total */
        }

        input:focus, select:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(0, 35, 102, 0.25);
        }

        .readonly {
            background-color: #e9ecef;
            cursor: not-allowed;
        }

        .button-group {
            text-align: center;
            margin-top: 2rem;
        }

        button[type="submit"] {
            background-color: var(--primary-color);
            color: white;
            padding: 1rem 2rem;
            border: none;
            border-radius: 5px;
            font-size: 1.1rem;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.2s ease;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        button[type="submit"]:hover {
            background-color: #003399;
            transform: translateY(-2px);
        }

        .back-button {
            display: inline-block;
            background-color: #6c757d; /* Gris para botón de volver */
            color: white;
            padding: 1rem 2rem;
            margin-left: 1rem;
            border-radius: 5px;
            text-decoration: none;
            transition: background-color 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .back-button:hover {
            background-color: #5a6268;
        }

        .message-box {
            margin-top: 1.5rem;
            padding: 1rem;
            border-radius: 8px;
            font-weight: bold;
            text-align: center;
        }

        .message-box.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message-box.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Responsividad */
        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            .form-group {
                margin-bottom: 1rem;
            }
            .button-group button, .back-button {
                width: 100%;
                margin: 0.5rem 0;
            }
        }
    </style>
    <script>
        // Se eliminan todas las funciones relacionadas con cargar datos dinámicamente o actualizar capacidad con JS
        // Se mantienen las validaciones del formulario básicas
        function validarFormulario() {
            const campos = ["curso", "seccion", "ciclo", "semestre", "anio", "dia", "hora_inicio", "hora_fin", "aula", "capacidad"];
            for (let i = 0; i < campos.length; i++) {
                const elemento = document.getElementById(campos[i]);
                if (!elemento || !elemento.value || elemento.value.trim() === "") {
                    alert("⚠️ Por favor, completa todos los campos del formulario.");
                    return false;
                }
            }
            const anio = document.getElementById("anio").value;
            if (!/^\d{4}$/.test(anio)) {
                alert("⚠️ El Año Académico debe ser un número de 4 dígitos.");
                return false;
            }
            const capacidad = parseInt(document.getElementById("capacidad").value);
            if (isNaN(capacidad) || capacidad <= 0) {
                alert("⚠️ La capacidad debe ser un número positivo.");
                return false;
            }

            return true;
        }
    </script>
</head>
<body>

    <div class="header-main">
        <h1>Solicitud de Nueva Clase</h1>
        <p>Envía una solicitud para añadir una nueva clase a tu horario.</p>
    </div>

    <div class="form-container">
        <h2><i class="fas fa-file-alt"></i> Formulario de Solicitud</h2>

        <% if (successMsg != null) { %>
            <div class="message-box <%= successMsg.startsWith("✅") ? "success" : "error" %>">
                <%= successMsg %>
            </div>
        <% } %>

        <form method="post" onsubmit="return validarFormulario();">
            <input type="hidden" name="id_profesor" value="<%= idProfesor %>">

            <div class="form-row">
                <div class="form-group">
                    <label for="curso">Curso</label>
                    <input type="text" name="curso" id="curso" required placeholder="Ej: Programación I">
                </div>
                <div class="form-group">
                    <label for="seccion">Sección</label>
                    <input type="text" name="seccion" id="seccion" required placeholder="Ej: A, B">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="ciclo">Ciclo</label>
                    <input type="text" name="ciclo" id="ciclo" required placeholder="Ej: I, II, 1, 2">
                </div>
                <div class="form-group">
                    <label for="semestre">Semestre</label>
                    <input type="text" name="semestre" id="semestre" placeholder="Ej. 2025-1, 2025-II" required>
                </div>
                <div class="form-group">
                    <label for="anio">Año Académico</label>
                    <input type="number" name="anio" id="anio" value="<%= java.time.Year.now().getValue() %>" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="dia">Día de la semana</label>
                    <select name="dia" id="dia" required>
                        <option value="">-- Seleccionar --</option>
                        <option value="lunes">Lunes</option>
                        <option value="martes">Martes</option>
                        <option value="miercoles">Miércoles</option>
                        <option value="jueves">Jueves</option>
                        <option value="viernes">Viernes</option>
                        <option value="sabado">Sábado</option>
                        <option value="domingo">Domingo</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="hora_inicio">Hora de inicio</label>
                    <input type="time" name="hora_inicio" id="hora_inicio" required>
                </div>
                <div class="form-group">
                    <label for="hora_fin">Hora de fin</label>
                    <input type="time" name="hora_fin" id="hora_fin" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="aula">Aula</label>
                    <input type="text" name="aula" id="aula" required placeholder="Ej: A101">
                </div>
                <div class="form-group">
                    <label for="capacidad">Capacidad del aula</label>
                    <input type="number" name="capacidad" id="capacidad" required placeholder="Ej: 30">
                </div>
            </div>

            <div class="button-group">
                <button type="submit">Enviar solicitud</button>
                <a href="salones_profesor.jsp" class="back-button">🔙 Volver a Mis Clases</a>
            </div>
        </form>
    </div>

</body>
</html>