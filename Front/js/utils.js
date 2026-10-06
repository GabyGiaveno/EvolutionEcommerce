
export const API_BASE_URL = 'https://localhost:7088/api';
export const PAGE_SIZE = 20;
export const CART_KEY = 'evolutionCart';

/**
 * Formatea un número a moneda local 
 * @param {number} amount
 * @returns {string}
 */
export function formatCurrency(amount) {
    const numericValue = Number(amount ?? 0);
    if (!Number.isFinite(numericValue) || numericValue <= 0) {
        return 'Gratis';
    }
    return numericValue.toLocaleString('es-AR', {
        style: 'currency',
        currency: 'ARS' 
    });
}

/**
 * Muestra u oculta el modal de detalles del admin.
 * @param {boolean} show 
 */
export function toggleModal(show) {
    const modal = document.getElementById("detalle-modal");
    const modalContent = document.getElementById("modal-content");
    if (!modal || !modalContent) return;

    if (show) {
        modal.classList.remove("hidden");
        setTimeout(() => {
            modalContent.classList.remove("opacity-0", "scale-95");
            modalContent.classList.add("opacity-100", "scale-100");
        }, 10);
    } else {
        modalContent.classList.add("opacity-0", "scale-95");
        modalContent.classList.remove("opacity-100", "scale-100");
        setTimeout(() => {
            modal.classList.add("hidden");
        }, 200);
    }
}

    /**
 * @returns {Array}
 */
export function getCart() {
    const cart = localStorage.getItem(CART_KEY);
    return cart ? JSON.parse(cart) : [];
}

/**
 * @param {Array} cart 
 */
export function saveCart(cart) {
    localStorage.setItem(CART_KEY, JSON.stringify(cart));
    
}

/**
 * @param {object} item 
 */
export function addToCart(item) {
    const cart = getCart();
    //evitar duplicados
    const existingItem = cart.find(i => i.id === item.id);
    if (existingItem) {
        Swal.fire({
        icon: 'warning',
        title: 'Producto ya Añadido',
        text: `${item.nombre} ya está en el carrito.`,
        background: '#1f2937', 
        color: '#e5e7eb',     
        confirmButtonColor: '#3b82f6' 
    });
        return;
    }

    cart.push(item);
    saveCart(cart);
    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: 'success',
        title: '¡Añadido al carrito!',
        text: item.nombre, 
        showConfirmButton: false,
        timer: 2500, 
        timerProgressBar: true,
        background: '#1f2937', 
        color: '#e5e7eb',      
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer);
            toast.addEventListener('mouseleave', Swal.resumeTimer);
        }
});
    

}
/**
 * @param {string} url 
 * @param {object} options Opciones de fetch 
 * @returns {Promise<Response>} respuesta del fetch
 */
export async function fetchConAuth(url, options = {}) {
    // obtener token de localStorage
    const token = localStorage.getItem('authToken');

    // crear headers iniciales
    const headers = new Headers(options.headers || {});
    if (!headers.has('Content-Type') && options.body) {
        headers.set('Content-Type', 'application/json');
    }
    //Si existe un token lo a;ade al header Authorization
    if (token) {
        headers.set('Authorization', `Bearer ${token}`);
    }
    // Unir headers con opciones
    const config = {
        ...options,
        headers: headers
    };

    // 5. Hacemos el fetch
    const response = await fetch(`${API_BASE_URL}${url}`, config);
    // si llega 401 limpiamos el storage y redirigimos al login.
    if (response.status === 401) {
        localStorage.removeItem('authToken');
        localStorage.removeItem('usuarioNombre');
        localStorage.removeItem('usuarioRol');
        window.location.href = 'SigIn.html'; 
    }

    return response;
}
export function actualizarNavbar() {
    const token = localStorage.getItem('authToken');
    const userRole = localStorage.getItem('usuarioRol');
    const nombreUsuario = localStorage.getItem('usuarioNombre');

    // buscar link por href
    const loginLink = document.querySelector('nav a[href="SigIn.html"]');
    const perfilLink = document.querySelector('nav a[href="usuario.html"]');
    const adminPanelLink = document.querySelector('nav a[href="admin.html"]');
    let logoutLink = document.querySelector('nav a#logout-link'); 

    if (token) {
        //sesion iniciada
        if (loginLink) loginLink.classList.add('hidden');
        
        if (perfilLink) perfilLink.classList.remove('hidden');

        if (adminPanelLink) {
            if (userRole === 'Admin') {
                adminPanelLink.classList.remove('hidden');
            } else {
                adminPanelLink.classList.add('hidden');
            }
        }
        if (!logoutLink && perfilLink) {
            logoutLink = document.createElement('a');
            logoutLink.id = 'logout-link';
            logoutLink.href = '#';
            logoutLink.textContent = 'Cerrar Sesión';
            logoutLink.className = 'text-lg text-gray-300 hover:text-blue-400 transition-colors';
            perfilLink.parentNode.insertBefore(logoutLink, perfilLink.nextSibling);
        }

if (logoutLink) {
    logoutLink.classList.remove('hidden'); 
    logoutLink.addEventListener('click', (e) => {
        e.preventDefault();
        
        Swal.fire({
            title: '¿Cerrar Sesión?',
            text: "¿Estás seguro de que quieres salir?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3b82f6', // blue-600
            cancelButtonColor: '#d33',
            confirmButtonText: 'Sí, cerrar sesión',
            cancelButtonText: 'Cancelar',
            background: '#1f2937',
            color: '#e5e7eb'
        }).then((result) => {
            // Si el usuario hace clic en "Sí, cerrar sesión"
            if (result.isConfirmed) {
                localStorage.removeItem('authToken');
                localStorage.removeItem('usuarioNombre');
                localStorage.removeItem('usuarioRol');
                window.location.href = 'SigIn.html';
            }
        });
    });
        }

    } else {
        // --- USUARIO SIN SESIÓN (INVITADO) ---

        // Mostramos "Login"
        if (loginLink) loginLink.classList.remove('hidden');
        
        // Ocultamos "Perfil"
        if (perfilLink) perfilLink.classList.add('hidden');
        
        // Ocultamos "Panel de Admin"
        if (adminPanelLink) adminPanelLink.classList.add('hidden');

        // Ocultamos "Cerrar Sesión" si existe
        if (logoutLink) logoutLink.classList.add('hidden');
    }
}
