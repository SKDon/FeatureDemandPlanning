using FluentValidation;
using FeatureDemandPlanning.BusinessObjects;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public class ComparisonVehicleValidator : VehicleValidator
    {
        public IEnumerable<Vehicle> InvalidVehicles { get; set; }
        
        public ComparisonVehicleValidator() : base()
        {
        }
    }

    public class ComparisonVehicleDuplicateValidator : AbstractValidator<Vehicle>
    {
        public const string duplicateComparisonVehicle = "Comparison vehicle '{0}' has been specified more than once";

        public IEnumerable<VehicleWithIndex> DuplicateVehicles { get { return _duplicateVehicles; } }
        public IEnumerable<Vehicle> ComparisonVehicles { get; set; }
        public int CurrentVehicleIndex { get; set; }
        
        public ComparisonVehicleDuplicateValidator(IEnumerable<Vehicle> comparisonVehicles)
        {
            ComparisonVehicles = comparisonVehicles;
            RuleFor(c => c)
                .Must(HaveNoDuplicates)
                .WithName("ComparisonVehicle")
                .WithMessage(duplicateComparisonVehicle, c => c.Description)
                .WithState(v => DuplicateVehicles);
        }

        private bool HaveNoDuplicates(Vehicle comparisonVehicle)
        {
            _duplicateVehicles = new List<VehicleWithIndex>();

            var currentIndex = 0;
            foreach (var otherVehicle in ComparisonVehicles)
            {
                if (currentIndex == CurrentVehicleIndex)
                {
                    currentIndex++;
                    continue;
                }

                if (otherVehicle == comparisonVehicle)
                {
                    _duplicateVehicles.Add(new VehicleWithIndex() 
                        { 
                            VehicleIndex = currentIndex, 
                            Vehicle = comparisonVehicle 
                        });
                }
                currentIndex++;
            }
            
            return _duplicateVehicles.Count() == 0;
        }

        private IList<VehicleWithIndex> _duplicateVehicles = new List<VehicleWithIndex>();
    }

    public class VehicleWithIndex
    {
        public int VehicleIndex { get; set; }
        public Vehicle Vehicle { get; set; }
    }
}
