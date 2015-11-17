using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpDerivative : Derivative
    {
        public int? FdpDerivativeId { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public Programme Programme { get; set; }

        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public FdpDerivative()
        {
            Programme = new EmptyProgramme();
        }

        public virtual string[] ToJQueryDataTableResult()
        {
            return new string[] 
            { 
                FdpDerivativeId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                DerivativeCode,
                Body.Name,
                Engine.Name,
                Transmission.Name
            };
        }

        public static FdpDerivative FromParameters(DerivativeParameters parameters)
        {
            return new FdpDerivative()
            {
                FdpDerivativeId = parameters.DerivativeId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
