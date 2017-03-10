using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

namespace StudioWeb.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? CreationDate { get; set; }

        [JsonIgnore]
        public virtual ICollection<Progetto> Progetti { get; set; }
    }
}