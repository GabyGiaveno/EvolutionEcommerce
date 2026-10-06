using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.EstadisticasDtos
{
    public class ReporteUsuariosMayorGastoDto
    {
        public string NombreUsuario { get; set; }
        public decimal TotalGastado { get; set; }
        public int CantidadTransacciones { get; set; }
    }
}
