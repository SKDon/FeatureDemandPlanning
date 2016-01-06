using FeatureDemandPlanning.Model.Enumerations;
using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Model.Validators
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
