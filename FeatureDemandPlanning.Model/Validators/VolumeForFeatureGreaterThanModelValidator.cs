using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FluentValidation;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class AllFeatureVolumesMustBeLessThanOrEqualToModel : PropertyValidator
    {
        private const string Message =
           "Volume for feature '{0}' of {1} is greater than the volume for model '{2}' of {3}.";

        public AllFeatureVolumesMustBeLessThanOrEqualToModel()
            : base(Message)
        {
        }
        public IEnumerable<RawTakeRateDataItem> InvalidDataItems { get; set; }
        
        protected override bool IsValid(PropertyValidatorContext context)
        {
            if (_parent == null)
            {
                _parent = context.ParentContext.InstanceToValidate as RawTakeRateData;
            }
            
            var list = context.PropertyValue as IList<RawTakeRateDataItem>;

            if (list == null) return true;

            InvalidDataItems = list.Where(c => c.Volume > GetModelVolume(c));
            
            return InvalidDataItems.Any();
        }
        private int GetModelVolume(RawTakeRateDataItem currentDataItem)
        {
            var model = currentDataItem.ModelId.HasValue ? 
                _parent.SummaryItems.FirstOrDefault(s => s.ModelId == currentDataItem.ModelId) : 
                _parent.SummaryItems.FirstOrDefault(s => s.FdpModelId == currentDataItem.FdpModelId);
            return model != null ? model.Volume : 0;
        }

        private RawTakeRateData _parent;
    }
    public class VolumeForFeatureGreaterThanModelValidator : AbstractValidator<RawTakeRateData>
    {
        private const string Message =
            "Volume for feature '{0}' of {1} is greater than the volume for model '{2}' of {3}.";

        public VolumeForFeatureGreaterThanModelValidator()
        {
            var validator = new AllFeatureVolumesMustBeLessThanOrEqualToModel();

            RuleForEach(d => d.DataItems)
                .SetValidator(validator)
                .WithMessage(Message,
                    (d, c) => c.FeatureDescription,
                    (d, c) => c.Volume,
                    (d, c) => c.Model,
                    (d, c) => GetModelVolume(d, c))
                .WithState(c => new ValidationState(ValidationRule.VolumeForFeatureGreaterThanModel, validator.InvalidDataItems));
        }
        private static int GetModelVolume(RawTakeRateData data, RawTakeRateDataItem currentDataItem)
        {
            var model = currentDataItem.ModelId.HasValue ?
                data.SummaryItems.FirstOrDefault(s => s.ModelId == currentDataItem.ModelId) :
                data.SummaryItems.FirstOrDefault(s => s.FdpModelId == currentDataItem.FdpModelId);

            return model != null ? model.Volume : 0;
        }
    }
}
