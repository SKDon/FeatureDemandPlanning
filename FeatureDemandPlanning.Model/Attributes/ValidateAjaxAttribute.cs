using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning
{
    public sealed class ValidateAjaxAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (!filterContext.HttpContext.Request.IsAjaxRequest())
                return;

            var modelState = filterContext.Controller.ViewData.ModelState;
            if (!modelState.IsValid)
            {
                var errorModel =
                        from x in modelState.Keys
                        where modelState[x].Errors.Count > 0
                        select new
                        {
                            key = x,
                            errors = modelState[x].Errors
                                                   .Select(y => new
                                                   {
                                                       ErrorMessage = ParseErrorMessage(y.ErrorMessage),
                                                       ProcessStatus = ParseStatusCode(y.ErrorMessage)
                                                   }
                                                   )
                                                   .ToArray()
                        };
                filterContext.Result = new JsonResult()
                 {
                     Data = errorModel
                 };
                filterContext.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
        }

        private static string ParseErrorMessage(string errorMessage)
        {
            var parts = errorMessage.Split(new string[] { "::" }, StringSplitOptions.None);
            return parts.Last();
        }

        private static FeatureDemandPlanning.Model.Enumerations.ProcessStatus ParseStatusCode(string errorMessage)
        {
            var status = FeatureDemandPlanning.Model.Enumerations.ProcessStatus.NotSet;
            var parts = errorMessage.Split(new string[] { "::" }, StringSplitOptions.None);
            if (parts.Length > 1)
            {
                var success = Enum.TryParse<FeatureDemandPlanning.Model.Enumerations.ProcessStatus>(parts[0], true, out status);
            }
            return status;
        }
    }
}