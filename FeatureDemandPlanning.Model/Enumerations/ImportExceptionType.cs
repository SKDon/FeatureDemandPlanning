using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ImportExceptionType
    {
        NotSet = 0,
        MissingMarket,
        MissingFeature,
        MissingDerivative,
        MissingTrim
    }
}
