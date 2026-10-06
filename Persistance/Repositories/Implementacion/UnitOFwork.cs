
using Entities.Interfaces;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Persistance.Repositories.Implementacion
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly EvolutionDBContext _context;

        // Propiedades para los repositorios
        public IJuegoRepository Juegos { get; private set; } 
        public IRepository<Producto> Productos { get; private set; }
        public IRepository<Genero> Generos { get; private set; }
        public IRepository<Etiqueta> Etiquetas { get; private set; }
        public IRepository<Desarrolladora> Desarrolladoras { get; private set; }
        public IRepository<Publisher> Publishers { get; private set; }
        public IRepository<SistemasOperativo> SistemasOperativos { get; private set; }
        public IRepository<PreciosProducto> PreciosProductos { get; private set; }
        public ITransaccionRepository Transacciones { get; }
        public IRepository<Dlc> Dlcs { get; private set; }
        public IEstadisticasRepository Estadisticas { get; private set; }
        public IRepository<Usuario> Usuarios { get; private set; }
        public IRepository<Pegi> PegiTipos { get; private set; }

        public UnitOfWork(EvolutionDBContext context)
        {
            _context = context;

            // Inicializamos los repositorios, pasándoles el mismo DbContext
            //DLC
            Juegos = new JuegoRepository(_context);
            Productos = new Repository<Producto>(_context);
            Generos = new Repository<Genero>(_context);
            Etiquetas = new Repository<Etiqueta>(_context);
            Desarrolladoras = new Repository<Desarrolladora>(_context);
            Publishers = new Repository<Publisher>(_context);
            SistemasOperativos = new Repository<SistemasOperativo>(_context);
            PreciosProductos = new Repository<PreciosProducto>(_context);
            Dlcs = new Repository<Dlc>(_context);
            Estadisticas = new EstadisticasRepository(_context);
            Usuarios = new Repository<Usuario>(_context);
            Transacciones = new TransaccionRepository(_context);
            PegiTipos = new Repository<Pegi>(_context);
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}

