using System;
using System.Linq;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class DpckUniqueValidator : PropertyValidator
    {
        public DpckUniqueValidator(IDataContext context) : base("DPCK Code is already in use in this OXO Document. Codes must be unique")
        {
            _context = context;
        }
        protected TrimMappingParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as TrimMappingParameters;

            var filter = TrimMappingFilter.FromTrimMappingParameters(Parameters);
            filter.PageSize = int.MaxValue;

            var oxoTrimLevels =
                _context.Vehicle.ListOxoTrim(filter).Result;

            return
                !oxoTrimLevels.CurrentPage.Any(IsExistingDpck);
        }

        private bool IsExistingDpck(OxoTrim trim)
        {
            return trim.DocumentId == Parameters.DocumentId &&
                    !string.IsNullOrEmpty(trim.DPCK) &&
                   trim.DPCK.Equals(Parameters.Dpck, StringComparison.OrdinalIgnoreCase);
        }

        private readonly IDataContext _context;
        
    }
}
