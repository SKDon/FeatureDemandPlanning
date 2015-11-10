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
           ControllerType = ControllerType.Default;
        }

        [HttpGet]
        //[OutputCache(Duration=600, VaryByParam="")]
        public ActionResult Index()
        {
            var model = AdminViewModel.GetModel(DataContext);
            return View(model);
        }
   }
}