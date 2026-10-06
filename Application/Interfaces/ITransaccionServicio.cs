using Application.DTOs.Paginacion;
using Application.DTOs.Transacciones;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface ITransaccionServicio
    {
        Task<IEnumerable<TransaccionListaDto>> GetAllTransaccionesAsync(string sortColumn, string sortOrder, DateTime? fechaInicio = null, DateTime? fechaFin = null);
        Task<TransaccionDetalleDto> GetTransaccionByIdAsync(int id);
        Task<PagedResultDto<TransaccionListaDto>> GetTransaccionesFiltradasPaginadasAsync(TransaccionFiltroQueryDto filtroQuery);
        Task<TransaccionDetalleDto> CrearTransaccionAsync(TransaccionCrearDto transaccionDto);
    }
}
