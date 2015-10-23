using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class MarketController : ControllerBase
    {
        public MarketController()
        {
            PageIndex = 1;
            PageSize = DataContext.ConfigurationSettings.DefaultPageSize;
            ControllerType = Controllers.ControllerType.SectionChild;
        }

        [HttpGet]
        public ActionResult Market()
        {
            MarketViewModel marketModel = new MarketViewModel(DataContext)
            {
                AvailableMarkets = DataContext.Market.ListAvailableMarkets(),
                TopMarkets = DataContext.Market.ListTopMarkets()
            };

            if (!marketModel.TopMarkets.Any())
            {
                marketModel.SetProcessState(
                    new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Warning, "No markets configured"));
            }
            else
            {
                marketModel.SetProcessState(
                    new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Information, String.Format("{0} markets configured", marketModel.TopMarkets.Count())));
            }

            return View("Market", marketModel);
        }

        [HttpGet]
        public PartialViewResult TopMarkets()
        {
            var marketModel = new MarketViewModel(DataContext)
            {
                AvailableMarkets = DataContext.Market.ListAvailableMarkets(),
                TopMarkets = DataContext.Market.ListTopMarkets()
            };

            return PartialView("TopMarkets", marketModel);
        }

        [HttpPost]
        public ActionResult AddTopMarket(int marketId)
        {
            var marketModel = new MarketViewModel(DataContext);
            try
            {
                marketModel.AvailableMarkets = DataContext.Market.ListAvailableMarkets();
                marketModel.TopMarkets = DataContext.Market.ListTopMarkets();

                var addedMarket = DataContext.Market.AddTopMarket(marketId);

                marketModel.AvailableMarkets = DataContext.Market.ListAvailableMarkets();
                marketModel.TopMarkets = DataContext.Market.ListTopMarkets();

                marketModel.SetProcessState(new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Success,
                String.Format("Market '{0}' was added successfully", addedMarket.Name)));
            }
            catch (ApplicationException ex)
            {
                marketModel.SetProcessState(ex);
            }

            return Json(marketModel);
        }

        [HttpPost]
        public ActionResult DeleteTopMarket(int marketId)
        {
            MarketViewModel marketModel = new MarketViewModel(DataContext);

            try
            {
                marketModel.AvailableMarkets = DataContext.Market.ListAvailableMarkets();
                marketModel.TopMarkets = DataContext.Market.ListTopMarkets();

                var deletedMarket = DataContext.Market.DeleteTopMarket(marketId);

                marketModel.AvailableMarkets = DataContext.Market.ListAvailableMarkets();
                marketModel.TopMarkets = DataContext.Market.ListTopMarkets();

                if (!marketModel.TopMarkets.Any())
                {
                    marketModel.SetProcessState(new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Warning,
                     "No markets configured"));
                }
                else
                {
                    marketModel.SetProcessState(new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Success,
                    String.Format("Market '{0}' was deleted successfully", deletedMarket.Name)));
                }

            }
            catch (ApplicationException ex)
            {
                marketModel.SetProcessState(ex);
            }

            return Json(marketModel);
        }

        [HttpPost]
        public ActionResult ListAvailableMarkets(ProgrammeFilter filter)
        {
            MarketViewModel marketModel = new MarketViewModel(DataContext);

            marketModel.AvailableMarkets = DataContext.Market.ListAvailableMarkets(filter);

            return Json(marketModel);
        }
    }
}