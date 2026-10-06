using Application.DTOs;
using Application.DTOs.Juegos;
using Application.DTOs.Paginacion;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces
{
    public interface IJuegosServicio
    {
        Task<JuegosRespuestaDto?> GetJuegoByIdAsync(int id);    
        Task<IEnumerable<JuegosRespuestaDto>> GetAllJuegosAsync();
        Task<PagedResultDto<JuegosRespuestaDto>> GetJuegosPaginadosAsync(int page, int pageSize);
        Task CreateJuegoAsync(JuegosCrearDto juegoDto);
        Task UpdateJuegoAsync(int id, JuegosCrearDto juegoDto);
        Task CambiarEstadoAsync(int id, bool cancelar);
        Task<PagedResultDto<JuegosRespuestaDto>> GetJuegosPaginadosAsync(JuegosFiltroQueryDto filtroQuery);
    }
}
