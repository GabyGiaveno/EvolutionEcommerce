using Entities.Models;
using Entities.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace Persistance.Repositories.Implementacion
{
    public class Repository<T> : IRepository<T> where T : class
    {
        protected readonly EvolutionDBContext _context;
        protected readonly DbSet<T> _dbset;
        public Repository(EvolutionDBContext context)
        {
            _context = context;
            _dbset = _context.Set<T>();
        }

        public async Task<T?> GetByIdAsync(int id)
        {
            return await _dbset.FindAsync(id);
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _dbset.ToListAsync();
        }

        public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> expression)
        {
            return await _dbset.Where(expression).ToListAsync();
        }

        public async Task<T> AddAsync(T entity)
        {
            return (await _dbset.AddAsync(entity)).Entity;
        }

        public async Task AddRangeAsync(IEnumerable<T> entities)
        {
            await _dbset.AddRangeAsync(entities);
        }

        public void Remove(T entity)
        {
            _dbset.Remove(entity);
        }

        public void RemoveRange(IEnumerable<T> entities)
        {
            _dbset.RemoveRange(entities);
        }

        public void Update(T entity)
        {
            _dbset.Update(entity);
        }
    }
}
