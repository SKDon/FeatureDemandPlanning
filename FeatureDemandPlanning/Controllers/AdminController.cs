using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Comparers;
using FeatureDemandPlanning.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Controllers
{
    public class AdminController : ControllerBase
    {  
        public AdminController()
        {
            _adminModel = new AdminViewModel(DataContext);

            PageIndex = 1;
            PageSize = DataContext.ConfigurationSettings.DefaultPageSize;
            ControllerType = Controllers.ControllerType.SectionChild;
        }

        [HttpGet]
        public ActionResult Index()
        {
            return View(_adminModel);
        }

        public ActionResult Derivative()
        {
            return View("Derivatives", _adminModel);
        }

        public ActionResult Users()
        {
            return View("Users", _adminModel);
        }

        private AdminViewModel _adminModel;
   }
}