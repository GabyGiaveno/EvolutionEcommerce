using Application.DTOs.Auth;
using Application.Interfaces;
using Entities.Interfaces;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;     
using System.IdentityModel.Tokens.Jwt;               

namespace Application.Implementaciones
{
    public class AuthServicio : IAuthServicio
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _config;

        public AuthServicio(IUnitOfWork unitOfWork, IConfiguration config)
        {
            _unitOfWork = unitOfWork;
            _config = config;
        }
        public async Task<AuthRespuestaDto> RegisterAsync(UsuarioRegisterDto dto)
        {
            //Validar si usuario ya existe
            var existe = await _unitOfWork.Usuarios.FindAsync(u => u.Email == dto.Email || u.NombreUsuario == dto.NombreUsuario);
            if (existe.Any())
            {
                throw new Exception("El email o nombre de usuario ya está en uso.");
            }

            // Hash y Salt de la contraseña
            CrearPasswordHash(dto.Password, out byte[] passwordHash, out byte[] passwordSalt);

            // 3. Crear el nuevo usuario
            var usuario = new Usuario
            {
                Email = dto.Email,
                NombreUsuario = dto.NombreUsuario,
                Nombre = dto.Nombre,
                Apellido = dto.Apellido,
                FechaNacimiento = dto.FechaNacimiento,
                Rol = dto.Rol,
                FechaRegistro = DateOnly.FromDateTime(DateTime.Now),
                PasswordHash = passwordHash,
                PasswordSalt = passwordSalt
            };

            // 4. Guardar en la BD
            await _unitOfWork.Usuarios.AddAsync(usuario);
            await _unitOfWork.SaveChangesAsync();

            // 5. Devolver el token (como si hiciera login)
            return await LoginAsync(new UsuarioLoginDto { Email = dto.Email, Password = dto.Password });
        }

        // --- MÉTODO DE LOGIN ---
        public async Task<AuthRespuestaDto> LoginAsync(UsuarioLoginDto dto)
        {
            // 1. Buscar al usuario
            var usuario = (await _unitOfWork.Usuarios.FindAsync(u => u.Email == dto.Email)).FirstOrDefault();
            if (usuario == null)
            {
                throw new Exception("Usuario o contraseña incorrectos.");
            }

            // 2. Verificar la contraseña
            if (!VerificarPasswordHash(dto.Password, usuario.PasswordHash, usuario.PasswordSalt))
            {
                throw new Exception("Usuario o contraseña incorrectos.");
            }

            // 3. Generar el Token JWT
            string token = GenerarToken(usuario);

            return new AuthRespuestaDto
            {
                Token = token,
                Email = usuario.Email,
                NombreUsuario = usuario.NombreUsuario,
                Rol = usuario.Rol,
                IdUsuario = usuario.IdUsuario
            };
        }

        // --- HELPERS PRIVADOS ---

        private void CrearPasswordHash(string password, out byte[] passwordHash, out byte[] passwordSalt)
        {
            using (var hmac = new HMACSHA512())
            {
                passwordSalt = hmac.Key;
                passwordHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));
            }
        }

        private bool VerificarPasswordHash(string password, byte[] passwordHash, byte[] passwordSalt)
        {
            using (var hmac = new HMACSHA512(passwordSalt))
            {
                var computedHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));
                return computedHash.SequenceEqual(passwordHash);
            }
        }

        private string GenerarToken(Usuario usuario)
        {
            // Definir los Claims
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, usuario.IdUsuario.ToString()),
                new Claim(ClaimTypes.Email, usuario.Email),
                new Claim(ClaimTypes.Name, usuario.NombreUsuario),
                new Claim(ClaimTypes.Role, usuario.Rol)
            };

            // Obtener Clave 
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _config.GetSection("Jwt:Key").Value ?? throw new InvalidOperationException("No se encontró la clave JWT")));

            // Crear credenciales
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            // Crear el descriptor del token
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddDays(1), // Token válido por 1 día
                SigningCredentials = creds,
                Issuer = _config.GetSection("Jwt:Issuer").Value,
                Audience = _config.GetSection("Jwt:Audience").Value
            };

            // Crear el token
            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return tokenHandler.WriteToken(token); // Devolver token
        }
    }
}

