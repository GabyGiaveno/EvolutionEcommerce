using Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EstadisticasController : ControllerBase
    {
        private readonly IEstadisticasServicio _estadisticasServicio;
        public EstadisticasController(IEstadisticasServicio estadisticasServicio)
        {
            _estadisticasServicio = estadisticasServicio;
        }
        [HttpGet("reporte-juego-dlc")]
        public async Task<IActionResult> GetReporteJuegoDlc()
        {
            var reporte = await _estadisticasServicio.GetReporteJuegoDlcAsync();
            return Ok(reporte);
        }
        [HttpGet("reporte-usuarios-mayor-gasto")]
        public async Task<IActionResult> GetReporteUsuariosMayorGasto()
        {
            var reporte = await _estadisticasServicio.GetReporteUsuariosMayorGastoAsync();
            return Ok(reporte);
        }
        [HttpGet("reporte-publishers-ingreso")]
        public async Task<IActionResult> GetReportePublishersIngreso()
        {
            var reporte = await _estadisticasServicio.GetReportePublishersIngresoAsync();
            return Ok(reporte);
        }
    }
}
