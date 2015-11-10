using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.ViewModel;
using FluentValidation;
using System;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Controllers
{
    public class UserController : ControllerBase
    {
        public UserController() : base()
        {
            ControllerType = ControllerType.SectionChild;
        }
        [HttpGet]
        [ActionName("Index")]
        public ActionResult UserPage()
        {
            return RedirectToAction("UserPage");
        }
        [HttpGet]
        public async Task<ActionResult> UserPage(UserParameters parameters)
        {
            var filter = new UserFilter()
            {
                CDSId = parameters.CDSId,
                PageIndex = PageIndex,
                PageSize = PageSize
            };
            return View(await UserViewModel.GetModel(DataContext, filter));
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListUsers(UserParameters parameters)
        {
            ValidateUserParameters(parameters, UserParametersValidator.NoValidation);

            var js = new JavaScriptSerializer();
            var filter = new UserFilter()
            {
                CDSId = parameters.CDSId,
                FilterMessage = parameters.FilterMessage,
                HideInactiveUsers = parameters.HideInactiveUsers
            };
            filter.InitialiseFromJson(parameters);

            var results = await UserViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            foreach (var result in results.Users.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }

            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(UserParameters parameters)
        {
            ValidateUserParameters(parameters, UserParametersValidator.UserIdentifier);

            var userView = await UserViewModel.GetModel(
                DataContext,
                UserFilter.FromCDSId(parameters.CDSId));

            return PartialView("_ContextMenu", userView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(UserParameters parameters)
        {
            ValidateUserParameters(parameters, UserParametersValidator.Action);

            var userView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), userView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(UserParameters parameters)
        {
            ValidateUserParameters(parameters, UserParametersValidator.UserIdentifierWithAction);
            ValidateUserParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddUser(UserParameters parameters)
        {
            var userView = await GetModelFromParameters(parameters);
            if (!(userView.User is EmptyUser))
            {
                return JsonGetFailure(string.Format("User '{0}' already exists", parameters.CDSId));
            }

            userView.User = await DataContext.User.AddUser(Model.User.FromParameters(parameters));
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' could not be created", parameters.CDSId));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> EnableUser(UserParameters parameters)
        {
            var userView = await GetModelFromParameters(parameters);
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' does not exist", parameters.CDSId));
            }

            userView.User = await DataContext.User.EnableUser(Model.User.FromParameters(parameters));
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' could not be enabled", parameters.CDSId));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> DisableUser(UserParameters parameters)
        {
            var userView = await GetModelFromParameters(parameters);
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' does not exist", parameters.CDSId));
            }

            userView.User = await DataContext.User.DisableUser(Model.User.FromParameters(parameters));
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' could not be disabled", parameters.CDSId));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> SetAsAdministrator(UserParameters parameters)
        {
            var userView = await GetModelFromParameters(parameters);
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' does not exist", parameters.CDSId));
            }

            userView.User = await DataContext.User.SetAdministrator(Model.User.FromParameters(parameters));
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' could not be set as an administrator", parameters.CDSId));
            }

            return JsonGetSuccess();
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> UnsetAsAdministrator(UserParameters parameters)
        {
            var userView = await GetModelFromParameters(parameters);
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' does not exist", parameters.CDSId));
            }

            userView.User = await DataContext.User.UnsetAdministrator(Model.User.FromParameters(parameters));
            if (userView.User is EmptyUser)
            {
                return JsonGetFailure(string.Format("User '{0}' could not be unset as an administrator", parameters.CDSId));
            }

            return JsonGetSuccess();
        }
        private string GetContentPartialViewName(UserAction forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private async Task<UserViewModel> GetModelFromParameters(UserParameters parameters)
        {
            return await UserViewModel.GetModel(
                DataContext,
                UserFilter.FromCDSId(parameters.CDSId),
                parameters.Action);
        }
        private void ValidateUserParameters(UserParameters parameters, string ruleSetName)
        {
            var validator = new UserParametersValidator();
            var result = validator.Validate(parameters, ruleSet: ruleSetName);
            if (!result.IsValid)
            {
                throw new ValidationException(result.Errors);
            }
        }
    }

    internal class UserParametersValidator : AbstractValidator<UserParameters>
    {
        public const string UserIdentifier = "CDSID";
        public const string NoValidation = "NO_VALIDATION";
        public const string Action = "ACTION";
        public const string UserIdentifierWithAction = "CDSID_WITH_ACTION";

        public UserParametersValidator()
        {
            RuleSet(NoValidation, () =>
            {

            });
            RuleSet(UserIdentifier, () =>
            {
                RuleFor(p => p.CDSId).NotEmpty().WithMessage("'CDSId' not specified");
            });
            RuleSet(Action, () =>
            {
                RuleFor(p => p.Action).NotEqual(a => UserAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(UserIdentifierWithAction, () =>
            {
                RuleFor(p => p.CDSId).NotEmpty().WithMessage("'CDSId' not specified");
                RuleFor(p => p.Action).NotEqual(a => UserAction.NotSet).WithMessage("'Action' not specified");
            });
            RuleSet(Enum.GetName(typeof(UserAction), UserAction.AddUser), () =>
            {
                RuleFor(p => p.CDSId).NotEmpty().WithMessage("'CDSId' not specified");
                RuleFor(p => p.FullName).NotEmpty().WithMessage("'Full Name' not specified");
                RuleFor(p => p.IsAdmin).NotNull().WithMessage("'Administrator' not specified");
            });
        }
    }
}