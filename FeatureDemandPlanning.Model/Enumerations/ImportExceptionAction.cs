using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ImportExceptionAction
    {
        NotSet = 0,
        MapMissingMarket = 1,
        AddMissingDerivative = 2,
        MapMissingDerivative = 3,
        AddMissingFeature = 4,
        MapMissingFeature = 5,
        AddSpecialFeature = 9,
        AddMissingTrim = 6,
        MapMissingTrim = 7,
        IgnoreException = 8
    }
}
