using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class PublishViewModel : SharedModelBase
    {
        public PagedResults<Publish> AvailableFiles { get; set; }

        public PublishViewModel()
        {
            InitialiseMembers();
        }
        public PublishViewModel(SharedModelBase baseModel)
            : base(baseModel)
        {
            InitialiseMembers();
        }
        public static Task<PublishViewModel> GetModel(IDataContext context, TakeRateFilter filter)
        {
            return GetFullAndPartialViewModel(context, filter);
        }
        private void InitialiseMembers()
        {
            AvailableFiles = new PagedResults<Publish>();
        }
        private static async Task<PublishViewModel> GetFullAndPartialViewModel(IDataContext context,
                                                                         TakeRateFilter filter)
        {
            var model = new PublishViewModel(GetBaseModel(context));
            model.AvailableFiles = await context.TakeRate.ListPublish(filter);
            
            return model;
        }
    }
}
