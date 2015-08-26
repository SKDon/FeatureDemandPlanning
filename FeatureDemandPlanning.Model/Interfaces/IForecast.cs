using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IForecast
    {
        int? ForecastId { get; set; }
        int VehicleId { get; set; }
        int ProgrammeId { get; set; }
        
        DateTime CreatedOn { get; set; }
        string CreatedBy { get; set; }
        DateTime? UpdatedOn { get; set; }
        string UpdatedBy { get; set; }

        Vehicle ForecastVehicle { get; set; }
        IEnumerable<Vehicle> ComparisonVehicles { get; set; }
        IEnumerable<TrimMapping> TrimMapping { get; set; }

        bool IsValid();
    }
}
