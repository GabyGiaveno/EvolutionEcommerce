
import { API_BASE_URL } from './utils.js'; 

let myDlcChart = null; 
let myTopUsuariosChart = null;
let myTopPublishersChart = null;
export function initReportePage() {
    cargarReporteDlc();
    cargarReporteTopUsuarios();
    cargarReporteTopPublishers();
}

async function cargarReporteDlc() {
    const errorContainer = document.getElementById('grafico-error');
    const loadingText = document.getElementById('grafico-loading');
    
    try {
        const url = `${API_BASE_URL}/Estadisticas/reporte-juego-dlc`;
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`Error ${response.status}: ${await response.text()}`);
        }
        
        const data = await response.json(); 
        loadingText.classList.add('hidden'); 

        if (data.length === 0) {
            errorContainer.textContent = "No se encontraron datos que cumplan con los criterios del reporte.";
            return;
        }

        renderGraficoDlc(data);
        
    } catch (error) {
        loadingText.classList.add('hidden');
        errorContainer.textContent = "Error al cargar el reporte.";
    }
}

/**
 * Renderiza el gráfico de barras usando Chart.js
 * @param {Array} data 
 */
function renderGraficoDlc(data) {
    const ctx = document.getElementById('grafico-dlc-reporte').getContext('2d');
    
    // mapeo datos para el chart
    const labels = data.map(item => item.juegoBase);
    const ingresosBase = data.map(item => item.ingresosJuegoBase);
    const ingresosDlcs = data.map(item => item.ingresosDLCs);

    if (myDlcChart) {
        myDlcChart.destroy();
    }

    myDlcChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels, 
            datasets: [
                {
                    label: 'Ingresos Juego Base',
                    data: ingresosBase,
                    backgroundColor: 'rgba(59, 130, 246, 0.7)',
                    borderColor: 'rgba(59, 130, 246, 1)',
                    borderWidth: 2
                },
                {
                    label: 'Ingresos DLCs',
                    data: ingresosDlcs,
                    backgroundColor: 'rgba(16, 185, 129, 0.7)',
                    borderColor: 'rgba(16, 185, 129, 1)',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    stacked: true, 
                    ticks: { color: '#9CA3AF' },
                    grid: { display: false }
                },
                y: {
                    stacked: true, 
                    beginAtZero: true,
                    ticks: { 
                        color: '#9CA3AF',
                        // Formatear el eje Y como moneda
                        callback: function(value) {
                            return '$' + value.toLocaleString('es-AR');
                        }
                    },
                    grid: { color: '#4B5563' }
                }
            },
            plugins: {
                legend: {
                    labels: { color: '#D1D5DB' }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.parsed.y !== null) {
                                label += formatCurrency(context.parsed.y);
                            }
                            return label;
                        }
                    }
                }
            }
        }
    });
}
async function cargarReporteTopUsuarios() {
    const errorContainer = document.getElementById('grafico-usuarios-error');
    const loadingText = document.getElementById('grafico-usuarios-loading');
    
    try {
        //pegarle al endpoint correcto
        const url = `${API_BASE_URL}/Estadisticas/reporte-usuarios-mayor-gasto`; 
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`Error ${response.status}: ${await response.text()}`);
        }
        
        const data = await response.json();
        loadingText.classList.add('hidden'); 

        if (data.length === 0) {
            errorContainer.textContent = "No se encontraron datos de usuarios.";
            return;
        }
        //llamo al render
        renderGraficoTopUsuarios(data);
        
    } catch (error) {
        loadingText.classList.add('hidden');
        errorContainer.textContent = "Error al cargar el reporte.";
    }
}

/**
 * Renderiza el gráfico de barras para el Top 10 de Usuarios
 * @param {Array} data 
 */
function renderGraficoTopUsuarios(data) {
    const ctx = document.getElementById('grafico-top-usuarios').getContext('2d');
    
    // Separamos los datos para Chart.js
    const labels = data.map(item => item.nombreUsuario);
    const totalGastadoData = data.map(item => item.totalGastado);
    const cantidadTransaccionesData = data.map(item => item.cantidadTransacciones);

    if (myTopUsuariosChart) {
        myTopUsuariosChart.destroy();
    }

    myTopUsuariosChart = new Chart(ctx, {
        type: 'bar', // Tipo base
        data: {
            labels: labels, 
            datasets: [
                {
                    label: 'Total Gastado ($)',
                    data: totalGastadoData,
                    type: 'bar', // Este es un set de BARRAS
                    backgroundColor: 'rgba(59, 130, 246, 0.7)', 
                    borderColor: 'rgba(59, 130, 246, 1)',
                    yAxisID: 'y_gasto', // Asignado al eje Y izquierdo (dinero)
                },
                {
                    label: 'Cantidad de Transacciones',
                    data: cantidadTransaccionesData,
                    type: 'bar', // Este es un set de LÍNEA
                    backgroundColor: 'rgba(234, 179, 8, 0.7)', 
                    borderColor: 'rgba(234, 179, 8, 1)',
                    tension: 0.1,
                    fill: false,
                    yAxisID: 'y_cantidad', // Asignado al eje Y derecho 
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    ticks: { color: '#9CA3AF' },
                    grid: { display: false }
                },
                // Eje Y Izquierdo (Dinero)
                y_gasto: { 
                    type: 'linear',
                    position: 'left',
                    beginAtZero: true,
                    ticks: { 
                        color: 'rgba(59, 130, 246, 1)',
                        callback: function(value) {
                            return '$' + value.toLocaleString('es-AR');
                        }
                    },
                    grid: { color: '#4B5563' }
                },
                // Eje Y Derecho (Cantidad)
                y_cantidad: { 
                    type: 'linear',
                    position: 'right',
                    beginAtZero: true,
                    ticks: { 
                        color: 'rgba(234, 179, 8, 1)',
                        stepSize: 1 
                    },
                    grid: { display: false } // Ocultar esta grilla para más limpieza
                }
            },
            plugins: {
                legend: { labels: { color: '#D1D5DB' } },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) { label += ': '; }
                            
                            if (context.dataset.label.includes('Transacciones')) {
                                label += context.parsed.y.toLocaleString('es-AR')
                            } else {
                                label += formatCurrency(context.parsed.y);
                            }
                            return label;
                        }
                    }
                }
            }
        }
    });
}
async function cargarReporteTopPublishers() {
    const errorContainer = document.getElementById('grafico-publishers-error');
    const loadingText = document.getElementById('grafico-publishers-loading');
    
    try {
        const url = `${API_BASE_URL}/Estadisticas/reporte-publishers-ingreso`; 
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`Error ${response.status}: ${await response.text()}`);
        }
        
        const data = await response.json();
        loadingText.classList.add('hidden'); 

        if (data.length === 0) {
            errorContainer.textContent = "No se encontraron datos de publishers.";
            return;
        }

        renderGraficoTopPublishers(data);
        
    } catch (error) {
        loadingText.classList.add('hidden');
        errorContainer.textContent = "Error al cargar el reporte.";
    }
}

/**
 * Renderiza el gráfico de barras para el Top 5 de Publishers
 * @param {Array} data
 */
function renderGraficoTopPublishers(data) {
    const ctx = document.getElementById('grafico-top-publishers').getContext('2d');
    
    const labels = data.map(item => item.publisher);
    const totalRecaudadoData = data.map(item => item.totalRecaudado);
    const unidadesVendidasData = data.map(item => item.unidadesVendidas);

    if (myTopPublishersChart) {
        myTopPublishersChart.destroy();
    }

    myTopPublishersChart = new Chart(ctx, {
        type: 'bar', 
        data: {
            labels: labels, // Nombres de publishers
            datasets: [
                {
                    label: 'Total Recaudado ($)',
                    data: totalRecaudadoData,
                    type: 'bar', // Set de BARRAS
                    backgroundColor: 'rgba(59, 130, 246, 0.7)', 
                    borderColor: 'rgba(59, 130, 246, 1)',
                    yAxisID: 'y_recaudado', 
                },
                {
                    label: 'Unidades Vendidas',
                    data: unidadesVendidasData,
                    type: 'bar', // Set de BARRAS
                    backgroundColor: 'rgba(16, 185, 129, 0.7)', 
                    borderColor: 'rgba(16, 185, 129, 1)',
                    tension: 0.1,
                    fill: false,
                    yAxisID: 'y_unidades', // Eje Y derecho (cantidad)
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    ticks: { color: '#9CA3AF' },
                    grid: { display: false }
                },
                // Eje Y Izquierdo (Dinero)
                y_recaudado: { 
                    type: 'linear',
                    position: 'left',
                    beginAtZero: true,
                    ticks: { 
                        color: 'rgba(59, 130, 246, 1)', // Color azul
                        callback: function(value) {
                            return '$' + value.toLocaleString('es-AR');
                        }
                    },
                    grid: { color: '#4B5563' }
                },
                // Eje Y Derecho (Cantidad)
                y_unidades: { 
                    type: 'linear',
                    position: 'right',
                    beginAtZero: true,
                    ticks: { 
                        color: 'rgba(16, 185, 129, 1)', // Color verde
                        stepSize: 1 // Asegurar enteros
                    },
                    grid: { display: false } // Ocultar esta grilla
                }
            },
            plugins: {
                legend: { labels: { color: '#D1D5DB' } },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) { label += ': '; }
                            
                            // Mostrar formato correcto ($ o uds.)
                            if (context.dataset.label.includes('Unidades')) {
                                label += context.parsed.y.toLocaleString('es-AR')
                            } else {
                                label += formatCurrency(context.parsed.y);
                            }
                            return label;
                        }
                    }
                }
            }
        }
    });
}

// función simple de formato de moneda para el Tooltip
function formatCurrency(amount) {
    const numericValue = Number(amount ?? 0);
    if (!Number.isFinite(numericValue) || numericValue <= 0) {
        return 'Gratis';
    }
    return numericValue.toLocaleString('es-AR', {
        style: 'currency',
        currency: 'ARS'
    });
}
