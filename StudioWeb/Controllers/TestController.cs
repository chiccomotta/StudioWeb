using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Web.Http;
using Newtonsoft.Json;
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
            // Json.net example
            var d = DateTime.Now;
            var t = JsonConvert.SerializeObject(d);
            Debug.WriteLine(t);

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
            // creo un progetto nuovo
            var pro1 = new Progetto()
            {
                ProjectName = "StudioWeb",
                ProjectType = "Web Site",
                DurationDays = 30
            };

            var pro2 = new Progetto()
            {
                ProjectName = "ConsoleOne",
                ProjectType = "Console",
                DurationDays = 15
            };

            var u = new User()
            {
                Nome = "Cristiano Motta",
                IsActive = true,
                CreationDate = DateTime.Now,
                Progetti = {pro1, pro2}
            };

            var repo = new UsersRepository();
            repo.Add(u);

            return Ok(JsonConvert.SerializeObject(u));
        }

        [HttpGet]
        [Route("insert2")]
        public IHttpActionResult Insert2Method()
        {          
            var repUsers = new UsersRepository();
            var chicco = repUsers.FindById(3);

            var pro = new Progetto()
            {
                ProjectName = "progetto Numero tre",
                ProjectType = "Spatial application game",
                DurationDays = 100,
            };

            chicco.Progetti.Add(pro);
            repUsers.Update(chicco);
        
            return Ok("Ok");
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
