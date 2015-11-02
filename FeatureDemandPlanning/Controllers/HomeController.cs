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
        public async Task<ActionResult> Index()
        {
            var homeModel = await HomeViewModel.GetFullOrPartialViewModel(DataContext);
            return View(homeModel);
        }
    }
}