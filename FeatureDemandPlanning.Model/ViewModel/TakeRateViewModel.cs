using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class TakeRateViewModel : SharedModelBase
    {
        public IEnumerable<TakeRateStatus> Statuses { get; set; }
        public TakeRateSummary TakeRate { get; set; }
        public PagedResults<TakeRateSummary> TakeRates { get; set; }

        public TakeRateViewModel()
        {
            InitialiseMembers();
        }
        public TakeRateViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<TakeRateViewModel> GetModel(IDataContext context, TakeRateFilter filter)
        {
            return new TakeRateViewModel(GetBaseModel(context))
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                TakeRates = await context.TakeRate.ListTakeRateData(filter),
                Statuses = await context.TakeRate.ListTakeRateStatuses()
            };
        }
        private void InitialiseMembers()
        {
            TakeRate = new EmptyTakeRateSummary();
            TakeRates = new PagedResults<TakeRateSummary>();
            Statuses = Enumerable.Empty<TakeRateStatus>();
            IdentifierPrefix = "Page";
        }
    }
}
