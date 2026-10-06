using Application.DTOs;
using Application.DTOs.Juegos;
using Application.DTOs.Paginacion;
using Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class JuegosController : ControllerBase
    {
        private readonly IJuegosServicio _juegoServicio;
        public JuegosController(IJuegosServicio juegoServicio)
        {
            _juegoServicio = juegoServicio;
        }

        // GET: api/juegos?page=1&pageSize=20
        [HttpGet]
        public async Task<ActionResult<PagedResultDto<JuegosRespuestaDto>>> GetJuegos([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var result = await _juegoServicio.GetJuegosPaginadosAsync(page, pageSize);
            return Ok(result);
        }

        // GET: api/juegos/5
        [HttpGet("{id}", Name = "GetJuegoById")]
        public async Task<ActionResult<JuegosRespuestaDto>> GetJuego(int id)
        {
            var juego = await _juegoServicio.GetJuegoByIdAsync(id);

            if (juego == null)
            {
                return NotFound(); 
            }

            return Ok(juego); 
        }
        // GET: api/juegos/paginados?PageNumber=1&PageSize=20&idGenero=2&idPublisher=3&idEtiqueta=5
        [HttpGet("paginados")]
        public async Task<ActionResult> GetJuegosPaginados(
        [FromQuery] JuegosFiltroQueryDto filtroQuery)
        {
            var pagedResult = await _juegoServicio.GetJuegosPaginadosAsync(filtroQuery);
            return Ok(pagedResult);
        }

        // POST: api/juegos
        [HttpPost]
        public async Task<ActionResult<JuegosRespuestaDto>> PostJuego(JuegosCrearDto crearDto)
        {
            try
            {
                await _juegoServicio.CreateJuegoAsync(crearDto);
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // PUT: api/juegos/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutJuego(int id, JuegosCrearDto crearDto)
        {
            try
            {
                await _juegoServicio.UpdateJuegoAsync(id, crearDto);
                return NoContent();
            }
            catch (Exception ex)
            {
                return NotFound(ex.Message);
            }
        }

        // PUT: api/juegos/5
        [HttpPut]
        public async Task<IActionResult> DeleteJuego([FromQuery] int id, [FromQuery] bool cancelar)
        {
            try
            {
                await _juegoServicio.CambiarEstadoAsync(id, cancelar);
                return NoContent();
            }
            catch (Exception ex)
            {
                return NotFound(ex.Message);
            }
        }
    }
}
