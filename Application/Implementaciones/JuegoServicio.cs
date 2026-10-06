
using Application.DTOs;
using Application.DTOs.Dlcs;
using Application.DTOs.Juegos;
using Application.DTOs.Paginacion;
using Application.Interfaces;    
using Entities.Interfaces;
using Entities.Models;
using System.Linq;

namespace Application.Implementaciones
{
    public class JuegoServicio : IJuegosServicio
    {
        private readonly IUnitOfWork _unitOfWork;

        public JuegoServicio(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<JuegosRespuestaDto?> GetJuegoByIdAsync(int id)
        {
            var juego = await _unitOfWork.Juegos.GetByIdConDetallesAsync(id);
            if (juego is null) return null;
            return MapJuegoToDto(juego);
        }

        public async Task<IEnumerable<JuegosRespuestaDto>> GetAllJuegosAsync()
        {
            var juegos = await _unitOfWork.Juegos.GetAllConDetallesAsync();
            return juegos.Select(MapJuegoToDto).ToList();
        }

        public async Task<PagedResultDto<JuegosRespuestaDto>> GetJuegosPaginadosAsync(int page, int pageSize)
        {
            var (items, totalCount) = await _unitOfWork.Juegos.GetPagedConDetallesAsync(page, pageSize);

            var records = items.Select(MapJuegoToDto).ToList();

            return new PagedResultDto<JuegosRespuestaDto>(records, totalCount, page, pageSize);
        }
        public async Task CreateJuegoAsync(JuegosCrearDto juegoDto)
        {
            try
            {
                var juego = new Juego
                {
                    Nombre = juegoDto.Nombre,
                    Descripcion = juegoDto.Descripcion,
                    FechaLanzamiento = juegoDto.FechaLanzamiento,
                    IdPegi = juegoDto.IdPegi,
                    Estado = juegoDto.Estado ?? "Publicado",
                    PortadaUrl = juegoDto.PortadaUrl
                };
                foreach (var idGenero in juegoDto.IdsGeneros)
                {
                    var genero = await _unitOfWork.Generos.GetByIdAsync(idGenero);
                    if (genero != null)
                    {
                        juego.Generos.Add(genero);
                    }
                }
                foreach (var idEtiqueta in juegoDto.IdsEtiquetas)
                {
                    var etiqueta = await _unitOfWork.Etiquetas.GetByIdAsync(idEtiqueta);
                    if (etiqueta != null)
                    {
                        juego.Etiquetas.Add(etiqueta);
                    }
                }
                foreach (var idDesarrolladora in juegoDto.IdsDesarrolladoras)
                {
                    var desarrolladora = await _unitOfWork.Desarrolladoras.GetByIdAsync(idDesarrolladora);
                    if (desarrolladora != null)
                    {
                        juego.Desarrolladoras.Add(desarrolladora);
                    }
                }
                foreach (var idPublisher in juegoDto.IdsPublishers)
                {
                    var publisher = await _unitOfWork.Publishers.GetByIdAsync(idPublisher);
                    if (publisher != null)
                    {
                        juego.Publishers.Add(publisher);
                    }
                }
                foreach (var idSistemaOperativo in juegoDto.IdsSistemasOperativos)
                {
                    var sistemaOperativo = await _unitOfWork.SistemasOperativos.GetByIdAsync(idSistemaOperativo);
                    if (sistemaOperativo != null)
                    {
                        juego.SistemasOperativos.Add(sistemaOperativo);
                    }
                }

                await _unitOfWork.Juegos.AddAsync(juego);

                var productoJuego = new Producto
                {
                    Juego = juego,
                    Tipo = "Juego"
                };
                await _unitOfWork.Productos.AddAsync(productoJuego);

                var precioJuego = new PreciosProducto
                {
                    Producto = productoJuego,
                    Precio = juegoDto.PrecioInicial,
                    FechaInicio = DateOnly.FromDateTime(DateTime.Now)
                };
                await _unitOfWork.PreciosProductos.AddAsync(precioJuego);


                if (juegoDto.Dlcs != null && juegoDto.Dlcs.Any())
                {
                    foreach (var dlcDto in juegoDto.Dlcs)
                    {
                        var dlc = new Dlc
                        {
                            IdJuego = juego.IdJuego,
                            Nombre = dlcDto.Nombre,
                            Descripcion = dlcDto.Descripcion,
                            FechaLanzamiento = dlcDto.FechaLanzamiento,
                            IdPegi = dlcDto.IdPegi,
                            Estado = "Publicado",
                            Juego = juego
                        };


                        juego.Dlcs.Add(dlc);


                        var productoDlc = new Producto
                        {
                            Dlc = dlc,
                            Tipo = "DLC"
                        };
                        await _unitOfWork.Productos.AddAsync(productoDlc);

                        var precioDlc = new PreciosProducto
                        {
                            Producto = productoDlc,
                            Precio = dlcDto.PrecioInicial,
                            FechaInicio = DateOnly.FromDateTime(DateTime.Now)
                        };
                        await _unitOfWork.PreciosProductos.AddAsync(precioDlc);
                    }
                }
                await _unitOfWork.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                throw new Exception("Error al crear el juego: " + ex.Message);
            }
        }


        public async Task UpdateJuegoAsync(int id, JuegosCrearDto juegoDto)
        {
            //var juegoActualizado = new Juego
            //{
            //    IdJuego = id,
            //    Nombre = juegoDto.Nombre,
            //    Descripcion = juegoDto.Descripcion,
            //    FechaLanzamiento = juegoDto.FechaLanzamiento,
            //    Dlcs = juegoDto.Dlcs.Select(dlcDto => new Dlc
            //    {
            //        IdJuego = id,
            //        Nombre = dlcDto.Nombre,
            //        Descripcion = dlcDto.Descripcion,
            //        FechaLanzamiento = dlcDto.FechaLanzamiento,
            //        IdPegi = dlcDto.IdPegi,
            //        Estado = "Publicado"
            //    }).ToList(),
            //    IdPegi = juegoDto.IdPegi,
            //    Estado = juegoDto.Estado ?? "Publicado",

            //};
            var juego = await _unitOfWork.Juegos.GetByIdConDetallesAsync(id);

            if (juego == null)
            {
                // Si el juego no existe, lanza exc
                throw new Exception("Juego no encontrado");
            }
            // propiedades escalares
            juego.Nombre = juegoDto.Nombre;
            juego.Descripcion = juegoDto.Descripcion;
            juego.FechaLanzamiento = juegoDto.FechaLanzamiento;
            juego.IdPegi = juegoDto.IdPegi;
            juego.Estado = juegoDto.Estado ?? "Publicado";
            //actualizar relaciones
            //  actualiza generos
            juego.Generos.Clear();
            foreach (var idGenero in juegoDto.IdsGeneros)
            {
                var genero = await _unitOfWork.Generos.GetByIdAsync(idGenero);
                if (genero != null)
                {
                    juego.Generos.Add(genero);
                }
            }
            juego.Etiquetas.Clear();
            foreach (var idEtiqueta in juegoDto.IdsEtiquetas)
            {
                var etiqueta = await _unitOfWork.Etiquetas.GetByIdAsync(idEtiqueta);
                if (etiqueta != null)
                {
                    juego.Etiquetas.Add(etiqueta);
                }
            }
            juego.Desarrolladoras.Clear();
            foreach (var idDesarrolladora in juegoDto.IdsDesarrolladoras)
            {
                var desarrolladora = await _unitOfWork.Desarrolladoras.GetByIdAsync(idDesarrolladora);
                if (desarrolladora != null)
                {
                    juego.Desarrolladoras.Add(desarrolladora);
                }
            }
            juego.Publishers.Clear();
            foreach (var idPublisher in juegoDto.IdsPublishers)
            {
                var publisher = await _unitOfWork.Publishers.GetByIdAsync(idPublisher);
                if (publisher != null)
                {
                    juego.Publishers.Add(publisher);
                }
            }
            juego.SistemasOperativos.Clear();
            foreach (var idSistemaOperativo in juegoDto.IdsSistemasOperativos)
            {
                var sistemaOperativo = await _unitOfWork.SistemasOperativos.GetByIdAsync(idSistemaOperativo);
                if (sistemaOperativo != null)
                {
                    juego.SistemasOperativos.Add(sistemaOperativo);
                }
            }

            // Actualizar  Precio
            // busca el producto asociado a este juego
            var productoJuego = juego.Productos.FirstOrDefault(p => p.IdJuego == id);
            if (productoJuego != null)
            {
                // precio mas reciente
                var precioActual = productoJuego.PreciosProductos
                    .OrderByDescending(p => p.FechaInicio)
                    .ThenByDescending(p => p.IdPrecioProducto)
                    .FirstOrDefault();

                // Si el precio del DTO es diferente al actual, agregamos un nuevo registro de precio
                if (precioActual == null || precioActual.Precio != juegoDto.PrecioInicial)
                {
                    var nuevoPrecio = new PreciosProducto
                    {
                        Producto = productoJuego,
                        Precio = juegoDto.PrecioInicial,
                        FechaInicio = DateOnly.FromDateTime(DateTime.Now)
                    };
                    await _unitOfWork.PreciosProductos.AddAsync(nuevoPrecio);
                }
            }
            //dlc
            var dlcsEnDto = juegoDto.Dlcs ?? new List<DlcsCrearDto>();
            var dlcsEnDb = juego.Dlcs.ToList(); // Copia local

            // Actualiza o Deshabilita los DLCs que ya están en la BD
            foreach (var dlcDb in dlcsEnDb)
            {
                // Buscar el Dlc de la BD en el DTO CON EL NOMBRE
                var dlcDto = dlcsEnDto.FirstOrDefault(d => d.Nombre.Equals(dlcDb.Nombre, StringComparison.OrdinalIgnoreCase));

                if (dlcDto != null)
                {
                    // SI LO ENCUENTRA LO PUBLICA CAMBIA SU ESTADO
                    dlcDb.Descripcion = dlcDto.Descripcion;
                    dlcDb.FechaLanzamiento = dlcDto.FechaLanzamiento;
                    dlcDb.IdPegi = dlcDto.IdPegi;
                    dlcDb.Estado = "Publicado"; 

                    // Actualizar precio
                    var productoDlc = (await _unitOfWork.Productos.FindAsync(p => p.IdDlc == dlcDb.IdDlc)).FirstOrDefault();
                    if (productoDlc != null)
                    {
                        var precioDlcActual = (await _unitOfWork.PreciosProductos
                            .FindAsync(p => p.IdProducto == productoDlc.IdProducto))
                            .OrderByDescending(p => p.FechaInicio)
                            .FirstOrDefault();

                        if (precioDlcActual == null || precioDlcActual.Precio != dlcDto.PrecioInicial)
                        {
                            await _unitOfWork.PreciosProductos.AddAsync(new PreciosProducto
                            {
                                Producto = productoDlc,
                                Precio = dlcDto.PrecioInicial,
                                FechaInicio = DateOnly.FromDateTime(DateTime.Now)
                            });
                        }
                    }
                }
                else
                {
                    // si no encuentra dlc
                    // El usuario lo borró de la lista en el frontend.
                    // se actualiza de la lista y lo inhabilita
                    dlcDb.Estado = "No Habilitado";
                }
            }

            //  Añadir los DLCs nuevos
            foreach (var dlcDto in dlcsEnDto)
            {
                // Buscar si el Dlc del DTO ya existe en la BD
                bool existeEnDb = dlcsEnDb.Any(d => d.Nombre.Equals(dlcDto.Nombre, StringComparison.OrdinalIgnoreCase));

                if (!existeEnDb)
                {
                    // dlc nuevo
                    var dlcNuevo = new Dlc
                    {
                        Nombre = dlcDto.Nombre,
                        Descripcion = dlcDto.Descripcion,
                        FechaLanzamiento = dlcDto.FechaLanzamiento,
                        IdPegi = dlcDto.IdPegi,
                        Estado = "Publicado",
                        Juego = juego // Se asocia al juego
                    };
                    juego.Dlcs.Add(dlcNuevo); // EF sabe que esto es un 'Add'

                    var productoDlc = new Producto
                    {
                        Dlc = dlcNuevo,
                        Tipo = "DLC"
                    };
                    await _unitOfWork.Productos.AddAsync(productoDlc);

                    var precioDlc = new PreciosProducto
                    {
                        Producto = productoDlc,
                        Precio = dlcDto.PrecioInicial,
                        FechaInicio = DateOnly.FromDateTime(DateTime.Now)
                    };
                    await _unitOfWork.PreciosProductos.AddAsync(precioDlc);
                }
            }
            await _unitOfWork.SaveChangesAsync();
        }        

        private static JuegosRespuestaDto MapJuegoToDto(Juego j)
        {
            var productoJuego = j.Productos?
                .FirstOrDefault(p => p.IdJuego == j.IdJuego) ??
                j.Productos?.FirstOrDefault();

            decimal precioActual = 0;
            if (productoJuego != null && productoJuego.PreciosProductos.Any())
            {
                precioActual = productoJuego.PreciosProductos
                    .OrderByDescending(p => p.FechaInicio)
                    .ThenByDescending(p => p.IdPrecioProducto)
                    .First()
                    .Precio;
            }
            var listaDlcsDto = new List<DlcRespuestaDto>();

            foreach (var dlc in j.Dlcs.Where(d => d.Estado == "Publicado"))
            {
                decimal precioDlc = 0;
                var productoDlc = dlc.Productos?.FirstOrDefault(p => p.IdDlc == dlc.IdDlc);

                if (productoDlc != null && productoDlc.PreciosProductos.Any())
                {
                    precioDlc = productoDlc.PreciosProductos
                                    .OrderByDescending(p => p.FechaInicio)
                                    .ThenByDescending(p => p.IdPrecioProducto)
                                    .First()
                                    .Precio;
                }

                listaDlcsDto.Add(new DlcRespuestaDto
                {
                    IdDlc = dlc.IdDlc,
                    IdProducto = productoDlc?.IdProducto ?? 0,
                    Nombre = dlc.Nombre,
                    Descripcion = dlc.Descripcion,
                    PrecioActual = precioDlc,
                    IdPegi = dlc.IdPegi
                });
            }
            return new JuegosRespuestaDto
            {
                Nombre = j.Nombre,
                IdJuego = j.IdJuego,
                IdProducto = productoJuego?.IdProducto ?? 0,
                Descripcion = j.Descripcion,
                FechaLanzamiento = j.FechaLanzamiento,
                IdPegi = j.IdPegi,
                ClasificacionPegi = j.Pegi?.Descripcion ?? string.Empty,
                PrecioActual = precioActual,
                ImagenUrl = j.ImagenUrl,
                PortadaUrl = j.PortadaUrl,
                Estado = j.Estado,
                Generos = j.Generos.Select(g => g.Nombre).ToList(),
                Etiquetas = j.Etiquetas.Select(e => e.Nombre).ToList(),
                Desarrolladoras = j.Desarrolladoras.Select(d => d.Nombre).ToList(),
                Publishers = j.Publishers.Select(p => p.Nombre).ToList(),
                SistemasOperativos = j.SistemasOperativos.Select(s => s.Nombre).ToList(),
                Dlcs = listaDlcsDto
            };
        }
        public async Task<PagedResultDto<JuegosRespuestaDto>> GetJuegosPaginadosAsync(JuegosFiltroQueryDto filtroQuery)
        {
            var (items, totalCount) = await _unitOfWork.Juegos.GetJuegosFiltradosPaginadosAsync(
                filtroQuery.PageNumber,
                filtroQuery.PageSize,
                filtroQuery.IdGenero,
                filtroQuery.IdPublisher,
                filtroQuery.IdEtiqueta,
                filtroQuery.Nombre
            );

            var records = items.Select(MapJuegoToDto).ToList();

            return new PagedResultDto<JuegosRespuestaDto>(records, totalCount, filtroQuery.PageNumber, filtroQuery.PageSize);
        }

        public async Task CambiarEstadoAsync(int id, bool cancelar)
        {
            await _unitOfWork.Juegos.CambiarEstadoAsync(id, cancelar);
        }
    }
}
