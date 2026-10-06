using Entities.Interfaces;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Evolution.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PublishersController : ControllerBase
    {
        // GET: api/<PublishersController>
        private readonly IUnitOfWork _unitOfWork;

        public PublishersController(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        // GET: api/Publishers
        [HttpGet]
        public async Task<IActionResult> GetPublishers()
        {
            // usamos unit of work en el repo generico, no necesito mas logica, solo la del generico
            var publishers = await _unitOfWork.Publishers.GetAllAsync();
            return Ok(publishers);
        }
    }
}
