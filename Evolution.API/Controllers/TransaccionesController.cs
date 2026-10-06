using Application.DTOs.Transacciones;
using Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TransaccionesController : ControllerBase
    {
        private readonly ITransaccionServicio _transaccionServicio;

        public TransaccionesController(ITransaccionServicio transaccionServicio)
        {
            _transaccionServicio = transaccionServicio;
        }
        // GET: api/<TransaccionesController>
        [HttpGet]
        public async Task<IActionResult> GetTransacciones(
            [FromQuery] string sortColumn = "fecha",
            [FromQuery] string sortOrder = "desc"
            )
        {
            var transacciones = await _transaccionServicio.GetAllTransaccionesAsync(sortColumn, sortOrder);
            return Ok(transacciones);
        }

        // GET api/<TransaccionesController>/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTransaccion(int id)
        {
            var transaccion = await _transaccionServicio.GetTransaccionByIdAsync(id);
            if (transaccion == null)
            {
                return NotFound();
            }
            return Ok(transaccion);
        }

        [HttpGet("paginadas")]
        public async Task<IActionResult> GetTransaccionesPaginadas([FromQuery] TransaccionFiltroQueryDto filtroQueryDto)
        {
            var pagedResult = await _transaccionServicio.GetTransaccionesFiltradasPaginadasAsync(filtroQueryDto);
            return Ok(pagedResult);
        }

        [HttpPost]
        public async Task<IActionResult> CrearTransaccion([FromBody] TransaccionCrearDto transaccionDto)
        {
            if (transaccionDto == null || transaccionDto.IdsProductos == null || !transaccionDto.IdsProductos.Any())
            {
                return BadRequest("No se proporcionaron productos para la transacción.");
            }

            try
            {
                var idUsuarioDelToken = User.FindFirstValue(ClaimTypes.NameIdentifier);

                if (string.IsNullOrEmpty(idUsuarioDelToken))
                {
                    return Unauthorized("Token inválido o no contiene ID de usuario.");
                }
                transaccionDto.IdUsuario = int.Parse(idUsuarioDelToken);
                var nuevaTransaccion = await _transaccionServicio.CrearTransaccionAsync(transaccionDto);

                // Devuelve un 201 Created con la ubicación del nuevo recurso y el recurso mismo
                return CreatedAtAction(nameof(GetTransaccion), new { id = nuevaTransaccion.IdTransaccion }, nuevaTransaccion);
            }
            catch (Exception ex)
            {
                // Manejo de errores (ej. producto no encontrado, precio no encontrado)
                return StatusCode(500, $"Error interno al crear la transacción: {ex.Message}");
            }
        }


    }
}
