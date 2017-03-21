using System;
using System.Collections.Generic;

namespace StudioWeb.Models
{

    public class DbFieldAttribute : Attribute
    {
        // non faccio nessuan implementazione 
    }

        public class ClientReportData
        {
            public string Description { get; set; }
            public int Quantity { get; set; }
        }


        public class EntityReportData
        {
            [DbField]
            public string Typology { get; set; }
            [DbField]
            public string Description { get; set; }
            [DbField]
            public int Quantity { get; set; }
        }


        public class EntityReportDetailsData
        {
            [DbField]
            public Guid CallId { get; set; }
            [DbField]
            public Guid ContactId { get; set; }
            [DbField]
            public string Name { get; set; }
            [DbField]
            public string StateProvinceRegion { get; set; }
            [DbField]
            public string City { get; set; }
            [DbField]
            public string PostalCode { get; set; }
            [DbField]
            public string Address { get; set; }
            [DbField]
            public DateTime CallDate { get; set; }
            [DbField]
            public string Competence { get; set; }
            [DbField]
            public string RelativePotential { get; set; }

            [DbField]
            public DateTime LastCallDate { get; set; }
            [DbField]
            public string SpecializationName { get; set; }
            [DbField]
            public string ProtocolTitle { get; set; }
            [DbField]
            public string ArgumentTitle { get; set; }

            // Raggruppamenti
            //[DbField]
            //public int TotalCalls { get; set; }
            //// Raggruppamenti
            //[DbField]
            //public String Typology { get; set; }
        }


        public class SummaryReportDataDto
        {
            public List<ClientReportData> specializations { get; set; }
            public List<ClientReportData> callArguments { get; set; }
            public List<ClientReportData> protocols { get; set; }
            public List<ClientReportData> fidelizations { get; set; }
            public List<ClientReportData> potentials { get; set; }
            public List<ClientReportData> competences { get; set; }

            public List<EntityReportDetailsData> Details { get; set; }
        }
    }