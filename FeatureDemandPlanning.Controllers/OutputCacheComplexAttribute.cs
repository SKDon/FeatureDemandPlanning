using System;
using System.Linq;
using System.Web.Mvc;

namespace FeatureDemandPlanning
{
    public class OutputCacheComplexAttribute : OutputCacheAttribute
    {
        public OutputCacheComplexAttribute(Type type)
        {
            var properties = type.GetProperties();
            VaryByParam = string.Join(";", properties.Select(p => p.Name).ToList());
            Duration = 600;
        }
    }
}