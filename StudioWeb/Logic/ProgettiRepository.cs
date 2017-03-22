using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using StudioWeb.Models;

namespace StudioWeb.Logic
{
    public class ProgettiRepository : IRepository<Progetto>
    {
        // DbContext
        private readonly StudioWebContext _context;

        public ProgettiRepository()
        {
            _context = new StudioWebContext();            
        }

        public IEnumerable<Progetto> List => _context.Progetti;

        public void Add(Progetto entity)
        {
            _context.Progetti.Add(entity);
            _context.SaveChanges();
        }

        public void Delete(Progetto entity)
        {
            _context.Progetti.Remove(entity);
            _context.SaveChanges();
        }

        public Progetto FindById(int id)
        {
            var result = (from r in _context.Progetti where r.Id == id select r).FirstOrDefault();
            return result;
        }

        public void Update(Progetto entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }
    }
}