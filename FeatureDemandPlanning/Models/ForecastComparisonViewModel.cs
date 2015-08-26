using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.DataStore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Models
{
    public class ForecastComparisonViewModel : SharedModelBase
    {
        public IForecast Forecast 
        {
            get
            {
                return _forecast;
            }
            set
            {
                _forecast = value;
            }
        }

        public int NumberOfComparisonVehicles 
        { 
            get 
            { 
                if (Forecast == null)
                    return 0;

                return Forecast.ComparisonVehicles.Any() ? Forecast.ComparisonVehicles.Count() : 0; 
            } 
        } 
        public dynamic Configuration { get; set; }
        
        public ForecastComparisonViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
        }

        private IForecast _forecast = new EmptyForecast();
    }
}
