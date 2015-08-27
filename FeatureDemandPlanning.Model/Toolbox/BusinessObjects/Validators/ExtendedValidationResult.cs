using FeatureDemandPlanning.Enumerations;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.BusinessObjects.Validators
{
    public class ExtendedValidationResult : ValidationResult
    {
        public ProcessStatus Status { get; set; }
        public object CustomState { get; set; }

        public ExtendedValidationResult(string errorMessage) : base(errorMessage)
        {
            Status = ProcessStatus.Warning;
            CustomState = new EmptyCustomState();
        }

        public ExtendedValidationResult(string errorMessage, 
                                        ProcessStatus status,
                                        object customState) : base(errorMessage)
        {
            Status = status;
            CustomState = customState;
        }
    }
}
