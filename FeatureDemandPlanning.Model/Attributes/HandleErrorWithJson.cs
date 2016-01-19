using FeatureDemandPlanning.Model.Results;
using FluentValidation;
using System.Net;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Model.Attributes
{
    public class HandleErrorWithJson : HandleErrorAttribute
    {
        public override void OnException(ExceptionContext filterContext)
        {
            var statusCode = HttpStatusCode.InternalServerError;

            if (CanIgnoreException(filterContext))
            {
                return;
            }
            if (!filterContext.HttpContext.Request.IsAjaxRequest())
            {
                base.OnException(filterContext);
                return;
            }

            if (filterContext.Exception is ValidationException)
            {
                statusCode = HttpStatusCode.BadRequest;
            }
          
            filterContext.Result = new JsonResult()
            {
                Data = JsonActionResult.GetFailure(filterContext.Exception),
                JsonRequestBehavior = JsonRequestBehavior.AllowGet
            };
            filterContext.ExceptionHandled = true;
            filterContext.HttpContext.Response.Clear();
            filterContext.HttpContext.Response.StatusCode = (int)statusCode;
        }
        private static bool CanIgnoreException(ExceptionContext filterContext)
        {
            return filterContext.ExceptionHandled ||!filterContext.HttpContext.IsCustomErrorEnabled;
        }
    }
}