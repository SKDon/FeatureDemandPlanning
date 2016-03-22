using System;
using FeatureDemandPlanning.Model.Interfaces;
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

        #endregion

        #region "Constructors"

        public HomeViewModel()
        {
            InitialiseMembers();
        }

        public HomeViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }

        #endregion      
  
        #region "Public Members"

        public static async Task<HomeViewModel> GetFullOrPartialViewModel(IDataContext context)
        {
            var modelBase = GetBaseModel(context);
            var model = new HomeViewModel(modelBase)
            {
                Configuration = context.ConfigurationSettings,
                LatestNews = await GetLatestNews(context),
                LatestTakeRateData = await GetLatestTakeRateData(context)
            };
            //model.LatestForecasts = latestForecasts.CurrentPage;

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

        private static async Task<IEnumerable<TakeRateSummary>> GetLatestTakeRateData(IDataContext context)
        {
            var latest = (IEnumerable<TakeRateSummary>)HttpContext.Current.Cache.Get("LatestTakeRateData");
            if (latest != null)
                return latest;

            var results = await context.TakeRate.ListLatestTakeRateDocuments();
            if (results != null && results.CurrentPage.Any())
            {
                latest = results.CurrentPage;
                HttpContext.Current.Cache.Insert("LatestTakeRateData", latest, null, DateTime.Now.AddMinutes(10),
                    System.Web.Caching.Cache.NoSlidingExpiration);
            }
            else
            {
                latest = Enumerable.Empty<TakeRateSummary>();
            }
            return latest;
        }

        private static async Task<IEnumerable<News>> GetLatestNews(IDataContext context)
        {
            var latest = (IEnumerable<News>)HttpContext.Current.Cache.Get("LatestNews");
            if (latest != null)
                return latest;

            latest = await context.News.ListLatestNews();
            if (latest != null && latest.Any())
            {
                HttpContext.Current.Cache.Insert("LatestNews", latest, null, DateTime.Now.AddMinutes(10),
                    System.Web.Caching.Cache.NoSlidingExpiration);
            }
            else
            {
                latest = Enumerable.Empty<News>();
            }
            return latest;
        }

        #endregion
    }
}
