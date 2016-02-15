using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class NewsViewModel : SharedModelBase
    {
        #region "Public Properties"

        public IEnumerable<News> News { get; set; }

        #endregion

        #region "Constructors"

        public NewsViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            
        }

        #endregion      
  
        #region "Public Members"

        public async static Task<NewsViewModel> GetFullOrPartialViewModel(IDataContext context)
        {
            var model = new NewsViewModel(GetBaseModel(context))
            {
                Configuration = context.ConfigurationSettings,
                News = await context.News.ListNews()
            };

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

        public string NewArticle { get; set; }
    }
}
