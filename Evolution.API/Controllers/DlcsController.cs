using Application.DTOs.Dlcs;
using Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DlcsController : ControllerBase
    {
        private readonly IDlcServicio _dlcServicio;
        public DlcsController(IDlcServicio dlcServicio)
        {
            _dlcServicio = dlcServicio;
        }
        [HttpPost]
        public async Task<IActionResult> CreateDlc([FromBody] DlcsCrearDto dlcDto)
        {
            try
            {
                var dlcCreado = await _dlcServicio.CreateDlcAsync(dlcDto);
                return CreatedAtAction(nameof(GetDlc), new { id = dlcCreado.IdDlc }, dlcCreado);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [HttpGet("{id}")]
        public async Task<IActionResult> GetDlc(int id)
        {
            // placeholder.
            return Ok(new { Message = "Endpoint GET de DLC aún no implementado, pero el POST funcionó." });
        }
    }
}
