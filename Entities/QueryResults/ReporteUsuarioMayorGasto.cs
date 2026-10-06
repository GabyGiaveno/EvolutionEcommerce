using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.QueryResults
{
    public class ReporteUsuarioMayorGasto
    {
        public string NombreUsuario { get; set; }
        public decimal TotalGastado { get; set; }
        public int CantidadTransacciones { get; set; }
    }
}
