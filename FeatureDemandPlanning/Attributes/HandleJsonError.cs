using FeatureDemandPlanning.Results;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Attributes
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
        private bool CanIgnoreException(ExceptionContext filterContext)
        {
            return filterContext.ExceptionHandled ||!filterContext.HttpContext.IsCustomErrorEnabled; ;
        }
        private bool IsJsonResponseRequired(HttpRequest request)
        {
            return true;
        }
    }
}