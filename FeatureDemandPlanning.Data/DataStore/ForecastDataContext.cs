using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.BusinessObjects;

namespace FeatureDemandPlanning.DataStore
{
    public class ForecastDataContext : BaseDataContext, IForecastDataContext
    {
        public ForecastDataContext(string cdsId) : base(cdsId)
        {
            _forecastDataSource = new ForecastDataStore(cdsId);
        }

        public IForecast GetForecast(int forecastId)
        {
            var forecast = _forecastDataSource.ForecastGet(forecastId);
            var forecastVehicle = _forecastVehicleDataStore.ForecastVehicleGet(forecast.ForecastVehicleId);

            // populate the forecast vehicle and the comparison vehicles

            var vehicle = _vehicleDataStore.VehicleGet(forecastVehicle.VehicleId.Value);
            var programme = _programmeDataStore.ProgrammeGet(forecastVehicle.ProgrammeId.Value);

            return null;
        }

        public IForecast SaveForecast(IForecast forecastToSave)
        {
            var success = _forecastDataSource.ForecastSave(forecastToSave);
            if (!success)
                return null;

            return forecastToSave;
        }

        public IForecast DeleteForecast(IForecast forecastToDelete)
        {
            if (forecastToDelete == null || !forecastToDelete.Id.HasValue)
                return null;

            var success = _forecastDataSource.ForecastDelete(forecastToDelete.Id.Value);
            if (!success)
                return null;

            return GetForecast(forecastToDelete.Id.Value);
        }

        public IEnumerable<IForecast> ListForecasts()
        {
            return _forecastDataSource.ForecastGetMany();
        }

        private ForecastDataStore _forecastDataSource = null;
        private ForecastVehicleDataStore _forecastVehicleDataStore = null;
        private VehicleDataStore _vehicleDataStore = null;
        private Gateway _gatewayDataStore = null;
        private ProgrammeDataStore _programmeDataStore = null;
    }
}
