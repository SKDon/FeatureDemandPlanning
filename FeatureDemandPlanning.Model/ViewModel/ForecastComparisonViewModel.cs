using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Validators;
using FeatureDemandPlanning.Model.Enumerations;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ForecastComparisonViewModel : SharedModelBase
    {
        #region "Constructors"

        /// <summary>
        /// Initializes a new instance of the <see cref="ForecastComparisonViewModel"/> class.
        /// </summary>
        /// <param name="dataContext">The data context.</param>
        public ForecastComparisonViewModel() : base()
        {
            InitialiseMembers();
        }
        public ForecastComparisonViewModel(SharedModelBase modelBase) : base(modelBase)
        {
            InitialiseMembers();
        }

        #endregion

        #region "Public Properties"

        public IForecast Forecast { get; set; }
        public PagedResults<ForecastSummary> Forecasts { get; set; }

        /// <summary>
        /// Gets or sets the forecast vehicle lookup. This provides a lookup of vehicles for selection lists
        /// associated with the forecast vehicle
        /// </summary>
        /// <value>
        /// The forecast vehicle lookup.
        /// </value>
        public LookupViewModel ForecastVehicleLookup { get; set; }
        
        /// <summary>
        /// Gets or sets the comparison vehicle lookup. This provides a lookup of vehicles for selection lists
        /// associated with each comparison vehicle
        /// </summary>
        /// <value>
        /// The comparison vehicle lookup.
        /// </value>
        public IList<LookupViewModel> ComparisonVehicleLookup { get; set; }

        /// <summary>
        /// Gets the number of comparison vehicles.
        /// </summary>
        /// <value>
        /// The number of comparison vehicles.
        /// </value>
        public int NumberOfComparisonVehicles
        {
            get { return Forecast.ComparisonVehicles.Count(c => !(c is EmptyVehicle)); }
        }

        /// <summary>
        /// Gets the non empty comparison vehicles. We are only interested in the non-empty ones for comparison purposes
        /// </summary>
        /// <value>
        /// The non empty comparison vehicles.
        /// </value>
        public IEnumerable<VehicleWithIndex> NonEmptyComparisonVehicles
        {
            get 
            {
                var index = 0;
                return Forecast.ComparisonVehicles
                    .Where(c => !(c is EmptyVehicle))
                    .Select(c => new VehicleWithIndex()
                    {
                        Vehicle = c,
                        VehicleIndex = ++index 
                    });
            }
        }

        #endregion

        #region "Public Methods"

        public static async Task<ForecastComparisonViewModel> GetModel(IDataContext context, ForecastFilter filter)
        {
            if (filter.ForecastId.HasValue)
            {
                return await GetFullAndPartialViewModelForForecast(context, filter);
            }

            return await GetFullAndPartialViewModelForForecasts(context, filter);
        }

        #endregion

        #region "Private Methods"

        private void InitialiseMembers()
        {
            IdentifierPrefix = "Page";
            Forecast = new EmptyForecast();
            Forecasts = new PagedResults<ForecastSummary>();
        }
        private static async Task<ForecastComparisonViewModel> GetFullAndPartialViewModelForForecast(IDataContext context,
                                                                                                     ForecastFilter filter)
        {
            var modelBase = SharedModelBase.GetBaseModel(context);
            var model = new ForecastComparisonViewModel(modelBase)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            model.Forecast = await context.Forecast.GetForecast(filter);
            InitialiseForecast(model.Forecast, context);

            return model;
        }

        private static async Task<ForecastComparisonViewModel> GetFullAndPartialViewModelForForecasts(IDataContext context, 
                                                                                                      ForecastFilter filter)
        {
            var modelBase = SharedModelBase.GetBaseModel(context);
            var model = new ForecastComparisonViewModel(modelBase)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            model.Forecasts = await context.Forecast.ListForecasts(filter);

            return model;
        }

        private static async void InitialiseForecast(IForecast forecast, IDataContext context)
        {
            await InitialiseForecastVehicle(forecast, context);
            InitialiseComparisonVehicles(forecast, context);
        }
        private static async Task<IVehicle> InitialiseForecastVehicle(IForecast forecast, IDataContext context)
        {
            if (forecast.ForecastVehicle is EmptyVehicle)
            {
                return forecast.ForecastVehicle;
            }

            forecast.ForecastVehicle = (Vehicle)(await InitialiseVehicle(forecast.ForecastVehicle, context));
            return forecast.ForecastVehicle;
        }
        private static async Task<IVehicle> InitialiseVehicle(IVehicle vehicle, IDataContext context)
        {
            var returnValue = await context.Vehicle.GetVehicle(VehicleFilter.FromVehicle(vehicle));
            returnValue.TrimMappings = vehicle.TrimMappings;

            return returnValue;
        }

        /// <summary>
        /// Initialises the comparison vehicles.
        /// The list is re-ordered, placing empty vehicles at the end of the list
        /// </summary>
        private static async void InitialiseComparisonVehicles(IForecast forecast, IDataContext context)
        {
            var newComparisonVehicles = EmptyVehicleList.CreateEmptyVehicleList();
            var nonEmptyVehicles = new List<IVehicle>();

            foreach (var comparisonVehicle in forecast.ComparisonVehicles)
            {
                if (comparisonVehicle is EmptyVehicle)
                {
                    continue;
                }
                nonEmptyVehicles.Add(await InitialiseVehicle(comparisonVehicle, context));
            }

            for (var i = 0; i < nonEmptyVehicles.Count(); i++)
            {
                newComparisonVehicles[i] = nonEmptyVehicles[i];
            }

            forecast.ComparisonVehicles = newComparisonVehicles.Cast<Vehicle>();
        }

        #endregion

        #region "Private Members"
        
        private const string cookieKey = "FdpFbm"; 

        #endregion
    }
}
