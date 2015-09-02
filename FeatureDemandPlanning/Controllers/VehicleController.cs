using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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
                AvailableVehicles = DataContext.Vehicle.ListAvailableVehicles(filter),
                PageSize = this.PageSize,
                PageIndex = this.PageIndex
            };

            return vehicleViewModel;
        }
    }
}