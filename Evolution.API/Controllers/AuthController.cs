using Application.DTOs.Auth;
using Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthServicio _authServicio;

        public AuthController(IAuthServicio authServicio)
        {
            _authServicio = authServicio;
        }
        // GET: api/<AuthController>
        [HttpPost("register")]
        public async Task<ActionResult<AuthRespuestaDto>> Register(UsuarioRegisterDto dto)
        {
            try
            {
                var respuesta = await _authServicio.RegisterAsync(dto);
                return Ok(respuesta);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthRespuestaDto>> Login(UsuarioLoginDto dto)
        {
            try
            {
                var respuesta = await _authServicio.LoginAsync(dto);
                return Ok(respuesta);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message); // "Usuario o contrase;a incorrectos"
            }
        }
    }
}
