using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class HomeViewModel : SharedModelBase
    {
        #region "Public Properties"

        public IEnumerable<News> LatestNews { get; set; }
        public IEnumerable<ForecastSummary> LatestForecasts { get; set; }
        public IEnumerable<TakeRateSummary> LatestTakeRateData { get; set; }
        
        public dynamic Configuration { get; set; }

        #endregion

        #region "Constructors"

        public HomeViewModel(IDataContext dataContext)
            : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
            InitialiseMembers();
        }

        #endregion      
  
        #region "Public Members"

        public async static Task<HomeViewModel> GetFullOrPartialViewModel(IDataContext context)
        {
            var model = new HomeViewModel(context);

            var latestForecasts = await context.Forecast.ListLatestForecasts();
            var latestTakeRateData = await context.Volume.ListLatestTakeRateData();
            
            model.LatestNews = await context.News.ListLatestNews();
            model.LatestForecasts = latestForecasts.CurrentPage;
            model.LatestTakeRateData = latestTakeRateData.CurrentPage;
            //model.LatestTakeRateData = latestTakeRateData.CurrentPage;

            return model;
        }

        #endregion

        #region "Private Members"

        private void InitialiseMembers()
        {
            LatestForecasts = Enumerable.Empty<ForecastSummary>();
            LatestNews = Enumerable.Empty<News>();
            LatestTakeRateData = Enumerable.Empty<TakeRateSummary>();

            IdentifierPrefix = "Page";
        }

        #endregion
    }
}
