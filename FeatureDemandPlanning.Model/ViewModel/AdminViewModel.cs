using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class AdminViewModel : SharedModelBase
    {
        public AdminViewModel(SharedModelBase baseModel) : base(baseModel)
        {

        }
        public static AdminViewModel GetModel(IDataContext context)
        {
            var modelBase = GetBaseModel(context);
            return new AdminViewModel(modelBase)
            {
                Configuration = context.ConfigurationSettings
            };
        }
    }
}