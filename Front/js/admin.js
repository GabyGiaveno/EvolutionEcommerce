import { formatCurrency, toggleModal, fetchConAuth,actualizarNavbar  } from './utils.js';

const adminSortState = { column: 'fecha', order: 'desc' };

export function initAdminPage() {
  actualizarNavbar();
  cargarTransacciones();
  initAdminModal();
  document.getElementById('paginacion-admin')?.addEventListener('click', handlePaginacionClick);
  document.getElementById('sort-fecha').addEventListener('click', () => handleSortClick('fecha'));
  document.getElementById('sort-total').addEventListener('click', () => handleSortClick('total'));
  const btnFiltrar = document.getElementById('btn-filtrar-fechas');
    if (btnFiltrar) {
        btnFiltrar.addEventListener('click', () => {
            cargarTransacciones(1); 
        });
    }

    const btnLimpiar = document.getElementById('btn-limpiar-fechas');
    if (btnLimpiar) {
        btnLimpiar.addEventListener('click', () => {
            // Limpia los inputs
            document.getElementById('fecha-inicio').value = '';
            document.getElementById('fecha-fin').value = '';
            // Vuelve a cargar sin filtros de fecha
            cargarTransacciones(1);
        });
    }
}

function handleSortClick(columnName) {
  if (adminSortState.column === columnName) {
    adminSortState.order = adminSortState.order === 'asc' ? 'desc' : 'asc';
  } else {
    adminSortState.column = columnName;
    adminSortState.order = 'desc';
  }
  cargarTransacciones();
  updateSortIcons();
}

function updateSortIcons() {
  document.querySelectorAll('.sort-button').forEach(btn => {
    const icon = btn.querySelector('.sort-icon');
    if (!icon) return;
    if (btn.dataset.column === adminSortState.column) {
      icon.innerHTML = adminSortState.order === 'asc' ? '&#9650;' : '&#9660;';
    } else {
      icon.innerHTML = '';
    }
  });
}

async function cargarTransacciones(page = 1) {
  const tbody = document.getElementById('transacciones-tbody');
  if (!tbody) return;

  tbody.innerHTML = `<tr><td colspan="6" class="px-6 py-4 whitespace-nowrap text-center text-gray-400">Cargando transacciones...</td></tr>`;

  let url = `/Transacciones/paginadas?PageNumber=${page}&sortColumn=${adminSortState.column}&sortOrder=${adminSortState.order}`;

  const fechaInicio = document.getElementById('fecha-inicio')?.value || '';
  const fechaFin = document.getElementById('fecha-fin')?.value || '';
  if (fechaInicio) url += `&FechaDesde=${fechaInicio}`;
  if (fechaFin) url += `&FechaHasta=${fechaFin}`;

  try {
    const response = await fetchConAuth(url);
    if (!response.ok) throw new Error(`Error HTTP: ${response.statusText}`);

    const data = await response.json();
    const transacciones = data.items || [];

    tbody.innerHTML = '';
    if (transacciones.length === 0) {
      tbody.innerHTML = `<tr><td colspan="6" class="px-6 py-4 whitespace-nowrap text-center text-gray-400">No se encontraron transacciones.</td></tr>`;
      return;
    }

    transacciones.forEach(tx => {
      const tr = document.createElement('tr');
      tr.className = 'hover:bg-gray-700 transition duration-150';
      const fechaFormateada = new Date(tx.fecha).toLocaleString('es-AR');
      const totalFormateado = formatCurrency(tx.total);

      tr.innerHTML = `
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-white">${tx.idTransaccion}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">${fechaFormateada}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">${tx.emailUsuario}</td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
          <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${tx.tipo === 'Compra' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">${tx.tipo}</span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-white">${totalFormateado}</td>
        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
          <button data-tx-id="${tx.idTransaccion}" class="btn-ver-detalles text-blue-400 hover:text-blue-300">Ver Detalles</button>
        </td>`;
      tbody.appendChild(tr);
    });

    tbody.querySelectorAll('.btn-ver-detalles').forEach(button => {
      button.addEventListener('click', () => verDetalleTransaccion(button.dataset.txId));
    });

    renderPaginacionAdmin(data);
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" class="px-6 py-4 whitespace-nowrap text-center text-red-400">Error al cargar los datos.</td></tr>`;
  }

  updateSortIcons();
}

function initAdminModal() {
  const modalCloseBtn = document.getElementById('modal-close-btn');
  const modal = document.getElementById('detalle-modal');
  if (modalCloseBtn && modal) {
    modalCloseBtn.addEventListener('click', () => toggleModal(false));
    modal.addEventListener('click', e => {
      if (e.target === modal) toggleModal(false);
    });
  }
}

async function verDetalleTransaccion(id) {
  const modalBody = document.getElementById('modal-body');
  modalBody.innerHTML = '<p id="modal-loading-text" class="text-center text-gray-300">Cargando detalles...</p>';
  toggleModal(true);

  try {
    const response = await fetchConAuth(`/Transacciones/${id}`);
    if (!response.ok) throw new Error(`Error: ${response.statusText}`);
    const tx = await response.json();

    let productosHtml = '';
    tx.productos.forEach(prod => {
      const precioPagado = formatCurrency(prod.precioPagado);
      const precioOriginal = formatCurrency(prod.precioOriginal);
      const descuentoHtml = prod.descuentoAplicado ? `<span class=\"text-sm text-red-400\">(-${prod.descuentoAplicado.toFixed(0)}%)</span>` : '';
      productosHtml += `
        <div class=\"flex justify-between items-center py-3 border-b border-gray-700 last:border-b-0\">
          <div>
            <p class=\"font-semibold text-white\">${prod.nombreProducto}</p>
            <p class=\"text-sm text-gray-400\">ID Producto: ${prod.idProducto}</p>
          </div>
          <div class=\"text-right\">
            <p class=\"font-semibold text-lg text-white\">${precioPagado}</p>
            ${prod.precioOriginal !== prod.precioPagado ? `<p class=\"text-sm text-gray-500 line-through\">${precioOriginal} ${descuentoHtml}</p>` : ''}
          </div>
        </div>`;
    });

    const totalFormateado = formatCurrency(tx.totalTransaccion);

    modalBody.innerHTML = `
      <div class=\"mb-4\">
        <p class=\"text-sm text-gray-400\">ID Transacción</p>
        <p class=\"text-lg font-semibold text-white\">${tx.idTransaccion}</p>
      </div>
      <div class=\"mb-4\">
        <p class=\"text-sm text-gray-400\">Email Usuario</p>
        <p class=\"text-lg font-semibold text-white\">${tx.emailUsuario}</p>
      </div>
      <div class=\"mb-6\">
        <p class=\"text-sm text-gray-400\">Fecha</p>
        <p class=\"text-lg font-semibold text-white\">${new Date(tx.fecha).toLocaleString('es-AR')}</p>
      </div>
      <h4 class=\"text-xl font-bold text-blue-300 mb-3 border-t border-gray-700 pt-4\">Productos Comprados</h4>
      <div class=\"flex flex-col space-y-2 mb-6\">${productosHtml}</div>
      <div class=\"flex justify-between items-center bg-gray-700 p-4 rounded-lg\">
        <span class=\"text-xl font-bold text-white\">TOTAL</span>
        <span class=\"text-2xl font-bold text-white\">${totalFormateado}</span>
      </div>`;
  } catch (error) {
    modalBody.innerHTML = '<p class=\"text-center text-red-400\">Error al cargar los detalles.</p>';
  }
}

function renderPaginacionAdmin(pagedData) {
  const paginacionContainer = document.getElementById('paginacion-admin');
  paginacionContainer.innerHTML = '';
  let html = '';

  const { page, totalPages, hasPrevious, hasNext } = pagedData;
  const maxVisible = 7;

  html += `
    <button data-page=\"${page - 1}\" class=\"pagination-button px-3 py-1 rounded-lg ${!hasPrevious ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600'}\" ${!hasPrevious ? 'disabled' : ''}>&laquo;</button>`;

  let startPage = Math.max(1, page - Math.floor(maxVisible / 2));
  let endPage = startPage + maxVisible - 1;
  if (endPage > totalPages) {
    endPage = totalPages;
    startPage = Math.max(1, endPage - maxVisible + 1);
  }
  if (startPage > 1) {
    html += `<button data-page=\"1\" class=\"pagination-button px-3 py-1 rounded-lg bg-gray-700 text-gray-300 hover:bg-gray-600\">1</button>`;
    if (startPage > 2) html += `<span class=\"px-2 text-gray-400\">...</span>`;
  }
  for (let i = startPage; i <= endPage; i++) {
    const active = i === page;
    html += `<button data-page=\"${i}\" class=\"pagination-button px-3 py-1 rounded-lg ${active ? 'bg-blue-600 text-white font-bold cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600'}\" ${active ? 'disabled' : ''}>${i}</button>`;
  }
  if (endPage < totalPages) {
    if (endPage < totalPages - 1) html += `<span class=\"px-2 text-gray-400\">...</span>`;
    html += `<button data-page=\"${totalPages}\" class=\"pagination-button px-3 py-1 rounded-lg bg-gray-700 text-gray-300 hover:bg-gray-600\">${totalPages}</button>`;
  }
  html += `<button data-page=\"${page + 1}\" class=\"pagination-button px-3 py-1 rounded-lg ${!hasNext ? 'bg-gray-700 text-gray-500 cursor-not-allowed' : 'bg-gray-700 text-gray-300 hover:bg-gray-600'}\" ${!hasNext ? 'disabled' : ''}>&raquo;</button>`;

  paginacionContainer.innerHTML = html;
  paginacionContainer.scrollLeft = 0;
}

function handlePaginacionClick(e) {
  const targetButton = e.target.closest('.pagination-button');
  if (!targetButton || targetButton.disabled) return;
  const page = parseInt(targetButton.dataset.page, 10);
  if (isNaN(page)) return;
  cargarTransacciones(page);
  document.querySelector('#tabla-transacciones-container')?.scrollIntoView({ behavior: 'smooth' });
}

