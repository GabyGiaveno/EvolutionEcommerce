using Entities.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GenerosController : ControllerBase
    {
        // GET: api/<GenerosController>
        private readonly IUnitOfWork _unitOfWork;

        public GenerosController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        // GET: api/generos
        [HttpGet]
        public async Task<IActionResult> GetGeneros()
        {
            // usamos unit of work en el repo generico, no necesito mas logica, solo la del generico
            var generos = await _unitOfWork.Generos.GetAllAsync();
            return Ok(generos);
        }

    }
}
