import { API_BASE_URL, formatCurrency } from './utils.js';

function toggleModal(show) {
    const modal = document.getElementById("juego-modal");
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

let pegiOptionsHtml = '<option value="">Cargando...</option>';

const paginacionState = {
    currentPage: 1,
    pageSize: 12, 
};

document.addEventListener('DOMContentLoaded', initJuegoAdminPage);

function initJuegoAdminPage() {
    cargarJuegos(paginacionState.currentPage);
    loadMasterData();
    document.getElementById('btn-nuevo-juego').addEventListener('click', () => openGameModal()); 
    document.getElementById('product-list-juegos').addEventListener('click', (e) => {
        const editButton = e.target.closest('.btn-editar-juego');
        if (editButton) {
            const id = editButton.dataset.idJuego;
            openGameModal(id); 
        }
    });
    document.getElementById('juego-form').addEventListener('submit', handleFormSubmit);
    document.getElementById('modal-close-btn').addEventListener('click', () => toggleModal(false));
    document.getElementById('modal-btn-cancelar').addEventListener('click', () => toggleModal(false));
    document.getElementById('btn-add-dlc').addEventListener('click', () => addDlcRow()); 
    document.getElementById('btn-toggle-estado').addEventListener('click', handleToggleEstado);
    document.getElementById('paginacion').addEventListener('click', handlePaginacionClick);
}

async function cargarJuegos(page = 1) {
    paginacionState.currentPage = page;
    const productList = document.getElementById('product-list-juegos');
    productList.innerHTML = '<p class="text-center text-gray-300 col-span-full">Cargando juegos...</p>';
    const url = `${API_BASE_URL}/Juegos/paginados?PageNumber=${page}&PageSize=${paginacionState.pageSize}`;
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);
        const pagedData = await response.json();
        renderJuegosList(pagedData.items || []);
        renderPaginacionJuegos(pagedData);
    } catch (error) {
        productList.innerHTML = `<p class="text-center text-red-400 col-span-full">Error al cargar juegos. ${error.message}</p>`;
    }
}

function renderJuegosList(juegos) {
    const productList = document.getElementById('product-list-juegos');
    if (juegos.length === 0) {
        productList.innerHTML = '<p class="text-center text-gray-400 col-span-full">No se encontraron juegos.</p>';
        return;
    }
    productList.innerHTML = juegos.map(juego => {
        const imageUrl = juego.imagenUrl || 'https://via.placeholder.com/300x400.png?text=Sin+Imagen'; 
        const precio = formatCurrency(juego.precioActual);
        const generos = (juego.generos?.length > 0) ? juego.generos.join(', ') : 'Sin género';
        const estadoClass = juego.estado === 'Publicado' ? 'bg-green-600' : 'bg-red-600';
        const estadoTexto = juego.estado === 'Publicado' ? 'Publicado' : 'No Disponible';
        return `
            <div class="bg-gray-800 rounded-lg shadow-lg overflow-hidden transition-transform duration-300 hover:scale-105 relative">
                <span class="absolute top-2 right-2 text-xs font-bold px-2 py-0.5 rounded-full ${estadoClass} text-white">${estadoTexto}</span>
                <img src="${imageUrl}" alt="${juego.nombre}" class="w-full h-64 object-cover">
                <div class="p-4">
                    <h3 class="text-xl font-bold text-white mb-2 truncate">${juego.nombre}</h3>
                    <p class="text-sm text-gray-400 mb-3">${generos}</p>
                    <div class="flex justify-between items-center">
                        <span class="text-2xl font-bold text-blue-400">${precio}</span>
                        <button class="btn-editar-juego bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md transition" data-id-juego="${juego.idJuego}">
                            Editar
                        </button>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

function renderPaginacionJuegos(pagedData) {
    const paginacionContainer = document.getElementById('paginacion');
    const { page: currentPage, totalPages, hasPrevious, hasNext } = pagedData;
    if (totalPages <= 1) {
        paginacionContainer.innerHTML = '';
        return;
    }
    let html = '';
    html += `<button data-page="${currentPage - 1}" class="pagination-button px-4 py-2 rounded-lg ${!hasPrevious ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-600 text-gray-300 hover:bg-gray-500'}" ${!hasPrevious ? 'disabled' : ''}>&laquo; Anterior</button>`;
    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPages, currentPage + 2);
    if (startPage > 1) {
         html += `<button data-page="1" class="pagination-button px-4 py-2 rounded-lg bg-gray-600 text-gray-300 hover:bg-gray-500">1</button>`;
         if (startPage > 2) html += `<span class="px-4 py-2 text-gray-400">...</span>`;
    }
    for (let i = startPage; i <= endPage; i++) {
        const active = i === currentPage;
        html += `<button data-page="${i}" class="pagination-button px-4 py-2 rounded-lg ${active ? 'bg-blue-600 text-white font-bold cursor-not-allowed' : 'bg-gray-600 text-gray-300 hover:bg-gray-500'}" ${active ? 'disabled' : ''}>${i}</button>`;
    }
    if (endPage < totalPages) {
        if (endPage < totalPages - 1) html += `<span class="px-4 py-2 text-gray-400">...</span>`;
        html += `<button data-page="${totalPages}" class="pagination-button px-4 py-2 rounded-lg bg-gray-600 text-gray-300 hover:bg-gray-500">${totalPages}</button>`;
    }
    html += `<button data-page="${currentPage + 1}" class="pagination-button px-4 py-2 rounded-lg ${!hasNext ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-600 text-gray-300 hover:bg-gray-500'}" ${!hasNext ? 'disabled' : ''}>Siguiente &raquo;</button>`;
    paginacionContainer.innerHTML = html;
}

function handlePaginacionClick(e) {
    const targetButton = e.target.closest('.pagination-button');
    if (!targetButton || targetButton.disabled) return;
    const page = parseInt(targetButton.dataset.page, 10);
    if (isNaN(page)) return;
    cargarJuegos(page);
    document.getElementById('juegos').scrollIntoView({ behavior: 'smooth' });
}

async function loadMasterData() {
    await loadSelectOptions('pegi', `${API_BASE_URL}/Pegi`, true); 
    await loadCheckboxList('generos-list', `${API_BASE_URL}/Generos`, 'idGenero'); 
    await loadCheckboxList('publishers-list', `${API_BASE_URL}/Publishers`, 'idPublisher'); 
    await loadCheckboxList('etiquetas-list', `${API_BASE_URL}/Etiquetas`, 'idEtiqueta'); 
}

async function loadSelectOptions(selectId, url, storeGlobally = false) {
    const select = document.getElementById(selectId);
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('No se pudieron cargar los datos');
        const items = await response.json(); 
        
        let optionsHtml = '<option value="">Seleccione una opción</option>';
        items.forEach(item => {
            const id = item.idPegi || item.id;
            const text = item.descripcion || item.nombre;
            optionsHtml += `<option value="${id}">${text}</option>`;
        });

        select.innerHTML = optionsHtml;
        
        if (storeGlobally) {
            pegiOptionsHtml = optionsHtml;
        }

    } catch (error) {
        select.innerHTML = `<option value="">Error al cargar</option>`;
    }
}


async function loadCheckboxList(containerId, url, idField) {
    const container = document.getElementById(containerId);
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('No se pudieron cargar los datos');
        const items = await response.json(); 
        container.innerHTML = ''; 
        items.forEach(item => {
            const id = item[idField] || item.id;
            const text = item.nombre;
            container.innerHTML += `
                <label class="block cursor-pointer hover:text-white">
                    <input type="checkbox" value="${id}" class="mr-2 accent-blue-500" data-name="${containerId}">
                    ${text}
                </label>`;
        });
    } catch (error) {
        container.innerHTML = `<p class="text-red-400">Error al cargar</p>`;
    }
}

async function openGameModal(juegoId = null) {
    const form = document.getElementById('juego-form');
    form.reset(); 
    document.getElementById('dlc-list').innerHTML = '';
    document.querySelectorAll('#juego-form input[type="checkbox"]').forEach(cb => cb.checked = false);
    const modalTitle = document.getElementById('modal-title');
    const idInput = document.getElementById('juego-id');
    const estadoBtn = document.getElementById('btn-toggle-estado');
    if (juegoId) {
        modalTitle.textContent = 'Editar Juego';
        idInput.value = juegoId;
        try {
            const response = await fetch(`${API_BASE_URL}/Juegos/${juegoId}`);
            if (!response.ok) throw new Error('No se pudo cargar el juego');
        
            const juego = await response.json(); 
            populateForm(juego);
            estadoBtn.classList.remove('hidden');
        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: 'Error al Cargar',
                text: 'No se pudo cargar la información del juego.',
                background: '#1f2937', 
                color: '#e5e7eb',     
                confirmButtonColor: '#3b82f6' 
            });
            return;
        }
    } else {
        modalTitle.textContent = 'Crear Nuevo Juego';
        idInput.value = ''; 
        estadoBtn.classList.add('hidden'); 
        document.getElementById('juego-estado-actual').value = 'Publicado'; 
    }
    toggleModal(true); 
}

function populateForm(juego) {
    document.getElementById('nombre').value = juego.nombre || '';
    document.getElementById('descripcion').value = juego.descripcion || '';
    document.getElementById('precioInicial').value = juego.precioActual || 0.0;
    
    document.getElementById('fechaLanzamiento').value = juego.fechaLanzamiento || ''; 
    document.getElementById('juego-estado-actual').value = juego.estado || 'Publicado';
    updateEstadoButton(juego.estado);

    document.getElementById('pegi').value = juego.idPegi; 
    
    populateCheckboxes('generos-list', juego.generos);
    populateCheckboxes('publishers-list', juego.publishers);
    populateCheckboxes('etiquetas-list', juego.etiquetas);
    const dlcList = document.getElementById('dlc-list');
    dlcList.innerHTML = '';
    if (juego.dlcs && juego.dlcs.length > 0) {
        juego.dlcs.forEach(dlc => {
            addDlcRow(dlc.idDlc, dlc.nombre, dlc.precioActual, dlc.descripcion || '',dlc.idPegi ||null);
        });
    }
}

function populateCheckboxes(containerId, selectedNames) {
    if (!selectedNames || selectedNames.length === 0) return;
    const checkboxes = document.querySelectorAll(`#${containerId} input[type="checkbox"]`);
    const nameSet = new Set(selectedNames.map(name => name.toLowerCase()));
    checkboxes.forEach(cb => {
        const labelText = cb.parentElement.textContent.trim().toLowerCase();
        if (nameSet.has(labelText)) {
            cb.checked = true;
        }
    });
}

function addDlcRow(idDlc = 0, nombre = '', precio = 0, descripcion = '', idPegi = null) {
    const dlcList = document.getElementById('dlc-list');
    const dlcRow = document.createElement('div');
    dlcRow.className = 'dlc-row grid grid-cols-12 gap-2 p-2 bg-gray-700 rounded-md items-center';
    dlcRow.dataset.idDlc = idDlc; 

    dlcRow.innerHTML = `
        <div class="col-span-5">
            <label class="text-xs text-blue-300">Nombre DLC</label>
            <input type="text" placeholder="Nombre..." value="${nombre}" class="dlc-nombre w-full bg-gray-600 text-white rounded-md p-1 border border-gray-500" required>
        </div>
        <div class="col-span-3">
             <label class="text-xs text-blue-300">Precio</label>
            <input type="number" placeholder="Precio..." value="${precio}" step="0.01" class="dlc-precio w-full bg-gray-600 text-white rounded-md p-1 border border-gray-500" required>
        </div>
        <div class="col-span-3">
             <label class="text-xs text-blue-300">PEGI</label>
            <select class="dlc-pegi w-full bg-gray-600 text-white rounded-md p-1 border border-gray-500" required>
                ${pegiOptionsHtml}
            </select>
        </div>
        <div class="col-span-1 flex items-end">
            <button type="button" class="dlc-remove text-red-400 hover:text-red-300 font-bold p-1">&times;</button>
        </div>

        <div class="col-span-12 mt-2">
             <label class="text-xs text-blue-300">Descripción DLC</label>
            <input type="text" placeholder="Descripción..." value="${descripcion}" class="dlc-descripcion w-full bg-gray-600 text-white rounded-md p-1 border border-gray-500">
        </div>
    `;

    if (idPegi) {
        dlcRow.querySelector('.dlc-pegi').value = idPegi;
    }
    
    dlcRow.querySelector('.dlc-remove').addEventListener('click', () => dlcRow.remove());
    dlcList.appendChild(dlcRow);
}


async function handleFormSubmit(e) {
    e.preventDefault();
    const form = e.target;
    const juegoId = document.getElementById('juego-id').value;
    const estado = document.getElementById('juego-estado-actual').value;

    const juegoDto = {
        nombre: document.getElementById('nombre').value,
        descripcion: document.getElementById('descripcion').value,
        fechaLanzamiento: document.getElementById('fechaLanzamiento').value || null,
        estado: estado,
        idPegi: parseInt(document.getElementById('pegi').value, 10),
        precioInicial: parseFloat(document.getElementById('precioInicial').value),

        idsGeneros: getCheckedIds('generos-list'),
        idsEtiquetas: getCheckedIds('etiquetas-list'),
        idsPublishers: getCheckedIds('publishers-list'),
        idsDesarrolladoras: [], 
        idsSistemasOperativos: [], 
        
        dlcs: Array.from(document.querySelectorAll('#dlc-list .dlc-row')).map(row => ({
            idJuegoBase: parseInt(juegoId, 10) || 0,
            // idDlc: parseInt(row.dataset.idDlc, 10) || 0, 
            nombre: row.querySelector('.dlc-nombre').value,
            descripcion: row.querySelector('.dlc-descripcion').value, 
            precioInicial: parseFloat(row.querySelector('.dlc-precio').value),
            idPegi: parseInt(row.querySelector('.dlc-pegi').value, 10), 
            fechaLanzamiento: null 
        }))
    };
    console.log(juegoDto)
    console.log(juegoDto.dlcs)

    const esCrear = !juegoId;
    const method = esCrear ? 'POST' : 'PUT';
    const url = esCrear ? `${API_BASE_URL}/Juegos` : `${API_BASE_URL}/Juegos/${juegoId}`;

    try {
        const response = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(juegoDto)
        });
        if (!response.ok) {
            const errorData = await response.text();
            throw new Error(`Error ${response.status}: ${errorData}`);
        }
        Swal.fire({
            icon: 'success',
            title: '¡Operación Exitosa!',
            text: `Juego ${esCrear ? 'creado' : 'actualizado'} con éxito.`,
            background: '#1f2937', 
            color: '#e5e7eb', 
            confirmButtonColor: '#3b82f6' 
        });
        toggleModal(false);
        cargarJuegos(paginacionState.currentPage); 
    } catch (error) {
            Swal.fire({
                icon: 'error',
                title: `Error al guardar: ${error.message}`,
                text: 'No se pudo guardar la información del juego.',
                background: '#1f2937', 
                color: '#e5e7eb',     
                confirmButtonColor: '#3b82f6' 
            });
    }
}

function getCheckedIds(containerId) {
    return Array.from(document.querySelectorAll(`#${containerId} input[type="checkbox"]:checked`))
    .map(cb => parseInt(cb.value, 10));
}

async function handleToggleEstado() {
    const juegoId = document.getElementById('juego-id').value;
    if (!juegoId) return;
    const estadoActual = document.getElementById('juego-estado-actual').value;
    const cancelar = (estadoActual === 'Publicado'); 
    const nuevoEstado = cancelar ? 'No Disponible' : 'Publicado';
    const resultado = await Swal.fire({
        title: '¿Confirmar Cambio?',
        text: `¿Estás seguro de que quieres cambiar el estado a "${nuevoEstado}"?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3b82f6', 
        cancelButtonColor: '#d33',
        confirmButtonText: 'Sí, cambiar estado',
        cancelButtonText: 'Cancelar',
        background: '#1f2937', 
        color: '#e5e7eb' 
    });
    if (!resultado.isConfirmed) {
        return;
    }
    try {
        const url = `${API_BASE_URL}/Juegos?id=${juegoId}&cancelar=${cancelar}`;
        const response = await fetch(url, { method: 'PUT' });
        if (!response.ok) {
            throw new Error(`Error ${response.status}: No se pudo cambiar el estado.`);
        }
        Swal.fire({
            icon: 'success',
            title: 'Estado cambiado con éxito',
            background: '#1f2937', 
            color: '#e5e7eb', 
            confirmButtonColor: '#3b82f6' 
        });
        document.getElementById('juego-estado-actual').value = nuevoEstado;
        updateEstadoButton(nuevoEstado);
        cargarJuegos(paginacionState.currentPage);
    } catch (error) {
        alert(`Error: ${error.message}`);
                    Swal.fire({
                icon: 'error',
                title: 'Error al cambiar estado:',
                text: `Error: ${error.message}`,
                background: '#1f2937', 
                color: '#e5e7eb',     
                confirmButtonColor: '#3b82f6' 
            });
    }
}

function updateEstadoButton(estado) {
    const estadoBtn = document.getElementById('btn-toggle-estado');
    if (estado === 'Publicado') {
        estadoBtn.textContent = 'Deshabilitar Juego';
        estadoBtn.className = 'text-white py-2 px-4 rounded-md transition bg-red-600 hover:bg-red-700';
    } else {
        estadoBtn.textContent = 'Habilitar Juego';
        estadoBtn.className = 'text-white py-2 px-4 rounded-md transition bg-green-600 hover:bg-green-700';
    }
}
