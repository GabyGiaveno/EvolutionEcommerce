using Entities.Interfaces;
using Entities.Models;
using Entities.QueryResults;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Persistance.Repositories.Implementacion
{
    public class EstadisticasRepository : IEstadisticasRepository
    {
        private readonly EvolutionDBContext _context;

        public EstadisticasRepository(EvolutionDBContext context)
        {
            _context = context;
        }
        public async Task<IEnumerable<ReporteJuegoDlcResultado>> GetReporteJuegoDlcAsync()
        {
        return await _context.Set<ReporteJuegoDlcResultado>()
                     .FromSqlRaw("EXEC sp_GetReporteJuegoDlc")
                     .ToListAsync();
        }
        public async Task<IEnumerable<ReporteUsuarioMayorGasto>> GetReporteUsuarioMayorGastoAsync()
        {
            return await _context.Set<ReporteUsuarioMayorGasto>()
                         .FromSqlRaw("EXEC sp_UsuariosMayorGasto")
                         .ToListAsync();
        }
        public async Task<IEnumerable<ReportePublishersIngreso>> GetReportePublishersIngresosAsync()
        {
            return await _context.Set<ReportePublishersIngreso>()
                         .FromSqlRaw("EXEC SP_publishers_ingresos")
                         .ToListAsync();
        }
    }
}
