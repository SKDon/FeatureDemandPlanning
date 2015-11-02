using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface INewsDataContext
    {
        Task<IEnumerable<News>> ListLatestNews();
        Task<IEnumerable<News>> ListNews();
    }
}
