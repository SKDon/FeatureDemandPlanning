using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class NewsViewModel : SharedModelBase
    {
        #region "Public Properties"

        public IEnumerable<News> News { get; set; }
        
        public dynamic Configuration { get; set; }

        #endregion

        #region "Constructors"

        public NewsViewModel(IDataContext dataContext)
            : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
            InitialiseMembers();
        }

        #endregion      
  
        #region "Public Members"

        public async static Task<NewsViewModel> GetFullOrPartialViewModel(IDataContext context)
        {
            var model = new NewsViewModel(context);

            var latestForecasts = await context.Forecast.ListLatestForecasts();
            
            model.News = await context.News.ListNews();

            return model;
        }

        #endregion

        #region "Private Members"

        private void InitialiseMembers()
        {
            News = Enumerable.Empty<News>();
            IdentifierPrefix = "Page";
        }

        #endregion
    }
}
