
import { API_BASE_URL, formatCurrency, addToCart,actualizarNavbar } from './utils.js';


export function initJuegoDetallePage() {
    actualizarNavbar();
    const idJuego = leerIdJuegoDeUrl();
    if (!idJuego) {
        mostrarError("No se especificó un ID de juego.");
        return;
    }
    fetchYRenderJuegoDetalle(idJuego);
}

function leerIdJuegoDeUrl() {
    const params = new URLSearchParams(window.location.search);
    return params.get('id'); // Devuelve el valor del parámetro 'id'
}


async function fetchYRenderJuegoDetalle(id) {
    const container = document.getElementById("juego-detalle-container");
    
    try {
        const response = await fetch(`${API_BASE_URL}/Juegos/${id}`);
        if (!response.ok) {
            throw new Error(`Juego no encontrado (ID: ${id})`);
        }
        const juego = await response.json();
        renderJuegoBase(container, juego);
        renderDlcs(container, juego.dlcs);

        container.addEventListener('click', (e) => {
            const button = e.target.closest('.btn-add-to-cart');
            if (!button || button.disabled) return;

            e.preventDefault();

            const productId = Number(button.dataset.idProducto);
            if (!Number.isInteger(productId) || productId <= 0) {
            Swal.fire({
                icon: 'warning',
                title: 'Producto No Disponible',
                text: 'Este producto no está disponible para la compra en este momento.',
                background: '#1f2937', 
                color: '#e5e7eb',      
                confirmButtonColor: '#3b82f6' 
            });
                return;
            }

            const item = {
                id: productId,
                nombre: button.dataset.nombre,
                precio: parseFloat(button.dataset.precio)
            };

            addToCart(item);
        });
    } catch (error) {
        mostrarError(error.message);
    }
}


function renderJuegoBase(container, juego) {
    container.innerHTML = "";
    const precioJuego = formatCurrency(juego.precioActual);
    const generosHtml = juego.generos.map(g => `<span class="bg-gray-700 px-3 py-1 rounded-full text-sm">${g}</span>`).join(' ');
    const etiquetasHtml = juego.etiquetas.map(e => `<span class="bg-gray-600 px-3 py-1 rounded-full text-sm">${e}</span>`).join(' ');
    const puedeComprar = Number.isInteger(juego.idProducto) && juego.idProducto > 0;
    
    const portadaPrincipal = (juego.portadaUrl || '').trim();
    const imagenAlternativa = (juego.imagenUrl || '').trim();
    const imagenSrc = portadaPrincipal || imagenAlternativa
        || `https://via.placeholder.com/1280x720.png?text=${encodeURIComponent(juego.nombre || 'Juego')}`;

    const botonCompra = puedeComprar
        ? `<button class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition duration-300 text-lg btn-add-to-cart"
                        data-id-producto="${juego.idProducto}" 
                        data-nombre="${juego.nombre}" 
                        data-precio="${juego.precioActual}">
                        Agregar al Carrito
            </button>`
        : `<button class="bg-gray-600 text-white font-bold py-3 px-6 rounded-lg text-lg opacity-50 cursor-not-allowed"
                        title="Producto no disponible por el momento" disabled>
                        No disponible
            </button>`;

    const juegoHtml = `
        <div class="bg-gray-800 rounded-xl shadow-2xl overflow-hidden mb-8">
            <img class="w-full h-96 object-cover" src="${imagenSrc}" alt="Portada de ${juego.nombre}">
            
            <div class="p-8">
                <div class="flex flex-col md:flex-row justify-between md:items-center mb-6">
                    <h1 class="text-4xl font-bold text-white mb-2 md:mb-0">${juego.nombre}</h1>
                    <div class="flex items-center space-x-4">
                        <span class="text-4xl font-bold text-blue-400">${juego.precioActual === 0 ? 'Gratis' : `${precioJuego}`}</span>
                        ${botonCompra}
                    </div>
                </div>

                <p class="text-gray-300 text-lg mb-6">
                    ${juego.descripcion || "Este juego aún no tiene una descripción."}
                </p>

                <div class="mb-4">
                    <h3 class="text-lg font-semibold text-blue-300 mb-2">Géneros</h3>
                    <div class="flex flex-wrap gap-2">
                        ${generosHtml || 'N/A'}
                    </div>
                </div>

                <div>
                    <h3 class="text-lg font-semibold text-blue-300 mb-2">Etiquetas</h3>
                    <div class="flex flex-wrap gap-2">
                        ${etiquetasHtml || 'N/A'}
                    </div>
                </div>
            </div>
        </div>
    `;
    container.insertAdjacentHTML('beforeend', juegoHtml);
}


function renderDlcs(container, dlcs) {
    if (!dlcs || dlcs.length === 0) {
        return; // No renderizar nada si no hay DLCs
    }

    let dlcCardsHtml = "";
    dlcs.forEach(dlc => {
        const precioDlc = formatCurrency(dlc.precioActual);
        const puedeComprar = Number.isInteger(dlc.idProducto) && dlc.idProducto > 0;
        const botonCompra = puedeComprar
            ? `<button class="mt-1 bg-blue-600 hover:bg-blue-700 text-white text-sm py-1 px-3 rounded btn-add-to-cart"
                            data-id-producto="${dlc.idProducto}"
                            data-nombre="${dlc.nombre}"
                            
                            data-precio="${dlc.precioActual}">
                            Agregar al Carrito
                    </button>`
            : `<button class="mt-1 bg-gray-600 text-white text-sm py-1 px-3 rounded opacity-50 cursor-not-allowed" disabled
                            title="Producto no disponible">
                            No disponible
                    </button>`;

        dlcCardsHtml += `
            <div class="bg-gray-700 p-4 rounded-lg flex justify-between items-center">
                <div>
                    <h4 class="text-xl font-semibold text-white">${dlc.nombre}</h4>
                    <p class="text-gray-400">${dlc.descripcion || ''}</p>
                </div>
                <div class="text-right flex-shrink-0 ml-4">
                    <span class="text-xl font-bold text-blue-300 block">${precioDlc}</span>
                    ${botonCompra}
                </div>
            </div>
        `;
    });

    const dlcSectionHtml = `
        <div class="bg-gray-800 rounded-xl shadow-2xl p-8">
            <h2 class="text-3xl font-bold text-white mb-6">Contenido Descargable</h2>
            <div class="space-y-4">
                ${dlcCardsHtml}
            </div>
        </div>
    `;
    container.insertAdjacentHTML('beforeend', dlcSectionHtml);
}
function mostrarError(mensaje) {
    const container = document.getElementById("juego-detalle-container");
    container.innerHTML = `<p class="text-center text-2xl text-red-400 mt-20">${mensaje}</p>`;
}
