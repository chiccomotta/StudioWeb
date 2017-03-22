using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace StudioWeb.Models
{
    public class CallsReportFilter
    {
        public Guid UserId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        public string CallArgument { get; set; }
        public string Protocol { get; set; }

        public string Specialization { get; set; }
        public string Competence { get; set; }
        public string RelativePotential { get; set; }
        public string PersonalFidelity { get; set; }
    }
}