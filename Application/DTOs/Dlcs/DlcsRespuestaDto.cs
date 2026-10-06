using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Dlcs
{
    public class DlcRespuestaDto
    {
        public int IdDlc { get; set; }
        public string Nombre { get; set; }
        public int IdProducto    { get; set; }
        public string Descripcion { get; set; }
        public decimal PrecioActual { get; set; }
        public int IdPegi { get; set; }

    }
}
