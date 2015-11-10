using FeatureDemandPlanning.Model.ViewModel;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Controllers
{
    public class NewsController : ControllerBase
    {
		[HttpGet]
        [ActionName("Index")]
        public async Task<ActionResult> NewsPage()
        {
            var newsModel = await NewsViewModel.GetFullOrPartialViewModel(DataContext);
            return View("NewsPage", newsModel);
        }
    }
}