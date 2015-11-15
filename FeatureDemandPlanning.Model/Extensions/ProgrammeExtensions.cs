using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Extensions
{
    public static class ProgrammeExtensions
    {
        public static string GetDisplayString(this Programme programme)
        {
            return string.Format("{0} - {1} ({2})", programme.VehicleName, programme.VehicleAKA, programme.ModelYear);
        }

        public static IEnumerable<CarLine> ListCarLines(this IEnumerable<Programme> programmes)
        {
            return programmes.Select(p => new CarLine()
            {
                VehicleId = p.VehicleId,
                VehicleName = p.VehicleName,
                VehicleAKA = p.VehicleAKA
            })
            .Distinct(new CarLineComparer())
            .OrderBy(c => c.VehicleName);
        }
    }
}
