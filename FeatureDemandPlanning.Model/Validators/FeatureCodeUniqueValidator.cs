using System;
using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class FeatureOrPackSpecifiedValidator : PropertyValidator
    {
        public FeatureOrPackSpecifiedValidator()
            : base("Feature Id or Feature Pack Id not specified")
        {
        }
        protected FeatureMappingParameters Parameters { get; set; }
        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as FeatureMappingParameters;

            return Parameters.FeatureId.HasValue || Parameters.FeaturePackId.HasValue;
        }
    }
    public class FeatureCodeUniqueValidator : PropertyValidator
    {
        public FeatureCodeUniqueValidator(IDataContext context)
            : base("Feature Code is already in use in this OXO Document. Codes must be unique")
        {
            _context = context;
        }
        protected FeatureMappingParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as FeatureMappingParameters;

            var filter = FeatureMappingFilter.FromFeatureMappingParameters(Parameters);
            filter.PageSize = int.MaxValue;

            var oxoFeatures =
                _context.Vehicle.ListOxoFeatures(filter).Result;

            return
                !oxoFeatures.CurrentPage.Any(IsExistingFeatureCode);
        }

        private bool IsExistingFeatureCode(OxoFeature feature)
        {
            return feature.DocumentId == Parameters.DocumentId &&
                    !string.IsNullOrEmpty(feature.FeatureCode) &&
                   feature.FeatureCode.Equals(Parameters.FeatureCode, StringComparison.OrdinalIgnoreCase);
        }

        private readonly IDataContext _context;
        
    }
}
