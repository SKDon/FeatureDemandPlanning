using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class AllFeatureVolumesMustBeLessThanModelVolume : PropertyValidator
    {
        public AllFeatureVolumesMustBeLessThanModelVolume(IDataContext context)
            : base("Feature volume cannot be greater than the volume for the model")
        {
            _context = context;
        }

        protected TakeRateParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as TakeRateParameters;
            var changes = context.PropertyValue as IEnumerable<DataChange>;

            if (changes != null)
            {
                return !changes.Any(IsFeatureVolumeGreaterThanVolumeForModel);
            }

            return true;
        }

        private bool IsFeatureVolumeGreaterThanVolumeForModel(DataChange change)
        {
            if (!change.IsFeatureChange)
                return false;

            var filter = TakeRateFilter.FromTakeRateParameters(Parameters);
            if (change.IsFdpModel)
            {
                filter.FdpModelId = change.GetModelId();
            }
            else
            {
                filter.ModelId = change.GetModelId();
            }
            var modelVolume = _context.TakeRate.GetVolumeForModel(filter).Result;

            return change.Volume > modelVolume;
        }

        private readonly IDataContext _context;
    }
}