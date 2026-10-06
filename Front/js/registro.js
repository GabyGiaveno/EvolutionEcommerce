import { API_BASE_URL } from './utils.js';

document.addEventListener('DOMContentLoaded', () => {
    
    // elementos del dom
    const registerForm = document.getElementById('register-form');
    const nombreInput = document.getElementById('nombre');
    const apellidoInput = document.getElementById('apellido');
    const nombreUsuarioInput = document.getElementById('nombreUsuario');
    const emailInput = document.getElementById('email');
    const fechaNacimientoInput = document.getElementById('fechaNacimiento');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    
    const errorMessageDiv = document.getElementById('error-message');
    const successMessageDiv = document.getElementById('success-message');

    // fecha maxima permitida (hoy - 18 anios) para el datepicker
    const maxFechaNacimiento = calcularFechaMaxima();
    fechaNacimientoInput.max = maxFechaNacimiento;

    registerForm.addEventListener('submit', async (e) => {
        e.preventDefault(); 
        errorMessageDiv.classList.add('hidden');
        successMessageDiv.classList.add('hidden');

        // get valores
        const password = passwordInput.value;
        const confirmPassword = confirmPasswordInput.value;
        const fechaNacimiento = fechaNacimientoInput.value;

        //validar contraseñas
        if (password !== confirmPassword) {
            errorMessageDiv.textContent = 'Las contraseñas no coinciden.';
            errorMessageDiv.classList.remove('hidden');
            return;
        }

        if (!esMayorDeEdad(fechaNacimiento)) {
            errorMessageDiv.textContent = 'Debes tener al menos 18 años para registrarte.';
            errorMessageDiv.classList.remove('hidden');
            return;
        }

        // crear  DTO
        const registerDto = {
            nombre: nombreInput.value,
            apellido: apellidoInput.value,
            nombreUsuario: nombreUsuarioInput.value,
            email: emailInput.value,
            fechaNacimiento: fechaNacimiento,
            password: password,
            rol: "Usuario" //asignamos usuario aca para q no se pueda registrar como admin
        };

        try {
            //fetch al endpoint de registro
            const response = await fetch(`${API_BASE_URL}/auth/register`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(registerDto)
            });

            //manejar res
            if (response.ok) {
                // devuelve datos y el token
                const data = await response.json(); // data = { token, email, nombreUsuario }

                // GUARDA EL TOKEN ROL Y USUARIO EN LOCALSTORAGE
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('usuarioNombre', data.nombreUsuario);
                localStorage.setItem('usuarioRol', data.rol);
                localStorage.setItem('usuarioId', data.idUsuario);

                //redirije a la tienda con mensaje de exito
                Swal.fire({
                        icon: 'success',
                        title: '¡Cuenta Creada!',
                        text: 'Iniciando sesión y redirigiendo a la tienda...',
                        timer: 2000, 
                        timerProgressBar: true,
                        showConfirmButton: false, // Ocultamos el botón "OK"
                        background: '#1f2937',
                        color: '#e5e7eb'
                    }).then(() => {
                        // Esto se ejecuta cuando el timer termina
                        window.location.href = 'index.html';
                    });

            } else {
                const errorTexto = await response.text();
                throw new Error(errorTexto || 'Error al crear la cuenta.');
            }

        } catch (error) {
            errorMessageDiv.textContent = error.message;
            errorMessageDiv.classList.remove('hidden');
        }
    });
});

function calcularFechaMaxima() {
    const hoy = new Date();
    const fechaMax = new Date(hoy.getFullYear() - 18, hoy.getMonth(), hoy.getDate());
    return fechaMax.toISOString().split('T')[0];
}

function esMayorDeEdad(valorFecha) {
    if (!valorFecha) return false;
    const fechaNacimiento = new Date(valorFecha);
    if (Number.isNaN(fechaNacimiento.getTime())) return false;

    const hoy = new Date();
    let edad = hoy.getFullYear() - fechaNacimiento.getFullYear();
    const mes = hoy.getMonth() - fechaNacimiento.getMonth();
    if (mes < 0 || (mes === 0 && hoy.getDate() < fechaNacimiento.getDate())) {
        edad--;
    }
    return edad >= 18;
}
