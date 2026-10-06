using Application.DTOs.Dlcs;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Juegos
{
    public class JuegosRespuestaDto
    {
        public int IdJuego { get; set; }
        public string Nombre { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly? FechaLanzamiento { get; set; }
        public decimal PrecioActual { get; set; }
        public string? ImagenUrl { get; set; }
        public string? PortadaUrl { get; set; }
        public string Estado { get; set; }
        public int IdPegi { get; set; }
        public string ClasificacionPegi { get; set; }
        public int IdProducto { get; set; }
        public List<string> Generos { get; set; }
        public List<string> Etiquetas { get; set; }
        public List<string> Desarrolladoras { get; set; }
        public List<string> Publishers { get; set; }
        public List<string> SistemasOperativos { get; set; }
        public List<DlcRespuestaDto> Dlcs { get; set; } = new List<DlcRespuestaDto>();
    }
}
