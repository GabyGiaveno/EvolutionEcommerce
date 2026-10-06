using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Application.DTOs.Dlcs;
using Entities.Models;

namespace Application.DTOs.Juegos
{
    public class JuegosCrearDto
    {
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(100)]
        public string Nombre { get; set; }

        [StringLength(255)]
        public string? Descripcion { get; set; }

        [StringLength(500)]
        public string? PortadaUrl { get; set; }

        public DateOnly? FechaLanzamiento { get; set; }
        public string Estado { get; set; } = "Publicado";

        [Required(ErrorMessage = "La clasificación PEGI es obligatoria")]
        [Range(1, int.MaxValue)]
        public int IdPegi { get; set; }
        public ICollection<DlcsCrearDto> Dlcs { get; set; } = new List<DlcsCrearDto>();

        [Required(ErrorMessage = "El precio es obligatorio")]
        [Range(0, 99999.99, ErrorMessage = "El precio debe ser un valor positivo.")]
        public decimal PrecioInicial { get; set; }

        // El front-end manda una lista de IDs de géneros
        public List<int> IdsGeneros { get; set; } = new List<int>();

        // Lista de IDs de etiquetas
        public List<int> IdsEtiquetas { get; set; } = new List<int>();

        // Lista de IDs de desarrolladoras
        public List<int> IdsDesarrolladoras { get; set; } = new List<int>();

        // Lista de IDs de publishers
        public List<int> IdsPublishers { get; set; } = new List<int>();

        // Lista de IDs de so
        public List<int> IdsSistemasOperativos { get; set; } = new List<int>();
    }
}
