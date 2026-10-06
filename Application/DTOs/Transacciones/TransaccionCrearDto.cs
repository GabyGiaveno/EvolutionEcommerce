using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Transacciones
{
    public class TransaccionCrearDto
    {
        public List<int> IdsProductos { get; set; }
        public int IdUsuario { get; set; }
        // Por ahora, lo harcodeamos en el backend.
        // public int IdMetodoPago { get; set; } 
    }
}
