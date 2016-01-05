using System.Web.Mvc;
using System.Web.Mvc.Html;

namespace FeatureDemandPlanning.Model.Helpers
{
    public static class HtmlHelpers
    {
        public static string MenuLink(this HtmlHelper htmlHelper, string linkText, string actionName, string controllerName, bool isRegistered)
        {
            //If I am already on the right page, just out put a text
            string currentAction = htmlHelper.ViewContext.RouteData.GetRequiredString("action");
            string currentController = htmlHelper.ViewContext.RouteData.GetRequiredString("controller");
            if (controllerName == currentController)
            {
                return linkText;
            }

            if (isRegistered || controllerName == "Home" || controllerName == "Admin")
            {
                return htmlHelper.ActionLink(linkText, actionName, controllerName).ToHtmlString();
            }
            else
            {
                return htmlHelper.ActionLink(linkText, null, null, new { onclick = "launch_registration_popup();", href = "#" }).ToHtmlString();
            }
       
        }

        public static string ImageButtonHref(this HtmlHelper htmlHelper, string actionName, string controllerName, bool isRegistered)
        {
            var urlHelper = new UrlHelper(htmlHelper.ViewContext.RequestContext);
            var url = urlHelper.Action(actionName, controllerName);
            return (isRegistered ? url : "#");
        }

        public static string ImageButtonOnClick(this HtmlHelper htmlHelper, bool isRegistered)
        {
            return (isRegistered ? "" : "launch_registration_popup();");
        }
    }
}