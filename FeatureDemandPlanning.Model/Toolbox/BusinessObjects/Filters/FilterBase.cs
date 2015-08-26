using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.Enumerations;
using System;
using System.Data;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    /// <summary>
    /// Base class representing search filters that can be passed to a data context object
    /// </summary>
    public abstract class FilterBase
    {
        public int? PageSize { get; set; }
        public int? PageIndex { get; set; }

        public int? SortIndex { get; set; }
        public SortDirection SortDirection { get { return _direction; } set { _direction = value; } }

        private SortDirection _direction = SortDirection.Ascending;

        /// <summary>
        /// Initialises from json search parameters
        /// </summary>
        /// <param name="param">The parameters to initialise with</param>
        public void InitialiseFromJson(JQueryDataTableParamModel param)
        {
            PageSize = param.iDisplayLength;
            PageIndex = (param.iDisplayStart / PageSize) + 1;
            SortIndex = param.iSortCol_0;
            SortDirection =
                param.sSortDir_0.Equals("ASC", StringComparison.OrdinalIgnoreCase) ?
                    SortDirection.Ascending :
                    SortDirection.Descending;
        }

        /// <summary>
        /// Gets basic search parameters to pass to the data store based on the filter
        /// </summary>
        /// <param name="filter">The filter.</param>
        /// <returns></returns>
        public static DynamicParameters GetParametersFromFilter(FilterBase filter)
        {
            var para = new DynamicParameters();

            if (filter.PageIndex.HasValue)
            {
                para.Add("@PageIndex", filter.PageIndex.Value, dbType: DbType.Int32);
            }

            if (filter.PageSize.HasValue)
            {
                para.Add("@PageSize", filter.PageSize.Value, dbType: DbType.Int32);
            }

            if (filter.SortIndex.HasValue)
            {
                para.Add("@SortIndex", filter.SortIndex.Value, dbType: DbType.Int32);
            }

            if (filter.SortDirection != SortDirection.NotSet)
            {
                para.Add("@SortDirection", (int)filter.SortDirection, dbType: DbType.Int32);
            }

            return para;
        }
    }
}
