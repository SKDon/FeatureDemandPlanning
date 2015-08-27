using FeatureDemandPlanning.BusinessObjects.Validators;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IExtendedValidatableObject : IValidatableObject
    {
        IEnumerable<ExtendedValidationResult> ExtendedValidationResults { get; set; }
    }
}
