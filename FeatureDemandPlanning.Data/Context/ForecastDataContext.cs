using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
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
        }
        
        public IForecast GetForecast(ForecastFilter filter)
        {
            IForecast forecast = null;

            if (!filter.ForecastId.HasValue)
            {
                throw new ArgumentNullException("ForecastId not specified");
            }

            forecast = _forecastDataStore.ForecastGet(filter.ForecastId.Value);

            if (forecast == null)
            {
                throw new ArgumentException(string.Format("Forecast {0} not found", filter.ForecastId.Value));
            }

            //HydrateForecastAsync(forecast);           
            //HydrateVehicleProgrammeAsync(forecast.ForecastVehicle);
            //HydrateComparisonVehicleProgrammesAsync(forecast);
            //HydrateVehicleTrimLevelsAsync(forecast.ForecastVehicle);
            //HydrateComparisonVehicleTrimLevelsAsync(forecast);
            //HydrateComparisonVehicleTrimMappingsAsync(forecast);

            return forecast;
        }

        public async Task<IForecast> GetForecastAsync(ForecastFilter filter)
        {
            IForecast forecast = null;

            if (!filter.ForecastId.HasValue)
            {
                throw new ArgumentNullException("ForecastId not specified");
            }

            forecast = await _forecastDataStore.ForecastGetAsync(filter.ForecastId.Value);

            if (forecast == null)
            {
                throw new ArgumentException(string.Format("Forecast {0} not found", filter.ForecastId.Value));
            }

            //await HydrateForecast(forecast);

            return forecast;
        }

        public PagedResults<IForecast> ListForecasts(ForecastFilter filter)
        {
            throw new NotImplementedException();
        }

        public async Task<PagedResults<IForecast>> ListForecastsAsync(ForecastFilter filter)
        {
            var forecasts = _forecastDataStore.ForecastGetManyAsync().Result.Select(f => HydrateForecast(f));

            return new PagedResults<IForecast>(forecasts);
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

        private IForecast HydrateForecast(IForecast forecast)
        {
            //await HydrateVehicleProgrammeAsync(forecast.ForecastVehicle);
            //await HydrateComparisonVehicleProgrammesAsync(forecast);
            //await HydrateVehicleTrimLevelsAsync(forecast.ForecastVehicle);
            //await HydrateComparisonVehicleTrimLevelsAsync(forecast);
            //await HydrateComparisonVehicleTrimMappingsAsync(forecast);

            return forecast;
        }

        private void HydrateComparisonVehicleProgrammesAsync(IForecast forecast)
        {
            if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
                return;

            foreach (var comparisonVehicle in forecast.ComparisonVehicles)
            {
                HydrateVehicleProgrammeAsync(comparisonVehicle);
            }
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

            var programme = _programmeDataStore.ProgrammeGet(vehicle.ProgrammeId.Value);
            vehicle.Programmes = new List<Programme>() { programme };
        }

        private void HydrateVehicleTrimLevelsAsync(IVehicle vehicle)
        {
            if (vehicle == null || vehicle is EmptyVehicle || !vehicle.ProgrammeId.HasValue)
                return;

            var programme = vehicle.GetProgramme();
            if (programme == null)
                return;

            var trim = _modelTrimDataStore.ModelTrimGetMany(vehicle.ProgrammeId.Value);
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
    }
}
