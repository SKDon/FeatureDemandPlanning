using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class MarketReviewViewModel : SharedModelBase
    {
        public PagedResults<MarketReview> AvailableMarketReviews { get; set; }

        public MarketReviewViewModel()
        {
            InitialiseMembers();
        }
        public MarketReviewViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static Task<MarketReviewViewModel> GetModel(IDataContext context, TakeRateFilter filter)
        {
            return GetFullAndPartialViewModel(context, filter);
        }
        private void InitialiseMembers()
        {
            AvailableMarketReviews = new PagedResults<MarketReview>();
        }
        private static async Task<MarketReviewViewModel> GetFullAndPartialViewModel(IDataContext context,
                                                                         TakeRateFilter filter)
        {
            var model = new MarketReviewViewModel(GetBaseModel(context));
            if (filter.Action == TakeRateDataItemAction.MarketReview)
            {
                model.AvailableMarketReviews = await context.TakeRate.ListMarketReview(filter);
            };
            return model;
        }
    }
}
