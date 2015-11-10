using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using System.Web.Mvc;

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