using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.DTOs.Paginacion;

namespace Application.DTOs.Transacciones
{
    public class TransaccionFiltroQueryDto : PaginacionQueryDto
    {
        public int? IdUsuario { get; set; }
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
        public string SortColumn { get; set; } = "Fecha";
        public string SortOrder { get; set; } = "asc";
    }
}
