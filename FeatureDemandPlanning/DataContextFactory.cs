using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning
{
    public static class DataContextFactory
    {
        public static IDataContext CreateDataContext(string cdsId)
        {
            //TODO use reflection here to inject dependency into data context
            return new FeatureDemandPlanning.DataStore.DataContext(cdsId);
        }
    }
}