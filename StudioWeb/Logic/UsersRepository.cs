using StudioWeb.Models;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;

namespace StudioWeb.Logic
{
    public class UsersRepository : IRepository<User>
    {
        // DbContext
        private readonly StudioWebContext _context;

        public UsersRepository()
        {
            _context = new StudioWebContext();
            _context.Database.Log = x => Debug.WriteLine(x);
        }

        public IEnumerable<User> List => _context.Users;

        public void Add(User entity)
        {
            _context.Users.Add(entity);
            _context.SaveChanges();
        }

        public void Delete(User entity)
        {
            _context.Users.Remove(entity);
            _context.SaveChanges();
        }

        public void Update(User entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }

        public User FindById(int Id)
        {
            var result = (from r in _context.Users where r.Id == Id select r).FirstOrDefault();
            return result;
        }        
    }
}