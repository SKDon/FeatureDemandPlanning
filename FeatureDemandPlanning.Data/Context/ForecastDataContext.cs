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

            HydrateVehicleProgramme(forecast.ForecastVehicle);
            HydrateComparisonVehicleProgrammes(forecast);
            HydrateVehicleTrimLevels(forecast.ForecastVehicle);
            HydrateComparisonVehicleTrimLevels(forecast);
            HydrateComparisonVehicleTrimMappings(forecast);

            return forecast;
        }

        public PagedResults<IForecast> ListForecasts(ForecastFilter filter)
        {
            throw new NotImplementedException();
        }

        public IForecast SaveForecast(IForecast forecastToSave)
        {
            forecastToSave = _forecastDataStore.ForecastSave(forecastToSave);

            return forecastToSave;
        }

        public IForecast DeleteForecast(IForecast forecastToDelete)
        {
            throw new NotImplementedException();
        }

        private void HydrateComparisonVehicleProgrammes(IForecast forecast)
        {
            if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
                return;

            foreach (var comparisonVehicle in forecast.ComparisonVehicles)
            {
                HydrateVehicleProgramme(comparisonVehicle);
            }
        }

        private void HydrateComparisonVehicleTrimLevels(IForecast forecast)
        {
            if (forecast.ComparisonVehicles == null || !forecast.ComparisonVehicles.Any())
                return;

            foreach (var comparisonVehicle in forecast.ComparisonVehicles)
            {
                HydrateVehicleTrimLevels(comparisonVehicle);
            }
        }

        private void HydrateComparisonVehicleTrimMappings(IForecast forecast)
        {
            var mappings = _forecastDataStore.TrimMappingGetMany(forecast.ForecastId.Value);
            if (mappings == null || !mappings.Any())
                return;

            forecast.TrimMapping = mappings;

            // We can go a step further and associate the actual details of the trim from the already loaded trim details
            // we can then use this in any views to show loaded details

            foreach (var mapping in mappings)
            {
                mapping.ForecastVehicleTrim = forecast.ForecastVehicle
                                                        .ListTrimLevels()
                                                        .Where(t => t.Id == mapping.ForecastVehicleTrimId)
                                                        .FirstOrDefault();

                var comparisonVehicle = forecast.ComparisonVehicles
                                                .Where(c => c.ProgrammeId == mapping.ComparisonVehicleProgrammeId)
                                                .FirstOrDefault();

                if (comparisonVehicle == null) 
                    continue;

                mapping.ComparisonVehicleTrim = comparisonVehicle
                                                    .ListTrimLevels()
                                                    .Where(t => t.Id == mapping.ComparisonVehicleTrimId)
                                                    .FirstOrDefault();
            }
        }

        private void HydrateVehicleProgramme(IVehicle vehicle)
        {
            if (vehicle == null || vehicle is EmptyVehicle || !vehicle.ProgrammeId.HasValue)
                return;

            var programme = _programmeDataStore.ProgrammeGet(vehicle.ProgrammeId.Value);
            vehicle.Programmes = new List<Programme>() { programme };
        }

        private void HydrateVehicleTrimLevels(IVehicle vehicle)
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
