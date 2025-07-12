<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Formulario de Postulación</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .form-container { max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ccc; border-radius: 5px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input, select { width: 100%; padding: 8px; }
        button { padding: 10px 20px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        button:hover { background-color: #45a049; }
    </style>
</head>
<body>
<div class="form-container">
    <h2>Formulario de Postulación</h2>
    <form action="postulacion" method="post">
        <div class="form-group">
            <label for="nombreCompleto">Nombre Completo:</label>
            <input type="text" id="nombreCompleto" name="nombreCompleto" required>
        </div>
        <div class="form-group">
            <label for="dni">DNI:</label>
            <input type="text" id="dni" name="dni" pattern="[0-9]{8}" required>
        </div>
        <div class="form-group">
            <label for="fechaNacimiento">Fecha de Nacimiento:</label>
            <input type="date" id="fechaNacimiento" name="fechaNacimiento" required>
        </div>
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="telefono">Teléfono:</label>
            <input type="text" id="telefono" name="telefono" required>
        </div>
        <div class="form-group">
            <label for="direccion">Dirección:</label>
            <input type="text" id="direccion" name="direccion" required>
        </div>
        <div class="form-group">
            <label for="carreraInteresId">Carrera de Interés:</label>
            <select id="carreraInteresId" name="carreraInteresId" required>
                <option value="1">Ingeniería de Sistemas</option>
                <option value="2">Ingeniería Civil</option>
                <option value="3">Medicina</option>
                <option value="4">Derecho</option>
                <option value="5">Administración</option>
                <option value="6">Psicología</option>
                <option value="7">Arquitectura</option>
                <option value="8">Economía</option>
                <option value="9">Contabilidad</option>
                <option value="10">Ingeniería Industrial</option>
            </select>
        </div>
        <div class="form-group">
            <label for="documentosAdjuntosUrl">URL Documentos Adjuntos:</label>
            <input type="url" id="documentosAdjuntosUrl" name="documentosAdjuntosUrl">
        </div>
        <button type="submit">Enviar Postulación</button>
    </form>
</div>
</body>
</html>

