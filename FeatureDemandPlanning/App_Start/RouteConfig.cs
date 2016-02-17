using System.Web.Mvc;
using System.Web.Routing;
using FeatureDemandPlanning.Model.Enumerations;

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
            //                defaults: new { controller = "Volume", action = "Volume", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "Document",
            //                url: "Document/{oxoDocId}/{action}/{id}",
            //                defaults: new { controller = "Volume", action = "Document", id = UrlParameter.Optional });

            //routes.MapRoute(name: "PercentageByMarket",
            //                url: "Document/{oxoDocId}/PercentageByMarket/{marketId}",
            //                defaults: new { controller = "Volume", action = "PercentageByMarket", resultsMode = VolumeResultMode.PercentageTakeRate });

            //routes.MapRoute(name: "VolumeByMarket",
            //                url: "Document/{oxoDocId}/VolumeByMarket/{marketId}",
            //                defaults: new { controller = "Volume", action = "Volume", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "Volume",
            //                url: "Document/{oxoDocId}/Volume",
            //                defaults: new { controller = "Volume", action = "Volume", resultsMode = VolumeResultMode.Raw });

            //routes.MapRoute(name: "Percentage",
            //                url: "Document/{oxoDocId}/Percentage",
            //                defaults: new { controller = "Volume", action = "Percentage", resultsMode = VolumeResultMode.PercentageTakeRate });

            //routes.MapRoute(
            //    name: "Volume",
            //    url: "Volume/{action}/{oxoDocId}",
            //    defaults: new { controller = "Volume", action = "Volume", oxoDocId = UrlParameter.Optional }
            //    );

            routes.MapRoute(
                "TakeRate",
                "TakeRate",
                new {controller = "TakeRate", action = "Index"}
                );

            routes.MapRoute(
                "ListTakeRates",
                "TakeRate/List",
                new { controller = "TakeRate", action = "ListTakeRates" }
                );

            routes.MapRoute(
                "TakeRateData",
                "TakeRate/{takeRateId}",
                new {controller = "TakeRateData", action = "Index"}
                );

            routes.MapRoute(
                "TakeRateDataRaw",
                "TakeRate/{takeRateId}/Raw",
                new { controller = "TakeRateData", action = "Index", mode = TakeRateResultMode.Raw }
                );

            routes.MapRoute(
                "TakeRateDataByMarket",
                "TakeRate/{takeRateId}/M/{marketId}",
                new { controller = "TakeRateData", action="Index", takeRateId = UrlParameter.Optional, marketId = UrlParameter.Optional }
                );

            routes.MapRoute(
                "TakeRateDataByMarketRaw",
                "TakeRate/{takeRateId}/M/{marketId}/Raw",
                new { controller = "TakeRateData", action = "Index", mode = TakeRateResultMode.Raw }
                );

            routes.MapRoute(
                "TakeRateDataByMarketGroup",
                "TakeRate/{takeRateId}/MG/{marketGroupId}",
                new { controller = "TakeRateData", action = "Index" }
                );

            routes.MapRoute(
                "TakeRateDataByMarketGroupRaw",
                "TakeRate/{takeRateId}/MG/{marketGroupId}/Raw",
                new { controller = "TakeRateData", action = "Index", mode = TakeRateResultMode.Raw }
                );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
