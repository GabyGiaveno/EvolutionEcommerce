using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Auth
{
    public class AuthRespuestaDto
    {
        public string Token { get; set; }
        public string Email { get; set; }
        public string NombreUsuario { get; set; }
        public string Rol { get; set; }
        public int IdUsuario { get; set; }
    }
}
