using Application.DTOs.Dlcs;
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
    public class DlcServicio : IDlcServicio
    {
        private readonly IUnitOfWork _unitOfWork;
        public DlcServicio(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task<DlcRespuestaDto> CreateDlcAsync(DlcsCrearDto dlcDto)
        {
            var juegoBase = await _unitOfWork.Juegos.GetByIdAsync(dlcDto.IdJuegoBase);
            if (juegoBase == null)
            {
                throw new Exception("El juego base especificado no existe.");
            }
            var nuevoDlc = new Dlc
            {
                IdJuego = dlcDto.IdJuegoBase,
                Nombre = dlcDto.Nombre,
                Descripcion = dlcDto.Descripcion,
                FechaLanzamiento = dlcDto.FechaLanzamiento,
                IdPegi = dlcDto.IdPegi,
                Estado = "Publicado" 
            };
            var nuevoProducto = new Producto
            {
                Tipo = "DLC"
            };
            var nuevoPrecio = new PreciosProducto
            {
                Precio = dlcDto.PrecioInicial,
                FechaInicio = DateOnly.FromDateTime(DateTime.Now)
            };
            nuevoProducto.PreciosProductos.Add(nuevoPrecio);
            nuevoDlc.Productos.Add(nuevoProducto);
            await _unitOfWork.Dlcs.AddAsync(nuevoDlc);
            await _unitOfWork.SaveChangesAsync();
            return new DlcRespuestaDto
            {
                IdDlc = nuevoDlc.IdDlc,
                Nombre = nuevoDlc.Nombre,
                IdProducto = juegoBase.IdJuego,
                PrecioActual = nuevoPrecio.Precio
            };
        }
    }
}
