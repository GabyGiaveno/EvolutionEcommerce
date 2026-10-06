// IIFE (Función autoejecutable)
(function() {
    // busca rol desde localStorage
    const userRole = localStorage.getItem('usuarioRol');
    // si el rol NO es 'Admin'
    // (Esto también cubre si es 'null' o 'Usuario')
    if (userRole !== 'Admin') {
        // Redire usuario a la página principal
        window.location.href = 'index.html'; 
    }
    
//     // Si el rol es 'Admin', el script simplemente termina
//     // y la carga de admin.html continúa normalmente.

})()
