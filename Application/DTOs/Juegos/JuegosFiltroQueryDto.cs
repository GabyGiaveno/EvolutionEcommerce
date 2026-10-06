using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs
{
    public class JuegosFiltroQueryDto : PaginacionQueryDto
    {
        public int? IdGenero { get; set; }
        public int? IdPublisher { get; set; }
        public int? IdEtiqueta { get; set; }
        public string? Nombre { get; set; }

    }
}
