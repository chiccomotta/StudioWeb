using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

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
                    _list.Add(e.CreationDate.Value.ToShortDateString());                    
                }
                
                // return to client
                return Ok(_list);
            }
        }
    }
}
