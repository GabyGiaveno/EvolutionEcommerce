using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Interfaces
{
    public interface ITransaccionRepository : IRepository<Transaccione>
    {
        Task<IEnumerable<Transaccione>> GetTransaccionesCompletasAsync(string sortColumn, string sortOrder, DateTime? fechaInicio, DateTime? fechaFin);
        Task<Transaccione?> GetTransaccionDetalleAsync(int id);
            Task<(IEnumerable<Transaccione> items, int totalCount)> GetTransaccionesFiltradasPaginadasAsync(
                string sortColumn, 
                string sortOrder,
                int pageNumber,
                int pageSize,
                DateTime? fechaInicio,
                DateTime? fechaFin
                );
        
    }
}

