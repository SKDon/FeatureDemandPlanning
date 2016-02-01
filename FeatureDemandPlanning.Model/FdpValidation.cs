using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class FdpValidation
    {
        public IEnumerable<ValidationResult> ValidationResults { get; set; }

        public FdpValidation()
        {
            ValidationResults = Enumerable.Empty<ValidationResult>();
        }
    }
}
