using System.Web.Mvc;
using System.Web.Routing;

namespace FeatureDemandPlanning
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            //routes.MapRoute(
            //    name: "Forecast",
            //    url: "Forecast/{action}/{forecastId}",
            //    defaults: new { controller = "Forecast", action = "Forecast", forecastId = UrlParameter.Optional }
            //    );

            //routes.MapRoute(name: "VolumeByMarketGroup",
            //                url: "Document/{oxoDocId}/VolumeByMarketGroup/{marketGroupId}",
            //                defaults: new { controller = "TakeRate", action = "TakeRate", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "Document",
            //                url: "Document/{oxoDocId}/{action}/{id}",
            //                defaults: new { controller = "TakeRate", action = "Document", id = UrlParameter.Optional });

            //routes.MapRoute(name: "PercentageByMarket",
            //                url: "Document/{oxoDocId}/PercentageByMarket/{marketId}",
            //                defaults: new { controller = "TakeRate", action = "PercentageByMarket", resultsMode = VolumeResultMode.PercentageTakeRate });

            //routes.MapRoute(name: "VolumeByMarket",
            //                url: "Document/{oxoDocId}/VolumeByMarket/{marketId}",
            //                defaults: new { controller = "TakeRate", action = "TakeRate", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "TakeRate",
            //                url: "Document/{oxoDocId}/TakeRate",
            //                defaults: new { controller = "TakeRate", action = "TakeRate", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "Percentage",
            //                url: "Document/{oxoDocId}/Percentage",
            //                defaults: new { controller = "TakeRate", action = "Percentage", resultsMode = VolumeResultMode.PercentageTakeRate });

            //routes.MapRoute(
            //    name: "TakeRate",
            //    url: "TakeRate/{action}/{oxoDocId}",
            //    defaults: new { controller = "TakeRate", action = "TakeRate", oxoDocId = UrlParameter.Optional }
            //    );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
