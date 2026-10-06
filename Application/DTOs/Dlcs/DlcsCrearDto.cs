using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Dlcs
{
    public class DlcsCrearDto
    {
        [Required]
        [Range(0, int.MaxValue, ErrorMessage = "El ID del juego base es obligatorio.")]
        public int IdJuegoBase { get; set; } 

        [Required]
        [StringLength(100)]
        public string Nombre { get; set; }

        [StringLength(255)]
        public string Descripcion { get; set; }

        public DateOnly? FechaLanzamiento { get; set; }

        [Required]
        [Range(1, int.MaxValue)]
        public int IdPegi { get; set; }

        [Required]
        [Range(0.00, 99999.99)]
        public decimal PrecioInicial { get; set; }
    }
}
