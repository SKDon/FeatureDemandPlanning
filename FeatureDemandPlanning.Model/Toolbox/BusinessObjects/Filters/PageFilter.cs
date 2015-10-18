using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    public class PageFilter
    {
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int DataPageIndex { get; set; }
        public int DataPageSize { get; set; }

        public PageFilter()
        {

        }

        public PageFilter(int pageSize, int pageIndex)
        {
            PageIndex = pageIndex;
            PageSize = pageSize;
        }
    }
}
