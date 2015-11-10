using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning
{
    public static class DataContextFactory
    {
        public static IDataContext CreateDataContext(string cdsId)
        {
            return new DataStore.DataContext(cdsId);
        }
    }
}