using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class UserProgrammeMapping
    {
        public int ProgrammeId { get; set; }
        public UserAction Action { get { return FdpUserActionId; } set { FdpUserActionId = value; } }
        public UserAction FdpUserActionId { get; set; }

        public string VehicleName { get; set; }
        public string ModelYear { get; set; }
    }
}
