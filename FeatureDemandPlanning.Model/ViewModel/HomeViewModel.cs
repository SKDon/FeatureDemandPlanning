using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

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

        public HomeViewModel() : base()
        {
            InitialiseMembers();
        }

        #endregion      
  
        #region "Public Members"

        public async static Task<HomeViewModel> GetFullOrPartialViewModel(IDataContext context)
        {
            var model = new HomeViewModel()
            {
                Configuration = context.ConfigurationSettings
            };

            //var latestForecasts = await context.Forecast.ListLatestForecasts();
            var latestTakeRateDocuments = await context.TakeRate.ListLatestTakeRateDocuments();
            
            model.LatestNews = await context.News.ListLatestNews();
            //model.LatestForecasts = latestForecasts.CurrentPage;
            model.LatestTakeRateData = latestTakeRateDocuments.CurrentPage;

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
