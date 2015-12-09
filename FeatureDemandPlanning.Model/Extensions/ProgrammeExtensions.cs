using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
        public static IEnumerable<Gateway> ListGateways(this IEnumerable<Programme> programmes)
        {
            return programmes
                .Select(p => new Gateway()
                {
                    VehicleName = p.VehicleName,
                    Name = p.Gateway,
                    ModelYear = p.ModelYear
                })
                .Distinct(new GatewayComparer())
                .OrderBy(p => p.Name);
        }
        public static IEnumerable<ModelYear> ListModelYears(this IEnumerable<Programme> programmes)
        {
            return programmes
                .Select(p => new ModelYear()
                {
                    VehicleName = p.VehicleName,
                    Name = p.ModelYear
                })
                .Distinct(new ModelYearComparer())
                .OrderBy(p => p.Name);
        }
    }
}
