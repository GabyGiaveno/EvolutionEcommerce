using Entities.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EtiquetasController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public EtiquetasController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        // GET: api/Etiquetas
        [HttpGet]
        public async Task<IActionResult> GetEtiquetas()
        {
            // usamos unit of work en el repo generico, no necesito mas logica, solo la del generico
            var Etiquetas = await _unitOfWork.Etiquetas.GetAllAsync();
            return Ok(Etiquetas);
        }
    }
}
