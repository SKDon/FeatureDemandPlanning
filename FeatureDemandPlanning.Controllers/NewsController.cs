using FeatureDemandPlanning.Model.ViewModel;
using System.Threading.Tasks;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;

namespace FeatureDemandPlanning.Controllers
{
    public class NewsController : ControllerBase
    {
        public NewsController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        public async Task<ActionResult> NewsPage()
        {
            var newsModel = await NewsViewModel.GetFullOrPartialViewModel(DataContext);
            return View("NewsPage", newsModel);
        }
    }
}