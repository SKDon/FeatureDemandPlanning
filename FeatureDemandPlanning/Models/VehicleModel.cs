using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.Models
{
    public class VehicleModel
    {
        public VehicleModel(IVehicleDataContext dataContext)
        {
            _dataContext = dataContext;
        }

        //public IEnumerable<IVehicle> ListAvailableVehicles(IVehicle filterVehicle) 
        //{ 
        //    IEnumerable<IVehicle> availableVehicles = _dataContext.ListAvailableVehicles();

        //    if (!availableVehicles.Any())
        //    {
        //        availableVehicles = _dataContext.ListAvailableVehicles();
        //    }
        //    if (filterVehicle == null)
        //    {
        //        return availableVehicles;
        //    }
        //    return availableVehicles.Where(v => v.Equals(filterVehicle));
        //}

        private IVehicleDataContext _dataContext = null;
    }
}