using FeatureDemandPlanning.Model.ViewModel;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class HomeController : ControllerBase
    {
        public async Task<ActionResult> Index()
        {
            Log.Debug("Test");
            var homeModel = await HomeViewModel.GetFullOrPartialViewModel(DataContext);
            return View(homeModel);
        }
    }
}