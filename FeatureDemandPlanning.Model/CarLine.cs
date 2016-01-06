using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class CarLine
    {
        public int? VehicleId { get; set; }
        public string VehicleName { get; set; }
        public string VehicleAKA { get; set; }
    }

    public class CarLineComparer : IEqualityComparer<CarLine>
    {
        public bool Equals(CarLine x, CarLine y)
        {
            return x.VehicleId == y.VehicleId;
        }

        public int GetHashCode(CarLine obj)
        {
            return obj.VehicleId.GetHashCode();
        }
    }
}
