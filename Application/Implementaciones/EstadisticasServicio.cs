using Application.DTOs.EstadisticasDtos;
using Application.Interfaces;
using Entities.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Implementaciones
{
    public class EstadisticasServicio : IEstadisticasServicio
    {
        private readonly IUnitOfWork _unitOfWork;

        public EstadisticasServicio(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task<IEnumerable<ReporteJuegoDlcDto>> GetReporteJuegoDlcAsync()
        {

            //Obtener el resultado del Dominio
            var resultadoRepo = await _unitOfWork.Estadisticas.GetReporteJuegoDlcAsync();

            //Mapear a DTO
            return resultadoRepo.Select(r => new ReporteJuegoDlcDto
            {
                JuegoBase = r.JuegoBase,
                CantidadDLCs = r.CantidadDLCs,
                VentasJuegoBase = r.VentasJuegoBase,
                VentasDLCs = r.VentasDLCs,
                IngresosJuegoBase = r.IngresosJuegoBase,
                IngresosDLCs = r.IngresosDLCs
            });
        }
        public async Task<IEnumerable<ReporteUsuariosMayorGastoDto>> GetReporteUsuariosMayorGastoAsync()
        {
            //Obtener el resultado del Dominio
            var resultadoRepo = await _unitOfWork.Estadisticas.GetReporteUsuarioMayorGastoAsync();
            // Mapear a DTO
            return resultadoRepo.Select(r => new ReporteUsuariosMayorGastoDto
            {
                NombreUsuario = r.NombreUsuario,
                TotalGastado = r.TotalGastado,
                CantidadTransacciones = r.CantidadTransacciones
            });
        }
        public async Task<IEnumerable<ReportePublishersIngresoDto>> GetReportePublishersIngresoAsync()
        {
            //Obtener el resultado del Dominio
            var resultadoRepo = await _unitOfWork.Estadisticas.GetReportePublishersIngresosAsync();
            // Mapear a DTO
            return resultadoRepo.Select(r => new ReportePublishersIngresoDto
            {
                Publisher = r.Publisher,
                UnidadesVendidas = r.UnidadesVendidas,
                TotalRecaudado = r.TotalRecaudado
            });
        }
    }

}
