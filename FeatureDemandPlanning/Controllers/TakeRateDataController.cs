using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Attributes;

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Primary controller for handling viewing / editing and updating of volume (take rate information)
    /// </summary>
    public class TakeRateDataController : ControllerBase
    {
        #region "Constructors"

        public TakeRateDataController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }

        #endregion

        [HttpGet]
        [ActionName("Index")]
        public ActionResult TakeRateDataPage()
        {
            return RedirectToAction("TakeRateDataPage", new TakeRateDataParameters());
        }
        [HttpGet]
        public async Task<ActionResult> TakeRateDataPage(TakeRateDataParameters parameters)
        {
            ValidateTakeRateDataParameters(parameters, TakeRateParametersValidator.NoValidation);
            
            var takeRateDataView = await TakeRateDataViewModel.GetModel(DataContext, TakeRateDataFilter.FromParameters(parameters));

            return View(takeRateDataView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListTakeRateData(TakeRateDataParameters parameters)
        {
            ValidateTakeRateDataParameters(parameters, TakeRateDataParametersValidator.NoValidation);

            var filter = new TakeRateDataFilter()
            {
                FilterMessage = parameters.FilterMessage
            };
            filter.InitialiseFromJson(parameters);

            var results = await TakeRateDataViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Data.RawData)
            {
                //jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        private static void ValidateTakeRateDataParameters(TakeRateDataParameters parameters, string ruleSetName)
        {
            var validator = new TakeRateDataParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class TakeRateDataParametersValidator : AbstractValidator<TakeRateDataParameters>
    {
        public const string NoValidation = "NO_VALIDATION";

        public TakeRateDataParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {
            });
        }
    }
}