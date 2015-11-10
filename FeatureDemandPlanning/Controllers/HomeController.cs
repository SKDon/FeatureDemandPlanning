using FeatureDemandPlanning.Model.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class HomeController : ControllerBase
    {
        //[OutputCache(Duration = 600, VaryByParam="")]
        public async Task<ActionResult> Index()
        {
            var homeModel = await HomeViewModel.GetFullOrPartialViewModel(DataContext);
            return View(homeModel);
        }
    }
}