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
    }
}
