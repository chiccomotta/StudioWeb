using PerformanceReporting.Data.SqlServer.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using StudioWeb.Models;

namespace PerformanceReporting.Data.SqlServer.Repositories
{
    public class CallsReportRepository
    {
        const string GET_SUMMARY_REPORT_DATA = "[PR].[GetSummaryReportData]";

        private SqlConnection Connection = new SqlConnection();
     

        public SummaryReportDataDto GetSummaryReportDataDto(CallsReportFilter filter, string quertType)
        {
            if (Connection.State != ConnectionState.Open)
                Connection.Open();

            using (SqlCommand command = new SqlCommand(GET_SUMMARY_REPORT_DATA, Connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.SetParameter("@UserId", DbType.Guid, ParameterDirection.Input, filter.UserId);
                command.SetParameter("@StartDate", DbType.DateTime, ParameterDirection.Input, filter.StartDate);
                command.SetParameter("@EndDate", DbType.DateTime, ParameterDirection.Input, filter.EndDate);
                command.SetParameter("@CallArgument", DbType.String, ParameterDirection.Input, filter.CallArgument);
                command.SetParameter("@Protocol", DbType.String, ParameterDirection.Input, filter.Protocol);
                command.SetParameter("@Competence", DbType.String, ParameterDirection.Input, filter.Competence);
                command.SetParameter("@RelativePotential", DbType.String, ParameterDirection.Input, filter.RelativePotential);
                command.SetParameter("@PersonalFidelity", DbType.String, ParameterDirection.Input, filter.PersonalFidelity);
                command.SetParameter("@Specialization", DbType.String, ParameterDirection.Input, filter.Specialization);
                command.SetParameter("@queryType", DbType.String, ParameterDirection.Input, quertType);

                // Compono l'oggetto da passare 
                var result = new SummaryReportDataDto();

                if (quertType == "Group")
                {
                    IList<EntityReportData> results = new List<EntityReportData>();
                    using (IDataReader reader = command.ExecuteReader())
                    {
                        results = reader.MapToEntityList<EntityReportData>();
                    }

                    result.competences = (from r in results
                                          where r.Typology == "COMPETENCE"
                                          select new ClientReportData()
                                          {
                                              Description = r.Description,
                                              Quantity = r.Quantity
                                          }).ToList();


                    result.potentials = (from r in results
                                         where r.Typology == "RELATIVE_POTENTIAL"
                                         select new ClientReportData()
                                         {
                                             Description = r.Description,
                                             Quantity = r.Quantity
                                         }).ToList();


                    result.fidelizations = (from r in results
                                            where r.Typology == "PERSONAL_FIDELITY"
                                            select new ClientReportData()
                                            {
                                                Description = r.Description,
                                                Quantity = r.Quantity
                                            }).ToList();


                    result.protocols = (from r in results
                                        where r.Typology == "PROTOCOL"
                                        select new ClientReportData()
                                        {
                                            Description = r.Description,
                                            Quantity = r.Quantity
                                        }).ToList();


                    result.specializations = (from r in results
                                              where r.Typology == "SPECIALIZATIONS"
                                              select new ClientReportData()
                                              {
                                                  Description = r.Description,
                                                  Quantity = r.Quantity
                                              }).ToList();

                    result.callArguments = (from r in results
                                            where r.Typology == "ARGUMENT"
                                            select new ClientReportData()
                                            {
                                                Description = r.Description,
                                                Quantity = r.Quantity
                                            }).ToList();

                }
                else
                {
                    IList<EntityReportDetailsData> results = new List<EntityReportDetailsData>();
                    using (IDataReader reader = command.ExecuteReader())
                    {
                        results = reader.MapToEntityList<EntityReportDetailsData>();
                    }

                    result.Details = results.ToList();
                }

                return result;
            }
        }
    }
}
