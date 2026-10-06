
import { initIndexPage } from './tienda.js';
import { initAdminPage } from './admin.js';
import { initJuegoDetallePage } from './juegoDetalle.js';
import { initReportePage } from './estadisticas.js';
import { initCarritoPage } from './carrito.js';


//detectar en que pagina estoy
//le envia un elemento del documento y si detecta que corresponde a una pagina,
// llama a la funcion de inicializacion de esa pagina
document.addEventListener('DOMContentLoaded', () => {
    
    //página de la tienda
    if (document.getElementById('product-list-juegos')) {
        initIndexPage();
    } 
    //página de admin
    else if (document.getElementById("transacciones-tbody")) {
        initAdminPage();
    }
    else if (document.getElementById("juego-detalle-container")) {
        initJuegoDetallePage();
    }
    else if (document.getElementById("grafico-dlc-reporte")) {
        initReportePage();
    }

    //página de login
    //página de usuario
    else if (document.getElementById("biblioteca-container")) {
        // initProfilePage(); 
    }
    else if (document.getElementById("cart-items-container")) {
        initCarritoPage();
    }
});