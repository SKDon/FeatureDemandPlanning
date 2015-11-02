using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class VehicleController : ControllerBase
    {
        [HttpPost]
        public ActionResult FilterVehicles(VehicleFilter filter)
        {
            return Json(GetFullAndPartialVehicleViewModel(filter));
        }

        private VehicleViewModel GetFullAndPartialVehicleViewModel(VehicleFilter filter)
        {        
            var vehicleViewModel = new VehicleViewModel(DataContext)
            {
                VehicleIndex = filter.VehicleIndex,
                Filter = filter,
                AvailableVehicles = ListAvailableVehicles(filter),
                PageSize = this.PageSize,
                PageIndex = this.PageIndex
            };

            return vehicleViewModel;
        }

        private IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter)
        {
            var cacheKey = string.Format("VehicleFilter_{0}", filter.GetHashCode());
            IEnumerable<IVehicle> vehicles = (IEnumerable<IVehicle>)HttpContext.Cache.Get(cacheKey);

            if (vehicles != null)
                return vehicles;

            vehicles = DataContext.Vehicle.ListAvailableVehicles(filter);

            HttpContext.Cache.Add(cacheKey, vehicles, null, DateTime.Now.AddMinutes(60), Cache.NoSlidingExpiration, CacheItemPriority.Default, null);

            return vehicles;
        }
    }
}