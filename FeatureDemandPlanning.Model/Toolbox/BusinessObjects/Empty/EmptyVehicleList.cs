using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
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
