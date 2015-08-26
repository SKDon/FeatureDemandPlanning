using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.Interfaces;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Forecast : BusinessObject, IForecast, IValidatableObject
    {
        public int? ForecastId { get; set; }
        public int VehicleId { get; set; }
        public int ProgrammeId { get; set; }
        public int GatewayId { get; set; }

        public new DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        
        public Forecast() 
        { 
            //TODO, build this list from configuration defining the max number of vehicles
            _comparisonVehicles = new List<Vehicle> {
                new EmptyVehicle() ,
                new EmptyVehicle(),
                new EmptyVehicle(),
                new EmptyVehicle(),
                new EmptyVehicle()
            };
        }

        public Vehicle ForecastVehicle 
        {
            get
            {
                return _forecastVehicle;
            }
            set
            {
                _forecastVehicle = value;
            } 
        }

        public IEnumerable<Vehicle> ComparisonVehicles 
        {
            get
            {
                return _comparisonVehicles;
            }
            set
            {
                _comparisonVehicles = value;
            }
        }

        public IEnumerable<TrimMapping> TrimMapping
        {
            get
            {
                return _trimMapping;
            }
            set
            {
                _trimMapping = value;
            }
        }

        public bool IsPersisted()
        {
            return ForecastId.HasValue;
        }

        public bool IsPersisted(ProcessState processState)
        {
            var isPersisted = IsPersisted();
            if (!isPersisted)
            {
                processState.Status = Enumerations.ProcessStatus.Warning;
                processState.Messages = new List<string> { "Forecast has not been saved" };
            }
            return isPersisted;
        }

        public bool IsValid(ProcessState processState)
        {
            var isValid = IsValid();
            if (!isValid)
            {
                processState.Status = Enumerations.ProcessStatus.Warning;
                processState.Messages = ValidationMessages;
            }
            return isValid;
        }

        public bool IsValid()
        {
            var isValid = true;
            ValidationMessages.Clear();

            

            return isValid;
        }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (HasDuplicateComparisonVehicles())
            {
                yield return new ValidationResult("Duplicate comparison vehicles are not allowed");
            }

            if (IsForecastVehicleEquivalentToComparisonVehicle())
            {
                yield return new ValidationResult("Cannot compare the forecast vehicle to itself");
            }
        }

        /// <summary>
        /// Determines whether the forecast has duplicate comparison vehicles.
        /// </summary>
        /// <returns></returns>
        private bool HasDuplicateComparisonVehicles()
        {
            if (ComparisonVehicles == null || !ComparisonVehicles.Any()) 
            {
                return false;
            }

            return ComparisonVehicles.GroupBy(v => v)
                .Where(g => g.Count() > 1)
                .Select(v => v.Key)
                .Count() > 0;
        }

        /// <summary>
        /// Determines whether the forecast vehicle is equivalent to a comparison vehicle.
        /// </summary>
        /// <returns></returns>
        private bool IsForecastVehicleEquivalentToComparisonVehicle()
        {
            if (ForecastVehicle == null || ComparisonVehicles == null)
            {
                return false;
            }

            return ComparisonVehicles.Contains(ForecastVehicle);
        }

        protected internal IList<string> ValidationMessages = new List<string>();

        private Vehicle _forecastVehicle = new EmptyVehicle();
        private IEnumerable<Vehicle> _comparisonVehicles = Enumerable.Empty<Vehicle>();
        private IEnumerable<TrimMapping> _trimMapping = Enumerable.Empty<TrimMapping>();
    }
}