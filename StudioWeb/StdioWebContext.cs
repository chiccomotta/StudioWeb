using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.ModelConfiguration.Conventions;
using System.Linq;
using System.Web;
using StudioWeb.Models;

namespace StudioWeb
{
    public class StudioWebContext : DbContext
    {
        public StudioWebContext()
        {
            // Turn off the Migrations, (NOT a code first Db)
            // Non tento di creare il DB se non esiste
            Database.SetInitializer<StudioWebContext>(null);
        }


        public DbSet<User> Users { get; set; }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            // se la tabella ha nome diverso dall'entità (Users e user) devo esplicitare il mapping
            modelBuilder.Entity<User>().ToTable("Users").HasKey(x => x.Id);

            // Database does not pluralize table names
            modelBuilder.Conventions.Remove<PluralizingTableNameConvention>();
        }
    }
}