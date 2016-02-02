using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class UserParameters : JQueryDataTableParameters
    {
        public string CDSId { get; set; }
        public string FullName { get; set; }
        public string FilterMessage { get; set; }
        public bool HideInactiveUsers { get; set; }
        public UserAction Action { get; set; }
        public int? ProgrammeId { get; set; }
        public bool? CanEditProgramme { get; set; }
        public bool? IsAdmin { get; set; }
        public string Roles { get; set; }

        public UserParameters()
        {
            Action = UserAction.NotSet;
            Roles = string.Empty;
        }

        public object GetActionSpecificParameters()
        {
            switch (Action)
            {
                case UserAction.EnableUser:
                case UserAction.DisableUser:
                    return new
                    {
                        CDSId
                    };
                case UserAction.AddProgramme:
                    return new
                    {
                        CDSId, ProgrammeId, CanEditProgramme
                    };
                case UserAction.RemoveProgramme:
                    return new
                    {
                        CDSId, ProgrammeId
                    };
                case UserAction.ManageProgrammes:
                    return new
                    {
                        CDSId, ProgrammeId
                    };
                case UserAction.AddUser:
                    return new
                    {
                        CDSId, FullName,
                        IsAdmin = IsAdmin.GetValueOrDefault()
                    };
                case UserAction.SetAsAdministrator:
                case UserAction.UnsetAsAdministrator:
                    return new
                    {
                        CDSId
                    };
            }

            return new { };
        }
    }
}
