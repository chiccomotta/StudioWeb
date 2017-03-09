using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;

namespace StudioWeb
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );


            // Rimuovo il formattatore XML
            config.Formatters.Remove(GlobalConfiguration.Configuration.Formatters.XmlFormatter);

            // Aggiungo il formattatore Json
            config.Formatters.Add(GlobalConfiguration.Configuration.Formatters.JsonFormatter);
        }
    }
}
