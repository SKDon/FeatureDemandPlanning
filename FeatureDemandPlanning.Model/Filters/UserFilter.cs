using FeatureDemandPlanning.Model.Enumerations;
namespace FeatureDemandPlanning.Model.Filters
{
    public class UserFilter : FilterBase
    {
        public string CDSId { get; set; }
        public bool? HideInactiveUsers { get; set; }

        public static UserFilter FromCDSId(string cdsId)
        {
            return new UserFilter()
            {
                CDSId = cdsId,
                HideInactiveUsers = false
            };
        }

        public int? ProgrammeId { get; set; }
        public int? MarketId { get; set; }
        public UserRole Role { get; set; }

        public UserAction RoleAction { get; set; }

        public string Permissions { get; set; }
    }
}
