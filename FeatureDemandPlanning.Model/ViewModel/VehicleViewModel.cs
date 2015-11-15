using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Comparers;
using FeatureDemandPlanning.Model.Interfaces;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class VehicleViewModel : SharedModelBase
    {
        public int? VehicleIndex { get; set; }
        public VehicleFilter Filter { get; set; }

        public IEnumerable<IVehicle> AvailableVehicles { get; set; }

        public IEnumerable<string> Makes
        {
            get { return AvailableVehicles.Select(v => v.Make).Distinct(); }
        }

        public IEnumerable<object> Programmes
        {
            get
            {
                return AvailableVehicles.Distinct(new UniqueVehicleByNameComparer()).Select(v => new
                {
                    ProgrammeId = v.ProgrammeId,
                    VehicleName = v.Code,
                    Description = v.Description
                });
            }
        }

        public IEnumerable<string> ModelYears
        {
            get { return AvailableVehicles.Select(v => v.ModelYear).Distinct(); }
        }

        public IEnumerable<string> Gateways
        {
            get { return AvailableVehicles.Select(v => v.Gateway).Distinct(); }
        }

        public VehicleViewModel() : base()
        {

        }
    }
}