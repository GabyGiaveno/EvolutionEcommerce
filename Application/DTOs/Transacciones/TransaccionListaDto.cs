using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Transacciones
{
    public class TransaccionListaDto
    {
        public int IdTransaccion { get; set; }
        public DateTime Fecha { get; set; }
        public string? EmailUsuario { get; set; }
        public required string Tipo { get; set; }
        public decimal Total { get; set; }
    }
}
