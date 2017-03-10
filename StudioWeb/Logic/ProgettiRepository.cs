using System;
using System.Collections.Generic;
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
            throw new NotImplementedException();
        }

        public void Delete(Progetto entity)
        {
            throw new NotImplementedException();
        }

        public Progetto FindById(int id)
        {
            throw new NotImplementedException();
        }

        public void Update(Progetto entity)
        {
            throw new NotImplementedException();
        }
    }
}