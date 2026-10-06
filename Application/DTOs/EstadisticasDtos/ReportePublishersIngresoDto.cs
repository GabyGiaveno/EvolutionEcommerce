using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.EstadisticasDtos
{
    public class ReportePublishersIngresoDto
    {
        public string Publisher { get; set; }
        public int UnidadesVendidas { get; set; }
        public decimal TotalRecaudado { get; set; }
    }
}
