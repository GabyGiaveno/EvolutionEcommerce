using Entities.QueryResults;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Interfaces
{
    public interface IEstadisticasRepository
    {
        Task<IEnumerable<ReporteJuegoDlcResultado>> GetReporteJuegoDlcAsync();
        Task<IEnumerable<ReporteUsuarioMayorGasto>> GetReporteUsuarioMayorGastoAsync();
        Task<IEnumerable<ReportePublishersIngreso>> GetReportePublishersIngresosAsync();
    }
}
