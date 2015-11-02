using FeatureDemandPlanning.Model.Validators;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IExtendedValidatableObject : IValidatableObject
    {
        IEnumerable<ExtendedValidationResult> ExtendedValidationResults { get; set; }
    }
}
