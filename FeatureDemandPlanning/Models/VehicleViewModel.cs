using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Comparers;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
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
            get { return AvailableVehicles.Distinct(new UniqueVehicleByNameComparer()).Select(v => new 
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

        public dynamic Configuration { get; set; }

        public VehicleViewModel(IDataContext dataContext) : base(dataContext)
        {

        }
    }
}