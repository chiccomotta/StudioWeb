using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public DbSet<Progetto> Progetti { get; set; }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            // Database does not pluralize table names
            modelBuilder.Conventions.Remove<PluralizingTableNameConvention>();

            // se la tabella ha nome diverso dall'entità (Users e User) devo esplicitare il mapping.
            // (In caso di chiave composta utilizzare un oggetto anonimo, es: (x => new {x.id, x.Nome})
            modelBuilder.Entity<User>().ToTable("Users").HasKey(x => x.Id);

            modelBuilder.Entity<Progetto>().ToTable("Progetti").HasKey(x => x.Id);

            // Come configurare la chiave esterna per le navigation properties
            modelBuilder.Entity<User>().HasMany(x => x.Progetti).WithRequired(x => x.Utente).Map(x => x.MapKey("UserId"));

            // se voglio evitare l'identity (sulla colonna)
            //modelBuilder.Entity<User>().Property(x => x.Id).HasDatabaseGeneratedOption(DatabaseGeneratedOption.None);
        }
    }
}