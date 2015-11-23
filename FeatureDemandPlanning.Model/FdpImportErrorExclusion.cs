using System;
using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class FdpImportErrorExclusion
    {
        public int? FdpImportErrorExclusionId { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }
        public Programme Programme { get; set; }

        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }
        public bool IsActive { get; set; }

        public string ErrorMessage { get; set; }

        public FdpImportErrorExclusion()
        {
            Programme = new EmptyProgramme();
            IsActive = true;
        }

        public virtual string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpImportErrorExclusionId.GetValueOrDefault().ToString(),
                CreatedOn.GetValueOrDefault().ToString("dd/MM/yyyy"),
                CreatedBy,
                Programme.GetDisplayString(),
                Gateway,
                ErrorMessage
            };
        }

        public static FdpImportErrorExclusion FromParameters(IgnoredExceptionParameters parameters)
        {
            return new FdpImportErrorExclusion()
            {
                FdpImportErrorExclusionId = parameters.IgnoredExceptionId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway
            };
        }
    }
}
