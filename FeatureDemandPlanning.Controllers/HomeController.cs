using System;
using FeatureDemandPlanning.Model.ViewModel;
using System.Threading.Tasks;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    public class HomeController : ControllerBase
    {
        public HomeController(IDataContext context) : base(context)
        {
        }
        public async Task<ActionResult> Index()
        {
            var homeModel = await HomeViewModel.GetFullOrPartialViewModel(DataContext);
            return View(homeModel);
        }
    }
}