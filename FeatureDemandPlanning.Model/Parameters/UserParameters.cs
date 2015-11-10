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

        public UserParameters()
        {
            Action = UserAction.NotSet;
        }

        public object GetActionSpecificParameters()
        {
            if (Action == UserAction.EnableUser || Action == UserAction.DisableUser)
            {
                return new
                {
                    CDSId = CDSId
                };
            }

            if (Action == UserAction.AddProgramme)
            {
                return new
                {
                    CDSId = CDSId,
                    ProgrammeId = ProgrammeId,
                    CanEditProgramme = CanEditProgramme
                };
            }

            if (Action == UserAction.RemoveProgramme)
            {
                return new
                {
                    CDSId = CDSId,
                    ProgrammeId = ProgrammeId
                };
            }

            if (Action == UserAction.ManageProgrammes)
            {
                return new
                {
                    CDSId = CDSId,
                    ProgrammeId = ProgrammeId
                };
            }

            if (Action == UserAction.AddUser)
            {
                return new
                {
                    CDSId = CDSId,
                    FullName = FullName,
                    IsAdmin = IsAdmin.GetValueOrDefault()
                };
            }

            if (Action == UserAction.SetAsAdministrator || Action == UserAction.UnsetAsAdministrator)
            {
                return new
                {
                    CDSId = CDSId
                };
            }

            return new { };
        }
    }
}
