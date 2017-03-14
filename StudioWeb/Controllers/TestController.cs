using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Common;
using System.Data.Entity.Core.Common.CommandTrees;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using StudioWeb.Logic;
using StudioWeb.Models;

namespace StudioWeb.Controllers
{
    [RoutePrefix("api/Test")]
    public class TestController : ApiController
    {
        [HttpGet]
        [Route("Prova")]
        public IHttpActionResult Method1()
        {
            using (var context = new StudioWebContext())
            {
                List<string> _list = new List<string>();
                foreach (var e in context.Users.ToList())
                {
                    _list.Add(e.CreationDate.Value.ToLongTimeString());                    
                }
                
                // return to client
                return Ok(_list);
            }
        }


        [HttpGet]
        [Route("insert")]
        public IHttpActionResult InsertMethod()
        {
            // Uso il reporitory
            var repo = new UsersRepository();

            foreach (var u in repo.List)
            {
                Debug.WriteLine(u.Nome);
            }

            using (var context = new StudioWebContext())
            {
                var u = new User()
                {                    
                    Nome = "Pasquale Esposito",
                    IsActive = true,
                    CreationDate = DateTime.Now
                };

                context.Users.Add(u);
                context.SaveChanges();

                // return to client
                return Ok(u);
            }
        }


        [HttpGet]
        [Route("TestContact")]
        public IHttpActionResult TestContact()
        {
            // Chimare la SP e mappare i risultati al returnedDto
            List<ReturnedDto> list = new List<ReturnedDto>();

            var competences = (from r in list
                select r.Competence).Distinct();

            var potentials = (from r in list
                        select r.RelativePotential).Distinct();

            foreach (var comp in competences)
            {
                var contact = new ContactDto();
                contact.Competence = comp;

                foreach (var pot in potentials)
                {
                    contact.RelativePotential = pot;

                    var field = (from x in list
                        where x.Competence == comp && x.RelativePotential == pot
                              && x.PersonalFidelity == "High"
                        select x).FirstOrDefault();

                    if (field != null)
                    {
                        contact.PersonalFidelityHigh = field.Quantity;
                        contact.Visited = field.Visited;
                        contact.TotalCounts = field.TotalCounts;               
                    }

                    field = (from x in list
                                 where x.Competence == comp && x.RelativePotential == pot
                                       && x.PersonalFidelity == "Medium"
                                 select x).FirstOrDefault();

                    if (field != null)
                    {
                        contact.PersonalFidelityMedium = field.Quantity;
                        contact.Visited = field.Visited;
                        contact.TotalCounts = field.TotalCounts;
                    }

                    field = (from x in list
                             where x.Competence == comp && x.RelativePotential == pot
                                   && x.PersonalFidelity == "Low"
                             select x).FirstOrDefault();

                    if (field != null)
                    {
                        contact.PersonalFidelityLow = field.Quantity;
                        contact.Visited = field.Visited;
                        contact.TotalCounts = field.TotalCounts;
                    }
                }
            }
            
            return Ok("ok");
        }
    }
}
