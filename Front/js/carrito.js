import { getCart, saveCart, formatCurrency,fetchConAuth,actualizarNavbar } from './utils.js';

export function initCarritoPage() {
    actualizarNavbar();
    // Anadir listener al contenedor principal para delegar clics
    document.getElementById('cart-items-container').addEventListener('click', handleRemoveItem);
    // Listeners para botones de resumen 
    document.getElementById('cart-summary').addEventListener('click', handleSummaryClick);
    renderCart();
}

function renderCart() {
    const cart = getCart();
    const container = document.getElementById('cart-items-container');
    const summaryContainer = document.getElementById('cart-summary');
    const emptyMsg = document.getElementById('cart-empty-msg');
    
    container.innerHTML = '';
    summaryContainer.innerHTML = '';

    if (cart.length === 0) {
        emptyMsg.classList.remove('hidden');
        summaryContainer.classList.add('hidden');
        return;
    }

    emptyMsg.classList.add('hidden');
    summaryContainer.classList.remove('hidden');

    let total = 0;

    cart.forEach(item => {
        total += item.precio;
        container.innerHTML += `
            <div class="flex justify-between items-center bg-gray-700 p-4 rounded-lg">
                <div>
                    <h4 class="text-xl font-semibold text-white">${item.nombre}</h4>
                    <p class="text-blue-300">${formatCurrency(item.precio)}</p>
                </div>
                <button class="btn-remove-item text-red-400 hover:text-red-300 font-bold" data-id="${item.id}">
                    Eliminar
                </button>
            </div>
        `;
    });

    // Renderizar resumen
    summaryContainer.innerHTML = `
        <div class="border-t border-gray-700 pt-6 mt-6">
            <div class="flex justify-between items-center mb-4">
                <span class="text-2xl font-bold text-white">TOTAL</span>
                <span class="text-3xl font-bold text-blue-300">${formatCurrency(total)}</span>
            </div>
            <div class="flex justify-end gap-4">
                <button id="btn-clear-cart" class="bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-5 rounded-lg transition">
                    Vaciar Carrito
                </button>
                <button id="btn-buy" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-5 rounded-lg transition">
                    Comprar
                </button>
            </div>
        </div>
    `;
}

function handleRemoveItem(e) {
    if (!e.target.classList.contains('btn-remove-item')) return;

    const itemId = e.target.dataset.id;
    const itemNombre = e.target.dataset.nombre;
Swal.fire({
        title: '¿Eliminar del Carrito?',
        text: `¿Seguro que quieres eliminar "${itemNombre}"?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3b82f6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar',
        background: '#1f2937',
        color: '#e5e7eb'
    }).then((result) => {
        if (result.isConfirmed) {
            let cart = getCart();
            cart = cart.filter(item => String(item.id) !== itemId);
            saveCart(cart);
            renderCart(); // Re renderiza todo
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: 'success',
                title: 'Eliminado',
                showConfirmButton: false,
                timer: 1500,
                background: '#1f2937',
                color: '#e5e7eb',
                timerProgressBar: true
            });
        }
    });
}

async function handleSummaryClick(e) { 
    if (e.target.id === 'btn-clear-cart') {
        Swal.fire({
                title: '¿Vaciar Carrito?',
                text: "Se eliminarán todos los productos de tu carrito.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3b82f6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Sí, vaciar',
                cancelButtonText: 'Cancelar',
                background: '#1f2937',
                color: '#e5e7eb'
            }).then((result) => {
                if (result.isConfirmed) {
                    saveCart([]);
                    renderCart();
                }
            });
    }

    if (e.target.id === 'btn-buy') {
        const cart = getCart();
        if (cart.length === 0) {
            Swal.fire({
                icon: 'error',
                title: 'Carrito Vacío',
                text: 'No puedes comprar un carrito vacío.',
                background: '#1f2937',
                color: '#e5e7eb',
                confirmButtonColor: '#3b82f6'
            });
            return;
        }

        const idsProductos = cart.map(item => extractProductId(item.id));
        const idsInvalidos = idsProductos.filter(id => !Number.isInteger(id) || id <= 0);
        if (idsInvalidos.length > 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error en el Carrito',
                text: 'No pudimos determinar los productos a comprar. Por favor vuelve a agregarlos al carrito.',
                background: '#1f2937', 
                color: '#e5e7eb',    
                confirmButtonColor: '#3b82f6' 
            });
            return;
        }

        const usuarioId = localStorage.getItem('usuarioId');
        const usuarioIdNumero = Number.parseInt(usuarioId ?? '', 10);
        if (!usuarioId || Number.isNaN(usuarioIdNumero)) {
            Swal.fire({
                icon: 'warning',
                title: 'Sesión requerida',
                text: 'Debes iniciar sesión para completar la compra.',
                background: '#1f2937',
                color: '#e5e7eb',
                confirmButtonColor: '#3b82f6'
            });
            return;
        }

        const transaccionDto = { 
            idsProductos,
            idUsuario: usuarioIdNumero
        };
        Swal.fire({
            title: 'Procesando tu compra...',
            text: 'Por favor espera.',
            background: '#1f2937',
            color: '#e5e7eb',
            allowOutsideClick: false,
            didOpen: () => {
                Swal.showLoading();
            }
        });

        try {
            const response = await fetchConAuth(`/Transacciones`, {
                method: 'POST',

                body: JSON.stringify(transaccionDto)
            });

            if (!response.ok) {
                const errorMessage = await getErrorMessage(response);
                throw new Error(errorMessage || response.statusText);
            }

            const nuevaTransaccion = await response.json();
            Swal.fire({
                icon: 'success',
                title: '¡Compra Exitosa!',
                text: 'Gracias por tu compra. Serás redirigido a la tienda.',
                timer: 3000,
                timerProgressBar: true,
                background: '#1f2937',
                color: '#e5e7eb',
                confirmButtonColor: '#3b82f6'
            }).then(() => {
                saveCart([]); // Vacía el carrito
                window.location.href = 'index.html'; // Redirige a la tienda
            });
        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: 'Error en la Compra',
                text: error.message,
                background: '#1f2937',
                color: '#e5e7eb',
                confirmButtonColor: '#3b82f6'
            });
        } finally {
            buyButton.disabled = false;
            buyButton.textContent = 'Comprar';
        }
    }
}
function extractProductId(rawId) {
    if (typeof rawId === 'number' && Number.isFinite(rawId)) {
        return Math.trunc(rawId);
    }
    if (rawId === null || rawId === undefined) {
        return NaN;
    }
    const matches = String(rawId).match(/\d+/g);
    if (!matches || matches.length === 0) {
        return NaN;
    }
    return Number.parseInt(matches[matches.length - 1], 10);
}

async function getErrorMessage(response) {
    try {
        const text = await response.text();
        if (!text) return response.statusText;
        try {
            const data = JSON.parse(text);
            return data.message || data.error || data.title || text;
        } catch {
            return text;
        }
    } catch {
        return response.statusText;
    }
}


