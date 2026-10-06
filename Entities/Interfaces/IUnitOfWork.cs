using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        IJuegoRepository Juegos { get; }
        IRepository<Producto> Productos { get; }
        IRepository<Genero> Generos { get; }
        IRepository<Etiqueta> Etiquetas { get; }
        IRepository<Desarrolladora> Desarrolladoras { get; }
        IRepository<Publisher> Publishers { get; }
        IRepository<SistemasOperativo> SistemasOperativos { get; }
        IRepository<PreciosProducto> PreciosProductos { get; }
        ITransaccionRepository Transacciones { get; }
        IRepository<Dlc> Dlcs { get; }
        IEstadisticasRepository Estadisticas { get; }
        IRepository<Usuario> Usuarios { get; }
        IRepository<Pegi> PegiTipos { get; }

        //metodo para guardar todo
        Task<int> SaveChangesAsync();
    }
}
