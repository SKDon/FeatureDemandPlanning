using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Web.Mvc;
using FeatureDemandPlanning.Dapper;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.BusinessObjects.Validators;
using da = System.ComponentModel.DataAnnotations;
using FluentValidation;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Forecast : BusinessObject, IForecast//, da.IValidatableObject
    {
        public int? ForecastId { get; set; }
 
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
                // Cast to a type vehicle to avoid simply setting the values of an empty vehicle
                if (value is EmptyVehicle && value.ProgrammeId.GetValueOrDefault() != 0)
                {
                    _forecastVehicle = Vehicle.FromVehicle(value);
                }
                else
                {
                    _forecastVehicle = value;
                }
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
                ReplaceNullValuesWithEmptyVehicles();
            }
        }

        public IEnumerable<VehicleWithIndex> ComparisonVehiclesWithIndex
        {
            get { return _comparisonVehicles.ToVehicleWithIndexList(); }
        }

        public IEnumerable<ForecastTrimMapping> TrimMapping
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

        public IEnumerable<ExtendedValidationResult> ExtendedValidationResults
        {
            get
            {
                return _extendedValidationResults;
            }
            set
            {
                _extendedValidationResults = value;
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

        public IEnumerable<da.ValidationResult> Validate(da.ValidationContext validationContext)
        {
            var validator = new ForecastValidator(this);
            var result = validator.Validate(this);

            return result.Errors.Select(error => 
                new da.ValidationResult(PrependProcessStatusToString(error.ErrorMessage, ProcessStatus.Warning), 
                    new [] { error.PropertyName }));
        }

        private void ReplaceNullValuesWithEmptyVehicles()
        {
            var comparisonVehicleList = new List<Vehicle>();
      
            foreach (var comparisonVehicle in _comparisonVehicles) {
                if (comparisonVehicle.ProgrammeId.HasValue) 
                {
                    comparisonVehicleList.Add(comparisonVehicle);
                }
                else
                {
                    comparisonVehicleList.Add(new EmptyVehicle());
                }
            }

            _comparisonVehicles = comparisonVehicleList;
        }

        private string PrependProcessStatusToString(string inputString, ProcessStatus status)
        {
            return string.Format("{0}::{1}", status, inputString);
        }

        #region "Private Members"

        private Vehicle _forecastVehicle = new EmptyVehicle();
        private IEnumerable<Vehicle> _comparisonVehicles = Enumerable.Empty<Vehicle>();
        private IEnumerable<ForecastTrimMapping> _trimMapping = Enumerable.Empty<ForecastTrimMapping>();
        private IEnumerable<ExtendedValidationResult> _extendedValidationResults = Enumerable.Empty<ExtendedValidationResult>();

        #endregion
    }
}