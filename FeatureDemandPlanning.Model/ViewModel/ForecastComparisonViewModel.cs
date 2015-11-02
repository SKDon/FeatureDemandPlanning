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

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class ForecastComparisonViewModel : SharedModelBase
    {
        #region "Constructors"

        /// <summary>
        /// Initializes a new instance of the <see cref="ForecastComparisonViewModel"/> class.
        /// </summary>
        /// <param name="dataContext">The data context.</param>
        public ForecastComparisonViewModel(IDataContext dataContext)
            : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
            CookieKey = cookieKey;
        }

        #endregion

        #region "Public Properties"

        /// <summary>
        /// Gets or sets the forecast. This is the primary model which all pages that work with forecasts will use 
        /// </summary>
        /// <value>
        /// The forecast.
        /// </value>
        public IForecast Forecast
        {
            get 
            { 
                return _forecast; 
            }
            set 
            { 
                _forecast = value;
                InitialiseForecast();
            }
        }

        /// <summary>
        /// Gets or sets the forecasts for use in pages containing search results
        /// </summary>
        /// <value>
        /// The forecasts.
        /// </value>
        public PagedResults<ForecastSummary> Forecasts
        {
            get { return _forecasts; }
            set { _forecasts = value; }
        }

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

        /// <summary>
        /// Gets or sets the configuration information. This is used to determine the behaviour of the client-side scripting model
        /// </summary>
        /// <value>
        /// The configuration.
        /// </value>
        public dynamic Configuration { get; set; }

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

        private void InitialiseForecast()
        {
            InitialiseForecastVehicle();
            InitialiseComparisonVehicles();
        }

        private void InitialiseForecastVehicle()
        {
            if (Forecast.ForecastVehicle is EmptyVehicle)
            {
                return;
            }

            Forecast.ForecastVehicle = (Vehicle)InitialiseVehicle(Forecast.ForecastVehicle);
        }

        /// <summary>
        /// Initialises the comparison vehicles.
        /// The list is re-ordered, placing empty vehicles at the end of the list
        /// </summary>
        private void InitialiseComparisonVehicles()
        {
            var newComparisonVehicles = EmptyVehicleList.CreateEmptyVehicleList();
            var nonEmptyVehicles = new List<IVehicle>();

            foreach (var comparisonVehicle in Forecast.ComparisonVehicles)
            {
                if (comparisonVehicle is EmptyVehicle)
                {
                    continue;
                }
                nonEmptyVehicles.Add(InitialiseVehicle(comparisonVehicle));
            }

            for (var i = 0; i < nonEmptyVehicles.Count(); i++)
            {
                newComparisonVehicles[i] = nonEmptyVehicles[i];
            }

            Forecast.ComparisonVehicles = newComparisonVehicles.Cast<Vehicle>();
        }

        private new IVehicle InitialiseVehicle(IVehicle vehicle)
        {
            var returnValue = this.DataContext.Vehicle.GetVehicle(VehicleFilter.FromVehicle(vehicle));
            returnValue.TrimMappings = vehicle.TrimMappings;

            return returnValue;
        }
        private static async Task<ForecastComparisonViewModel> GetFullAndPartialViewModelForForecast(IDataContext context,
                                                                                                     ForecastFilter filter)
        {
            var model = new ForecastComparisonViewModel(context)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue
            };
            model.Forecast = await context.Forecast.GetForecast(filter);

            return model;
        }

        private static async Task<ForecastComparisonViewModel> GetFullAndPartialViewModelForForecasts(IDataContext context, 
                                                                                                      ForecastFilter filter)
        {
            var model = new ForecastComparisonViewModel(context)
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue
            };
            model.Forecasts = await context.Forecast.ListForecasts(filter);

            return model;
        }

        #endregion

        #region "Private Members"

        private IForecast _forecast = new EmptyForecast();
        private PagedResults<ForecastSummary> _forecasts = new PagedResults<ForecastSummary>();
        
        private const string cookieKey = "FdpFbm"; 

        #endregion
    }
}
