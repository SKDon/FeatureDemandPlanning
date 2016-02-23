using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Controllers
{
    public class ValidationMessage
    {
        public bool IsValid { get; set; }
        public IList<ValidationError> Errors { get { return _errors; } }

        public ValidationMessage()
        {
            IsValid = true;
        }

        public ValidationMessage(bool isValid) : this()
        {
            IsValid = isValid;
        }

        public ValidationMessage(bool isValid, IEnumerable<ValidationError> errors) : this(isValid)
        {
            _errors = errors.ToList();
        }

        private IList<ValidationError> _errors = Enumerable.Empty<ValidationError>().ToList();
    }
}