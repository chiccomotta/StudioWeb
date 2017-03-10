using System;
using System.Collections.Generic;
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


            // lo salvo su DB
            //var progetti = new ProgettiRepository();
            //progetti.Add(pro);

            // Uso il reporitory
            //var repo = new UsersRepository();

            //foreach (var u in repo.List)
            //{
            //    Debug.WriteLine(u.Nome);
            //}

            //using (var context = new StudioWebContext())
            //{
            //    var u = new User()
            //    {                    
            //        Nome = "Pasquale Esposito",
            //        IsActive = true,
            //        CreationDate = DateTime.Now
            //    };

            //    context.Users.Add(u);
            //    context.SaveChanges();

            //    // return to client
            //    return Ok(u);
            //}
        }

        [HttpGet]
        [Route("insert2")]
        public IHttpActionResult Insert2Method()
        {          
            var repUsers = new UsersRepository();
            var chicco = repUsers.FindById(3);

            var pro = new Progetto()
            {
                ProjectName = "Pippo",
                ProjectType = "Boh",
                DurationDays = 20,
            };

            chicco.Progetti.Add(pro);
            repUsers.Update(chicco);
        
            return Ok("Ok");
        }
    }
}
