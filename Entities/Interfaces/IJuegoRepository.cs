using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Interfaces
{
    public interface IJuegoRepository : IRepository<Juego>
    {
        // Método para obtener UN juego con todas sus relaciones
        Task<Juego?> GetByIdConDetallesAsync(int id);

        // Método para obtener TODOS los juegos con sus relaciones
        Task<IEnumerable<Juego>> GetAllConDetallesAsync();
        Task UpdateJuegoAsync(Juego juego);

        Task<(IEnumerable<Juego> Items, int TotalCount)> GetPagedConDetallesAsync(int pageNumber, int pageSize);
        Task CambiarEstadoAsync(int id, bool cancelar);
        Task<(IEnumerable<Juego> Items, int TotalCount)> GetJuegosFiltradosPaginadosAsync(
        int pageNumber,
        int pageSize,
        int? idGenero,       
        int? idPublisher,    
        int? idEtiqueta,
        string? Nombre
    );
    }
}
