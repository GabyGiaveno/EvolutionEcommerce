using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Transacciones
{
    public class ProductoTransaccionDto
    {
        public int IdProducto { get; set; }
        public required string NombreProducto { get; set; }
        public decimal PrecioOriginal { get; set; }
        public decimal PrecioPagado { get; set; }
        public decimal? DescuentoAplicado { get; set; }
    }
}
