
import { API_BASE_URL } from './utils.js';

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('login-form');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const errorMessageDiv = document.getElementById('error-message');
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault(); 
        errorMessageDiv.classList.add('hidden');
        errorMessageDiv.textContent = '';

        // Obtenemos los valores
        const email = emailInput.value;
        const password = passwordInput.value;

        //body de peticion
        const loginData = {
            email: email,
            password: password
        };

        try {
            //fetch a ruta
            const response = await fetch(`${API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(loginData)
            });

            if (response.ok) {
                const data = await response.json(); 
                // guardar token en localStorage
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('usuarioNombre', data.nombreUsuario); 
                localStorage.setItem('usuarioRol', data.rol);
                localStorage.setItem('usuarioId', data.idUsuario);
                
                // redirije al index
                window.location.href = 'index.html'; 

            } else {
                
                const errorTexto = await response.text();
                throw new Error(errorTexto || 'Usuario o contraseña incorrectos');
            }

        } catch (error) {
            //catchear error en el div
        Swal.fire({
            icon: 'error',
            title: 'Error al Iniciar Sesión',
            text: error.message, 
            background: '#1f2937', 
            color: '#e5e7eb',     
            confirmButtonColor: '#3b82f6' 
        });
        }
    });
});
