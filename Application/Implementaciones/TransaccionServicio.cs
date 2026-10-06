using Application.DTOs.Paginacion;
using Application.DTOs.Transacciones;
using Application.Interfaces;
using Entities.Interfaces;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Implementaciones
{
    public class TransaccionServicio : ITransaccionServicio
    {
        private readonly IUnitOfWork _unitOfWork;

        public TransaccionServicio(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<TransaccionDetalleDto> CrearTransaccionAsync(TransaccionCrearDto transaccionDto)
        {
            int idUsuarioTemporal = transaccionDto.IdUsuario;
            const int idMetodoPagoTemporal = 1; // hardcodeado para limitar complejidad

            var nuevaTransaccion = new Transaccione
            {
                IdUsuario = idUsuarioTemporal,
                IdMetodoPagoGuardado = idMetodoPagoTemporal,
                Fecha = DateTime.Now,
                Tipo = "Compra" 
            };

            // agregar la transacción principal primero
            await _unitOfWork.Transacciones.AddAsync(nuevaTransaccion);

            // procesamos cada producto del carrito
            foreach (var idProducto in transaccionDto.IdsProductos)
            {
                // obtener el precio actual del producto
                var precioActual = (await _unitOfWork.PreciosProductos
                                    .FindAsync(p => p.IdProducto == idProducto && p.FechaInicio <= DateOnly.FromDateTime(DateTime.Now)))
                                    .OrderByDescending(p => p.FechaInicio)
                                    .FirstOrDefault();

                if (precioActual == null)
                {
                    // tira excepcion si no encuentra el precio del producto
                    throw new Exception($"El producto con Id {idProducto} no tiene un precio válido.");
                }

                DescuentosProducto descuentoActual = null; // simplificación hasta implementar dctos

                // crear el detalle de la transacción
                var detalle = new DetallesTransaccione
                {
                    IdProducto = idProducto,
                    IdPrecioProducto = precioActual.IdPrecioProducto,
                    IdDescuentoProducto = descuentoActual?.IdDescuentoProducto,
                    Transaccion = nuevaTransaccion 
                };

                // agregar el detalle a la colección de la transacción
                nuevaTransaccion.DetallesTransacciones.Add(detalle);
                
            }

            await _unitOfWork.SaveChangesAsync();

            return await GetTransaccionByIdAsync(nuevaTransaccion.IdTransaccion);
        }

        public async Task<IEnumerable<TransaccionListaDto>> GetAllTransaccionesAsync(string sortColumn, string sortOrder, DateTime? fechaInicio = null, DateTime? fechaFin = null)
        {
            var transacciones = await _unitOfWork.Transacciones.GetTransaccionesCompletasAsync(sortColumn, sortOrder, fechaInicio, fechaFin);
            return transacciones.Select(t => new TransaccionListaDto
            {
                IdTransaccion = t.IdTransaccion,
                Fecha = t.Fecha,
                EmailUsuario = t.Usuario?.Email ?? "N/A",
                Tipo = t.Tipo,
                Total = t.DetallesTransacciones.Sum(dt => CalcularPrecioFinal(dt.PrecioProducto, dt.DescuentoProducto))
            });
        }

        public async Task<TransaccionDetalleDto> GetTransaccionByIdAsync(int id)
        {
            var t = await _unitOfWork.Transacciones.GetTransaccionDetalleAsync(id);
            if (t == null) return null;

            var detalleDto = new TransaccionDetalleDto
            {
                IdTransaccion = t.IdTransaccion,
                Fecha = t.Fecha,
                EmailUsuario = t.Usuario?.Email ?? "N/A",
                Tipo = t.Tipo,
            };

            foreach (var dt in t.DetallesTransacciones)
            {
                var productoDto = new ProductoTransaccionDto
                {
                    IdProducto = dt.IdProducto,
                    NombreProducto = dt.Producto?.Juego?.Nombre ?? dt.Producto?.Dlc?.Nombre ?? "Producto Desconocido",
                    PrecioOriginal = dt.PrecioProducto?.Precio ?? 0,
                    PrecioPagado = CalcularPrecioFinal(dt.PrecioProducto, dt.DescuentoProducto),
                    DescuentoAplicado = dt.DescuentoProducto?.Porcentaje
                };
                detalleDto.Productos.Add(productoDto);
            }

            detalleDto.TotalTransaccion = detalleDto.Productos.Sum(p => p.PrecioPagado);
            return detalleDto;
        }

        public async Task<PagedResultDto<TransaccionListaDto>> GetTransaccionesFiltradasPaginadasAsync(TransaccionFiltroQueryDto filtroQuery)
        {
            var (items, totalCount) = await _unitOfWork.Transacciones.GetTransaccionesFiltradasPaginadasAsync(
                            filtroQuery.SortColumn,
                            filtroQuery.SortOrder,
                            filtroQuery.PageNumber,
                            filtroQuery.PageSize,
                            filtroQuery.FechaDesde,
                            filtroQuery.FechaHasta
                        );
            var records = items.Select(t => new TransaccionListaDto
            {
                IdTransaccion = t.IdTransaccion,
                Fecha = t.Fecha,
                Total = t.DetallesTransacciones.Sum(dt => CalcularPrecioFinal(dt.PrecioProducto, dt.DescuentoProducto)),
                Tipo = t.Tipo,
                EmailUsuario = t.Usuario?.Email ?? "N/A"
            }).ToList();
            return new PagedResultDto<TransaccionListaDto>(records, totalCount, filtroQuery.PageNumber, filtroQuery.PageSize);
        }

        // metodo Helper Privado para Calcular Precios
        private decimal CalcularPrecioFinal(PreciosProducto precio, DescuentosProducto descuento)
        {
            if (precio == null) return 0;
            if (descuento == null) return precio.Precio;

            return precio.Precio * (1 - (descuento.Porcentaje / 100));
        }
    }
}
