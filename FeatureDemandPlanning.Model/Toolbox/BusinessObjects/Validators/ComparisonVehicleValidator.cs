using FluentValidation;
using FeatureDemandPlanning.BusinessObjects;
using System.Collections.Generic;
using System.Linq;
using System;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public class ComparisonVehicleValidator : VehicleValidator
    {
        public IEnumerable<Vehicle> InvalidVehicles { get; set; }
        
        public ComparisonVehicleValidator() : base()
        {
        }
    }

    public class ComparisonVehicleDuplicateValidator : AbstractValidator<VehicleWithIndex>
    {
        public const string duplicateComparisonVehicle = "Comparison vehicle '{0}' has been specified more than once";

        public IEnumerable<VehicleWithIndex> DuplicateVehicles { get { return _duplicateVehicles; } }
        public IEnumerable<VehicleWithIndex> ComparisonVehicles { get; set; }
        
        public ComparisonVehicleDuplicateValidator(IEnumerable<VehicleWithIndex> comparisonVehicles)
        {
            var index = 1;
            ComparisonVehicles = comparisonVehicles
                .Where(c => !(c.Vehicle is EmptyVehicle)).ToList();
                //.Select(c => new VehicleWithIndex() { VehicleIndex = index++, Vehicle = c }).ToList();
            
            _duplicateVehicles = ListDuplicates().ToList();

            RuleSet("ComparisonVehicles", () =>
            {
                RuleFor(c => c)
                    .Must(HaveNoDuplicates)
                    .WithName("ComparisonVehicle")
                    .WithMessage(duplicateComparisonVehicle, c => c.Vehicle.Description)
                    .WithState(v => _duplicatesForCurrentVehicle);
            });
        }

        private bool HaveNoDuplicates(VehicleWithIndex comparisonVehicle)
        {
            _duplicatesForCurrentVehicle = DuplicateVehicles.Where(v => v.Vehicle == comparisonVehicle.Vehicle);
            return !_duplicatesForCurrentVehicle.Any();
        }

        private IEnumerable<VehicleWithIndex> ListDuplicates()
        {
            var duplicatesWithIndices = ComparisonVehicles
                //.Select((vehicle, index) => new { vehicle, index = index + 1 })
                .GroupBy(v => v.Vehicle)
                .Select(vg => new VehicleGroup() {
                    Vehicle = vg.Key,
                    Indices = vg.Select(i => i.VehicleIndex)
                })
                .Where(v => v.Indices.Count() > 1).ToList();

            foreach (var duplicate in duplicatesWithIndices)
            {
                foreach (var duplicateIndex in duplicate.Indices)
                {
                    yield return new VehicleWithIndex()
                    {
                        VehicleIndex = duplicateIndex,
                        Vehicle = duplicate.Vehicle
                    };
                }
            }
        }

        private IEnumerable<VehicleWithIndex> _duplicateVehicles = Enumerable.Empty<VehicleWithIndex>();
        private IEnumerable<VehicleWithIndex> _duplicatesForCurrentVehicle = Enumerable.Empty<VehicleWithIndex>();
    }

    public class VehicleWithIndex : IEquatable<VehicleWithIndex>
    {
        public int VehicleIndex { get; set; }
        public Vehicle Vehicle { get; set; }

        public override int GetHashCode()
        {
            return Vehicle.GetHashCode();
        }

        public bool Equals(VehicleWithIndex other)
        {
            return Vehicle == other.Vehicle;
        }
    }

    public class VehicleGroup
    {
        public Vehicle Vehicle { get; set; }
        public IEnumerable<int> Indices { get; set; }
    }
}
