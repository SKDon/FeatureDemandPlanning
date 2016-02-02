using System.Net;
using FeatureDemandPlanning.Model.ViewModel;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web;

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