using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class AdminViewModel : SharedModelBase
    {
        public AdminViewModel() : base()
        {

        }

        public static AdminViewModel GetModel(IDataContext context)
        {
            return new AdminViewModel
            {
                Configuration = context.ConfigurationSettings
            };
        }
    }
}