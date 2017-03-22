using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StudioWeb.Models
{
    public class Progetto
    {
        public int Id { get; set; }
        public string ProjectName { get; set; }
        public string ProjectType { get; set; }
        public int? DurationDays { get; set; }

        // Navigation property
        public virtual User Utente { get; set; }
    }
}