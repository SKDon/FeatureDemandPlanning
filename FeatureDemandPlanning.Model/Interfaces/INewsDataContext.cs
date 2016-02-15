using System.Collections.Generic;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface INewsDataContext
    {
        Task<IEnumerable<News>> ListLatestNews();
        Task<IEnumerable<News>> ListNews();

        void AddNews(string newArticle);
    }
}
