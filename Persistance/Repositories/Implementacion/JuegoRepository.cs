using Entities.Interfaces;              
using Entities.Models;                  
using Microsoft.EntityFrameworkCore;    

namespace Persistance.Repositories.Implementacion
{
    public class JuegoRepository : Repository<Juego>, IJuegoRepository
    {
        public JuegoRepository(EvolutionDBContext context) : base(context)
        {
        }
        public async Task<Juego?> GetByIdConDetallesAsync(int id)
        {
            return await _context.Juegos
                .Include(j => j.Pegi)
                .Include(j => j.Generos)
                .Include(j => j.Etiquetas)
                .Include(j => j.Desarrolladoras)
                .Include(j => j.Publishers)
                .Include(j => j.SistemasOperativos)
                .Include(j => j.Productos)
                    .ThenInclude(p => p.PreciosProductos)
                    .Include(j => j.Dlcs) 
                .ThenInclude(dlc => dlc.Productos) 
                .ThenInclude(p_dlc => p_dlc.PreciosProductos)
                .FirstOrDefaultAsync(j => j.IdJuego == id);
        }

        public async Task<IEnumerable<Juego>> GetAllConDetallesAsync()
        {
            return await _context.Juegos
                .Include(j => j.Pegi)
                .Include(j => j.Generos)
                .Include(j => j.Etiquetas)
                .Include(j => j.Desarrolladoras)
                .Include(j => j.Publishers)
                .Include(j => j.SistemasOperativos)
                .Include(j => j.Productos)
                    .ThenInclude(p => p.PreciosProductos)
                .ToListAsync();
        }

        // Obtiene juegos con paginación + total de registros
        public async Task<(IEnumerable<Juego> Items, int TotalCount)> GetPagedConDetallesAsync(int pageNumber, int pageSize)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 20;

            var query = _context.Juegos
                .Include(j => j.Pegi)
                .Include(j => j.Generos)
                .Include(j => j.Etiquetas)
                .Include(j => j.Desarrolladoras)
                .Include(j => j.Publishers)
                .Include(j => j.SistemasOperativos)
                .Include(j => j.Productos)
                    .ThenInclude(p => p.PreciosProductos)
                .AsQueryable();

            var totalCount = await query.CountAsync();

            var items = await query
                .OrderBy(j => j.IdJuego)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, totalCount);
        }
        public async Task<(IEnumerable<Juego> Items, int TotalCount)> GetJuegosFiltradosPaginadosAsync(
            int pageNumber,       
            int pageSize,         
            int? idGenero,        
            int? idPublisher,     
            int? idEtiqueta,
            string? Nombre
            )
        {
            var query = _context.Juegos.AsQueryable();

            if (idGenero.HasValue)
            {
                query = query.Where(j => j.Generos.Any(jg => jg.IdGenero == idGenero.Value));
            }

            if (idPublisher.HasValue)
            {
                query = query.Where(j => j.Publishers.Any(jp => jp.IdPublisher == idPublisher.Value));
            }

            if (idEtiqueta.HasValue)
            {
                query = query.Where(j => j.Etiquetas.Any(je => je.IdEtiqueta == idEtiqueta.Value));
            }
            if(!string.IsNullOrEmpty(Nombre))
            {
                query = query.Where(j => j.Nombre.Contains(Nombre));
            }

            var totalCount = await query.CountAsync();

            if (totalCount == 0)
            {
                return (new List<Juego>(), 0);
            }

            var items = await query
                .Include(j => j.Pegi)
                .Include(j => j.Generos)
                .Include(j => j.Productos).ThenInclude(p => p.PreciosProductos)
                .OrderBy(j => j.Nombre)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, totalCount);
        }

        public async Task CambiarEstadoAsync(int id, bool cancelar)
        {
            if (cancelar)
            {
                await _context.Juegos
                    .Where(j => j.IdJuego == id)
                    .ExecuteUpdateAsync(j => j.SetProperty(
                        juego => juego.Estado,
                        juego => juego.Estado == "Publicado" ? "No Disponible" : "Publicado"));
            }
            else
            {
                await _context.Juegos
                    .Where(j => j.IdJuego == id)
                    .ExecuteUpdateAsync(j => j.SetProperty(
                        juego => juego.Estado,
                        juego => juego.Estado == "No Disponible" ? "Publicado" : "No Disponible"));
            }
        }

        public async Task UpdateJuegoAsync(Juego juego)
        {
            await _context.Juegos
                .Where(j => j.IdJuego == juego.IdJuego)
                .ExecuteUpdateAsync(j => j
                    .SetProperty(juego => juego.Nombre, juego.Nombre)
                    .SetProperty(juego => juego.Descripcion, juego.Descripcion)
                    .SetProperty(juego => juego.FechaLanzamiento, juego.FechaLanzamiento)
                    .SetProperty(juego => juego.IdPegi, juego.IdPegi)
                    .SetProperty(juego => juego.Estado, juego.Estado)
                );
        }
    }
}

