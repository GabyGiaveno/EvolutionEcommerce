using Entities.Interfaces;
using Entities.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Persistance.Repositories.Implementacion
{
    public class TransaccionRepository : Repository<Transaccione>, ITransaccionRepository
    {
        public TransaccionRepository(EvolutionDBContext context) : base(context)
        {
        }

        public async Task<IEnumerable<Transaccione>> GetTransaccionesCompletasAsync(string sortColumn, string sortOrder, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var query = _context.Transacciones
                .Include(t => t.Usuario)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.PrecioProducto)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.DescuentoProducto)
                .AsQueryable();
            bool isAscending = sortOrder.ToLower() == "asc";
            switch (sortColumn.ToLower())
            {
                case "total":
                    if (isAscending)
                    {
                        query = query.OrderBy(t => t.DetallesTransacciones.Sum(dt =>
                            dt.DescuentoProducto == null
                            ? dt.PrecioProducto.Precio
                            : dt.PrecioProducto.Precio * (1 - (dt.DescuentoProducto.Porcentaje / 100))
                        ));
                    }
                    else
                    {
                        query = query.OrderByDescending(t => t.DetallesTransacciones.Sum(dt =>
                            dt.DescuentoProducto == null
                            ? dt.PrecioProducto.Precio
                            : dt.PrecioProducto.Precio * (1 - (dt.DescuentoProducto.Porcentaje / 100))
                        ));
                    }
                    break;
                case "fecha":
                default:
                    if (isAscending)
                    {
                        query = query.OrderBy(t => t.Fecha);
                    }
                    else
                    {
                        query = query.OrderByDescending(t => t.Fecha);
                    }
                    break;
            }
            return await query.ToListAsync();
        }
        public async Task<Transaccione?> GetTransaccionDetalleAsync(int id)
        {
            return await _context.Transacciones
                .Include(t => t.Usuario)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.Producto)
                        .ThenInclude(p => p.Juego)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.Producto)
                        .ThenInclude(p => p.Dlc)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.PrecioProducto)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.DescuentoProducto)
                .FirstOrDefaultAsync(t => t.IdTransaccion == id);
        }

        public async Task<(IEnumerable<Transaccione> items, int totalCount)> GetTransaccionesFiltradasPaginadasAsync(string sortColumn, string sortOrder, int pageNumber, int pageSize, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var query = _context.Transacciones
                                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.PrecioProducto)
                .Include(t => t.DetallesTransacciones)
                    .ThenInclude(dt => dt.DescuentoProducto)
                .Include(t => t.Usuario)
                .AsQueryable();

            if (fechaInicio.HasValue)
            {
                query = query.Where(t => t.Fecha >= fechaInicio.Value.Date);
            }

            if (fechaFin.HasValue)
            {
                var fechaFinSiguiente = fechaFin.Value.Date.AddDays(1);
                query = query.Where(t => t.Fecha < fechaFinSiguiente);
            }

            bool isAscending = sortOrder.ToLower() == "asc";
            switch (sortColumn.ToLower())
            {
                case "total":
                    if (isAscending)
                    {
                        query = query.OrderBy(t => t.DetallesTransacciones.Sum(dt =>
                            dt.DescuentoProducto == null
                            ? dt.PrecioProducto.Precio
                            : dt.PrecioProducto.Precio * (1 - (dt.DescuentoProducto.Porcentaje / 100))
                        ));
                    }
                    else
                    {
                        query = query.OrderByDescending(t => t.DetallesTransacciones.Sum(dt =>
                            dt.DescuentoProducto == null
                            ? dt.PrecioProducto.Precio
                            : dt.PrecioProducto.Precio * (1 - (dt.DescuentoProducto.Porcentaje / 100))
                        ));
                    }
                    break;
                case "fecha":
                default:
                    if (isAscending)
                    {
                        query = query.OrderBy(t => t.Fecha);
                    }
                    else
                    {
                        query = query.OrderByDescending(t => t.Fecha);
                    }
                    break;
            }
            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, totalCount);
        }
    }
}
