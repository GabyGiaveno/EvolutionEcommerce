using Application.DTOs.EstadisticasDtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface IEstadisticasServicio
    {
        Task<IEnumerable<ReporteJuegoDlcDto>> GetReporteJuegoDlcAsync();
        Task<IEnumerable<ReporteUsuariosMayorGastoDto>> GetReporteUsuariosMayorGastoAsync();
        Task<IEnumerable<ReportePublishersIngresoDto>> GetReportePublishersIngresoAsync();
    }
}
