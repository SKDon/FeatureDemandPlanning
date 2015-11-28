using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class ForecastDataContext : BaseDataContext, IForecastDataContext
    {
        public ForecastDataContext(string cdsId) : base(cdsId)
        {
            _forecastDataStore = new ForecastDataStore(cdsId);
            _programmeDataStore = new ProgrammeDataStore(cdsId);
            _modelTrimDataStore = new ModelTrimDataStore(cdsId);
            _transmissionDataStore = new ModelTransmissionDataStore(cdsId);
            _vehicleDataStore = new VehicleDataStore(cdsId);
        }

        public async Task<IForecast> GetForecast(ForecastFilter filter)
        {
            IForecast forecast = null;

            if (!filter.ForecastId.HasValue)
            {
                throw new ArgumentNullException("ForecastId not specified");
            }

            forecast = await Task.FromResult<IForecast>(_forecastDataStore.ForecastGet(filter.ForecastId.Value));

            if (forecast == null)
            {
                throw new ArgumentException(string.Format("Forecast {0} not found", filter.ForecastId.Value));
            }

            //await HydrateForecast(forecast);

            return forecast;
        }

        public async Task<PagedResults<ForecastSummary>> ListLatestForecasts()
        {
            var forecasts = await ListForecasts(new ForecastFilter());

            forecasts.CurrentPage = forecasts.CurrentPage.Take(5);

            return forecasts;
        }
        public async Task<PagedResults<ForecastSummary>> ListForecasts(ForecastFilter filter)
        {
            return await Task.FromResult<PagedResults<ForecastSummary>>(
                _forecastDataStore.ForecastGetMany(filter));
        }

        public IForecast SaveForecast(IForecast forecastToSave)
        {
            forecastToSave = _forecastDataStore.ForecastSave(forecastToSave);

            return forecastToSave;
        }

        public Task<IForecast> SaveForecastAsync(IForecast forecastToSave)
        {
            throw new NotImplementedException();
        }

        public IForecast DeleteForecast(IForecast forecastToDelete)
        {
            throw new NotImplementedException();
        }

        public Task<IForecast> DeleteForecastAsync(IForecast forecastToDelete)
        {
            throw new NotImplementedException();
        }

        private async Task<IForecast> HydrateForecast(ForecastSummary forecast)
        {
            var programme = _programmeDataStore.ProgrammeGet(forecast.ProgrammeId);

            return await Task.FromResult<Forecast>(new Forecast()
            {
                ForecastId = forecast.ForecastId,
                CreatedOn = forecast.CreatedOn,
                CreatedBy = forecast.CreatedBy,
                ForecastVehicle = new Vehicle() { ProgrammeId = forecast.ProgrammeId, Gateway = forecast.Gateway }
            });
        }

        public void HydrateComparisonVehiclesTrimMappings(IForecast forecast)
        {
            if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
                return;

            foreach (var comparisonVehicle in forecast.ComparisonVehicles)
            {
                HydrateComparisonVehicleTrimMappings(forecast, comparisonVehicle);
            }
        }

        public void HydrateComparisonVehicleTrimMappings(IForecast forecast, IVehicle comparisonVehicle)
        {
            //var programme = forecast.ForecastVehicle.Programmes.First();

            //comparisonVehicle.TrimMappings = forecast.ForecastVehicle.Programmes.AllTrims
            //    .Select(t => new TrimMapping() {
            //        ForecastVehicleTrim = t,
            //        ComparisonVehicleTrimMappings = new List<ModelTrim>()
            //    }).ToList();
        }

        private async Task HydrateVehicleProgrammeAsync(IVehicle vehicle)
        {
            if (vehicle == null || vehicle is EmptyVehicle || !vehicle.ProgrammeId.HasValue)
                return;

            var programme = await Task.FromResult<Programme>(_programmeDataStore.ProgrammeGet(vehicle.ProgrammeId.Value));
            vehicle.Programmes = new List<Programme>() { programme };
        }

        private void HydrateVehicleTrimLevelsAsync(IVehicle vehicle)
        {
            if (vehicle == null || vehicle is EmptyVehicle || !vehicle.ProgrammeId.HasValue)
                return;

            var programme = vehicle.GetProgramme();
            if (programme == null)
                return;

            var trim = _modelTrimDataStore.ModelTrimGetMany(new TrimFilter() { ProgrammeId = vehicle.ProgrammeId });
            if (trim == null || !trim.Any())
            {
                programme.AllTrims = Enumerable.Empty<ModelTrim>();
                return;
            }

            programme.AllTrims = trim;
        }

        private ForecastDataStore _forecastDataStore = null;
        private ProgrammeDataStore _programmeDataStore = null;
        private ModelTrimDataStore _modelTrimDataStore = null;
        private ModelTransmissionDataStore _transmissionDataStore = null;
        private VehicleDataStore _vehicleDataStore = null;
    }
}
