using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StudioWeb.Models
{
    public class Contacts
    {
        public Guid ContactId { get; set; }
        public Guid LineId { get; set; }
        public string Name { get; set; }
        public string  StateProvinceRegion { get; set; }
        public string City { get; set; }
        public string PostalCode { get; set; }
        public DateTime? LastCallDate { get; set; }
        public string Competence { get; set; }
        public string RelativePotential { get; set; }
        public string PersonalFidelity { get; set; }        
    }
}