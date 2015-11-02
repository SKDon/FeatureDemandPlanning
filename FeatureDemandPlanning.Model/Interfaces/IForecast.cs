using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IForecast
    {
        int? ForecastId { get; set; }
       
        DateTime CreatedOn { get; set; }
        string CreatedBy { get; set; }
        DateTime? UpdatedOn { get; set; }
        string UpdatedBy { get; set; }

        Vehicle ForecastVehicle { get; set; }
        IEnumerable<Vehicle> ComparisonVehicles { get; set; }
        IEnumerable<ForecastTrimMapping> TrimMapping { get; set; }

        string[] ToJQueryDataTableResult();
    }
}
