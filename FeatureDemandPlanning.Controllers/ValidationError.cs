using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Controllers
{
    public class ValidationError
    {
        public string key { get; set; }
        public IList<ValidationErrorItem> errors { get { return _errors; } }

        public ValidationError()
        {
        }

        public ValidationError(ValidationErrorItem error)
        {
            _errors = new List<ValidationErrorItem>() { error };
        }

        public ValidationError(IEnumerable<ValidationErrorItem> errors)
        {
            _errors = errors.ToList();
        }

        private IList<ValidationErrorItem> _errors = Enumerable.Empty<ValidationErrorItem>().ToList();
    }
}
