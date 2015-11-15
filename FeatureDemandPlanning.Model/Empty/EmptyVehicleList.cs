using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class EmptyVehicleList
    {
        public static IList<IVehicle> CreateEmptyVehicleList()
        {
            var emptyList = new List<IVehicle>();
            InitialiseEmptyList(emptyList);

            return emptyList;
        }

        private static void InitialiseEmptyList(IList<IVehicle> listToInitialise)
        {
            listToInitialise.Add(new EmptyVehicle());
            listToInitialise.Add(new EmptyVehicle());
            listToInitialise.Add(new EmptyVehicle());
            listToInitialise.Add(new EmptyVehicle());
            listToInitialise.Add(new EmptyVehicle());
        }
    }
}
