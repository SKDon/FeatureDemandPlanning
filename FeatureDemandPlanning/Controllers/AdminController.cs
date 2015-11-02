using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Comparers;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
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
            ControllerType = ControllerType.SectionChild;
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