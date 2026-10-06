using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.QueryResults
{
    public class ReporteJuegoDlcResultado
    {
        public string JuegoBase { get; set; }
        public int CantidadDLCs { get; set; }
        public int VentasJuegoBase { get; set; }
        public int VentasDLCs { get; set; }
        public decimal IngresosJuegoBase { get; set; }
        public decimal IngresosDLCs { get; set; }
    }
}
