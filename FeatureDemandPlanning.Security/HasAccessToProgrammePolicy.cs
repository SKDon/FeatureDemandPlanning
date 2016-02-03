using System.Linq;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FluentSecurity;

namespace FeatureDemandPlanning.Security
{
    public class HasAccessToProgrammePolicy : PolicyBase
    {
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
        private static int? GetProgrammeIdFromTakeRate(int takeRateId)
        {
            IDataContext context = new DataContext(SecurityHelper.GetAuthenticatedUser());
            var document = context.TakeRate.GetUnderlyingOxoDocument(new TakeRateFilter() { TakeRateId = takeRateId }).Result;
            if (document == null || document is EmptyOxoDocument)
            {
                return null;
            }
            return document.ProgrammeId;
        }
        private static bool HasAccessToProgramme(int programmeId)
        {
            IDataContext context = new DataContext(SecurityHelper.GetAuthenticatedUser());
            var user = context.User.GetUser();

            return user.Programmes.Any(m => m.ProgrammeId == programmeId);
        }
        private static string GetProgrammeName(int programmeId)
        {
            IDataContext context = new DataContext(SecurityHelper.GetAuthenticatedUser());
            var programme = context.TakeRate.GetProgramme(new TakeRateFilter()
            {
                ProgrammeId = programmeId 
            }).Result;

            return programme != null
                ? string.Format("{0} ({1})", programme.VehicleName, programme.ModelYear)
                : string.Empty;
        }
    }
}