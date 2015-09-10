using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Controllers
{
    public class ValidationMessage
    {
        public bool IsValid { get; set; }
        public List<ValidationError> Errors { get; set; }
    }
}