using System;
using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FluentValidation.Validators;

namespace FeatureDemandPlanning.Model.Validators
{
    public class BrochureModelCodeUniqueValidator : PropertyValidator
    {
        public BrochureModelCodeUniqueValidator(IDataContext context) : base("Brochure Model Code is already in use in this OXO Document. Codes must be unique")
        {
            _context = context;
        }
        protected DerivativeMappingParameters Parameters { get; set; }

        protected override bool IsValid(PropertyValidatorContext context)
        {
            Parameters = context.ParentContext.InstanceToValidate as DerivativeMappingParameters;

            var filter = DerivativeMappingFilter.FromDerivativeMappingParameters(Parameters);
            filter.PageSize = int.MaxValue;

            var oxoDerivatives =
                _context.Vehicle.ListOxoDerivatives(filter).Result;

            return
                !oxoDerivatives.CurrentPage.Any(IsExistingBmc);
        }

        private bool IsExistingBmc(OxoDerivative derivative)
        {
            return derivative.DocumentId == Parameters.DocumentId &&
                   derivative.DerivativeCode.Equals(Parameters.DerivativeCode, StringComparison.OrdinalIgnoreCase);
        }

        private readonly IDataContext _context;
        
    }
}
