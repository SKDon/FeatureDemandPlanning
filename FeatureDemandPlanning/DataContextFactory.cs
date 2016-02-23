using FeatureDemandPlanning.Model.Interfaces;
using Ninject;

namespace FeatureDemandPlanning
{
    public static class DataContextFactory
    {
        public static IDataContext CreateDataContext()
        {
            IDataContext context;
            using (var kernel = new StandardKernel(new Bindings.DataContextModule()))
            {
                context = kernel.Get<IDataContext>();
            }

            return context;
        }
    }
}