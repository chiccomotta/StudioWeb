using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StudioWeb.Models
{
    public class ContactDto
    {
        public string Competence { get; set; }
        public string RelativePotential { get; set; }

        public int PersonalFidelityHigh { get; set; }
        public int PersonalFidelityMedium { get; set; }
        public int PersonalFidelityLow { get; set; }

        public int Quantity { get; set; }
        public int Visited { get; set; }
        public int TotalCounts { get; set; }

        public decimal Percentage
        {
            get { return (PersonalFidelityHigh + PersonalFidelityMedium + PersonalFidelityLow) / TotalCounts * 100; }
            set { }
        }
    }

    public class ReturnedDto
    {
        public string Competence { get; set; }
        public string RelativePotential { get; set; }

        public string PersonalFidelity { get; set; }
        public int Quantity { get; set; }

        public int Visited { get; set; }
        public int TotalCounts { get; set; }
    }
}