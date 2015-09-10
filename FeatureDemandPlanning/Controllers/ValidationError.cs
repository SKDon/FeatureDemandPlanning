using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Controllers
{
    public class ValidationError
    {
        public string key { get; set; }
        public IList<ValidationErrorItem> errors { get; set; }
    }
}
