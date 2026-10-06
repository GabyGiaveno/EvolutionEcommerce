using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Auth
{
    public class UsuarioRegisterDto
    {
        public string NombreUsuario { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Rol { get; set; }
        public DateOnly FechaNacimiento { get; set; }
    }
}
