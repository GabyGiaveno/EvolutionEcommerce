using Entities.Interfaces;
using Entities.Models;
using Microsoft.AspNetCore.Mvc;

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PegiController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;

        public PegiController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        // GET: api/Pegi
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Pegi>>> GetPegiTipos()
        {
            // Usamos el repositorio genérico para la entidad Pegi
            var pegiTipos = await _unitOfWork.PegiTipos.GetAllAsync();
            return Ok(pegiTipos);
        }
    }
}