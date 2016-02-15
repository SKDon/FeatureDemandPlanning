using System.Linq;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToProgrammePolicy : SecurityPolicyBase
    {
        public HasAccessToProgrammePolicy(IDataContext context) : base(context)
        {
        }

        public override PolicyResult Enforce(ISecurityContext context)
        {
            var programmeId = GetProgrammeParameter(context);
            var takeRateId = GetTakeRateParameter(context);

            if (!programmeId.HasValue && takeRateId.HasValue)
            {
                programmeId = GetProgrammeIdFromTakeRate(takeRateId.Value);
            }
            if (!programmeId.HasValue || HasAccessToProgramme(programmeId.Value))
            {
                return PolicyResult.CreateSuccessResult(this);
            }

            return PolicyResult.CreateFailureResult(this, string.Format("User '{0}' does not have sufficient permissions to access data for programme '{1}'.",
                SecurityHelper.GetAuthenticatedUser(),
                GetProgrammeName(programmeId.Value)));
        }
        private int? GetProgrammeParameter(ISecurityContext context)
        {
            int programmeId;
            var programmeParameter = GetActionParameter("ProgrammeId", context);
            if (!string.IsNullOrEmpty(programmeParameter) && int.TryParse(programmeParameter, out programmeId) && programmeId != 0)
            {
                return programmeId;
            }
            return null;
        }
        private int? GetTakeRateParameter(ISecurityContext context)
        {
            int takeRateId;
            var takeRateParameter = GetActionParameter("TakeRateId", context);
            if (!string.IsNullOrEmpty(takeRateParameter) && int.TryParse(takeRateParameter, out takeRateId) && takeRateId != 0)
            {
                return takeRateId;
            }
            return null;
        }
        private int? GetProgrammeIdFromTakeRate(int takeRateId)
        {
            var document = Context.TakeRate.GetUnderlyingOxoDocument(new TakeRateFilter() { TakeRateId = takeRateId }).Result;
            if (document == null || document is EmptyOxoDocument)
            {
                return null;
            }
            return document.ProgrammeId;
        }
        private bool HasAccessToProgramme(int programmeId)
        {
            var user = Context.User.GetUser();

            return user.Programmes.Any(m => m.ProgrammeId == programmeId);
        }
        private string GetProgrammeName(int programmeId)
        {
            var programme = Context.TakeRate.GetProgramme(new TakeRateFilter()
            {
                ProgrammeId = programmeId 
            }).Result;

            return programme != null
                ? string.Format("{0} ({1})", programme.VehicleName, programme.ModelYear)
                : string.Empty;
        }
    }
}