using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class UserParameters : JQueryDataTableParameters
    {
        public string CDSId { get; set; }
        public string FullName { get; set; }
        public string FilterMessage { get; set; }
        public bool HideInactiveUsers { get; set; }
        public UserAdminAction Action { get; set; }
        public int? ProgrammeId { get; set; }
        public bool? CanEditProgramme { get; set; }
        public bool? IsAdmin { get; set; }
        public string Roles { get; set; }
        public UserAction RoleAction { get; set; }
        public UserRole Role { get; set; }

        public UserParameters()
        {
            Action = UserAdminAction.NoAction;
            Roles = string.Empty;
        }

        public object GetActionSpecificParameters()
        {
            switch (Action)
            {
                case UserAdminAction.EnableUser:
                case UserAdminAction.DisableUser:
                    return new
                    {
                        CDSId
                    };
                case UserAdminAction.AddProgramme:
                    return new
                    {
                        CDSId,
                        ProgrammeId,
                        CanEditProgramme
                    };
                case UserAdminAction.RemoveProgramme:
                    return new
                    {
                        CDSId,
                        ProgrammeId
                    };
                case UserAdminAction.ManageProgrammes:
                    return new
                    {
                        CDSId,
                        ProgrammeId
                    };
                case UserAdminAction.AddUser:
                    return new
                    {
                        CDSId,
                        FullName,
                        IsAdmin = IsAdmin.GetValueOrDefault()
                    };
                case UserAdminAction.SetAsAdministrator:
                case UserAdminAction.UnsetAsAdministrator:
                    return new
                    {
                        CDSId
                    };
            }

            return new { CDSId, FullName, ProgrammeId, IsAdmin = IsAdmin.GetValueOrDefault()};
        }

        public int? MarketId { get; set; }
    }
}
