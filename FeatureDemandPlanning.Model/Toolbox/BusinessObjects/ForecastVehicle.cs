using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ForecastVehicle : Vehicle
    {
        public IEnumerable<ModelTrim> TrimLevels { get; set; }

        private IEnumerable<ModelTrim> _programmes = new List<ModelTrim>();
    }
}