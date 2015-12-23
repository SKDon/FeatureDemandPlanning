using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class AllModelVolumesMustBeLessThanMarketVolume : PropertyValidator
    {
        public AllModelVolumesMustBeLessThanMarketVolume(IDataContext context)
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
                return !changes.Any(IsVolumeGreaterThanVolumeForMarket);
            }

            return true;
        }

        private bool IsVolumeGreaterThanVolumeForMarket(DataChange change)
        {
            if (!change.IsModelSummary)
                return false;

            var filter = TakeRateFilter.FromTakeRateParameters(Parameters);
            var marketVolume = _context.TakeRate.GetVolumeForMarket(filter).Result;

            return change.Volume > marketVolume;
        }

        private readonly IDataContext _context;
    }
}