using System;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class NewsDataContext : BaseDataContext, INewsDataContext
    {
        public NewsDataContext(string cdsId) : base(cdsId)
        {
            _newsDataStore = new NewsDataStore(cdsId);
        }
        public async Task<IEnumerable<News>> ListLatestNews()
        {
            return await Task.FromResult(_newsDataStore.NewsGetMany().Take(5));
        }
        public async Task<IEnumerable<News>> ListNews()
        {
            return await Task.FromResult(_newsDataStore.NewsGetMany());
        }

        private readonly NewsDataStore _newsDataStore;


        public void AddNews(string newArticle)
        {
            throw new System.NotImplementedException();
        }

        public void RemoveNews(int articleId)
        {
            throw new NotImplementedException();
        }
    }
}
