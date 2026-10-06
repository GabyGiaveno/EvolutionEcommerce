
import { API_BASE_URL, PAGE_SIZE, formatCurrency, actualizarNavbar } from './utils.js';
//ESTADO GLOBAL
const estadoPagina = {
    currentPage: 1,
    filtros: {
        idGenero: null,
        idEtiqueta: null,
        idPublisher: null,
        nombre: null 
    }
};
export function initIndexPage() {
    actualizarNavbar();
    const paginacionContainer = document.getElementById('paginacion');
    if (paginacionContainer) {
        paginacionContainer.addEventListener('click', handlePaginacionClick);
    }
    document.getElementById('filter-container-generos')?.addEventListener('change', handleFiltroChange);
    document.getElementById('filter-container-etiquetas')?.addEventListener('change', handleFiltroChange);
    document.getElementById('filter-container-publishers')?.addEventListener('change', handleFiltroChange);
    const searchBar = document.getElementById('search-bar');
    if (searchBar) {
        searchBar.addEventListener('keyup', handleBusquedaKeyup);
    }

    cargarFiltros().then(() => {
        fetchJuegos(1);
    });
}
function handleFiltroChange(e) {
    const input = e.target;
    const tipoFiltro = input.name; 
    estadoPagina.filtros[tipoFiltro] = input.value || null;
    fetchJuegos(1);
}
function handleBusquedaKeyup(e) {
    if (e.key !== 'Enter') {
        return;
    }
    const searchTerm = e.target.value.trim();
    estadoPagina.filtros.nombre = searchTerm || null;
    fetchJuegos(1);
}

async function fetchJuegos(pageNumber) {
    estadoPagina.currentPage = pageNumber;
    const juegosListContainer = document.getElementById('product-list-juegos');
    const paginacionContainer = document.getElementById('paginacion');
    juegosListContainer.innerHTML = '<p class="text-gray-400 col-span-full text-center">Cargando juegos...</p>';
    //parametros
    const params = new URLSearchParams({
        PageNumber: pageNumber,
        PageSize: PAGE_SIZE
    });
    if (estadoPagina.filtros.idGenero) {
        params.append('IdGenero', estadoPagina.filtros.idGenero);
    }
    if (estadoPagina.filtros.idEtiqueta) {
        params.append('IdEtiqueta', estadoPagina.filtros.idEtiqueta);
    }
    if (estadoPagina.filtros.idPublisher) {
        params.append('IdPublisher', estadoPagina.filtros.idPublisher);
    }
    if (estadoPagina.filtros.nombre) {
        params.append('Nombre', estadoPagina.filtros.nombre); // <--- OK
    }
    const url = `${API_BASE_URL}/Juegos/Paginados?${params.toString()}`;
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);
        const data = await response.json();
        renderJuegos(data.items);
        
        renderPaginacion(data); 

    } catch (error) {
        juegosListContainer.innerHTML = '<p class="text-red-400 col-span-full text-center">Error al cargar juegos.</p>';
        paginacionContainer.innerHTML = '';
    }
}
function renderJuegos(juegos) {
    const juegosListContainer = document.getElementById('product-list-juegos');
    juegosListContainer.innerHTML = '';

    if (!Array.isArray(juegos) || juegos.length === 0) {
        juegosListContainer.innerHTML = '<p class="text-gray-400 col-span-full text-center">No se encontraron juegos con esos filtros.</p>';
        return;
    }

    juegos.forEach(juego => {
        const generos = Array.isArray(juego.generos) ? juego.generos : [];
        const generosTexto = generos.slice(0, 2).join(', ');
        const precioFormateado = formatCurrency(juego.precioActual);
        const imagenSrc = (juego.imagenUrl && `${juego.imagenUrl}`.trim() !== '')
            ? juego.imagenUrl
            : `https://via.placeholder.com/400x300.png?text=${encodeURIComponent(juego.nombre || 'Juego')}`;
        const cardHtml = `
                <a href="./juego-detalle.html?id=${juego.idJuego}" 
                class="block bg-gray-800 rounded-xl overflow-hidden shadow-2xl transition-all duration-300 hover:-translate-y-1 hover:shadow-blue-500/30 hover:shadow-xl">
                <img class="w-full h-64 object-cover" 
                    src="${imagenSrc}" 
                    alt="Imagen de ${juego.nombre || 'Juego'}">
                <div class="p-4">
                    <h3 class="text-lg font-bold truncate text-white" title="${juego.nombre || ''}">
                        ${juego.nombre || ''}
                    </h3>
                    <div class="text-sm text-gray-400 h-5 my-1">
                        ${generosTexto || '&nbsp;'}
                    </div>
                    <div class="flex justify-between items-center pt-2 mt-2 border-t border-gray-600">
                        <span class="text-sm font-bold text-gray-400">${juego.clasificacionPegi || ''}</span>
                        <span class="text-xl font-bold text-blue-400">${precioFormateado}</span>
                    </div>
                </div>
            </a>`;
        juegosListContainer.insertAdjacentHTML('beforeend', cardHtml);
    });
}
function renderPaginacion(pagedData) {
    const paginacionContainer = document.getElementById('paginacion');
    paginacionContainer.innerHTML = '';
    let html = '';

    const { pageNumber, totalPages, hasPreviousPage, hasNextPage } = pagedData;

    const prevDisabled = !hasPreviousPage ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600';
    html += `<button data-page="${pageNumber - 1}" class="pagination-button px-4 py-2 rounded-lg ${prevDisabled}" ${!hasPreviousPage ? 'disabled' : ''}>&laquo; Anterior</button>`;

    for (let i = 1; i <= totalPages; i++) {
        html += `<button data-page="${i}" class="pagination-button px-4 py-2 rounded-lg ${i === pageNumber ? 'bg-blue-600 text-white font-bold cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600'}" ${i === pageNumber ? 'disabled' : ''}>${i}</button>`;
    }

    const nextDisabled = !hasNextPage ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600';
    html += `<button data-page="${pageNumber + 1}" class="pagination-button px-4 py-2 rounded-lg ${nextDisabled}" ${!hasNextPage ? 'disabled' : ''}>Siguiente &raquo;</button>`;

    paginacionContainer.innerHTML = html;
}
function handlePaginacionClick(e) {
    const juegosListContainer = document.getElementById('product-list-juegos');
    const targetButton = e.target.closest('.pagination-button');

    if (targetButton && !targetButton.disabled) {
        const page = parseInt(targetButton.dataset.page, 10);
        fetchJuegos(page);
        juegosListContainer.scrollIntoView({ behavior: 'smooth' });
    }
}

async function cargarFiltros() {
    await Promise.all([
        popularFiltrosRadio("filter-container-generos", `${API_BASE_URL}/Generos`, "idGenero", "nombre"),
        popularFiltrosRadio("filter-container-etiquetas", `${API_BASE_URL}/Etiquetas`, "idEtiqueta", "nombre"),
        popularFiltrosRadio("filter-container-publishers", `${API_BASE_URL}/Publishers`, "idPublisher", "nombre")
    ]);
}


async function popularFiltrosRadio(containerId, url, idField, nameField) {
    const container = document.getElementById(containerId);
    if (!container) return;
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`Error al cargar ${url}: ${response.statusText}`);
        }
        const data = await response.json();
        container.innerHTML = ''; 
        const labelTodos = document.createElement("label");
        labelTodos.className = "block cursor-pointer hover:text-white";
        labelTodos.innerHTML = `
            <input type="radio" name="${idField}" value="" class="mr-2 accent-blue-500" checked>
            Todos
        `;
        container.appendChild(labelTodos);
        data.forEach(item => {
            const label = document.createElement("label");
            label.className = "block cursor-pointer hover:text-white";
            const radio = document.createElement("input");
            radio.type = "radio";
            radio.className = "mr-2 accent-blue-500";
            radio.value = item[idField];
            radio.name = idField; 
            
            label.appendChild(radio);
            label.appendChild(document.createTextNode(` ${item[nameField]}`));
            container.appendChild(label);
        });
    } catch (error) {
        container.innerHTML = '<label class="text-red-400">Error al cargar filtros.</label>';
    }
}
