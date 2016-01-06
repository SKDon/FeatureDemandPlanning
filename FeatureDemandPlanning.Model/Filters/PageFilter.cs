namespace FeatureDemandPlanning.Model.Filters
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
