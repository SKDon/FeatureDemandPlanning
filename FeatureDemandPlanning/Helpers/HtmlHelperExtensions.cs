using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Web.Mvc;
using System.Web.Mvc.Html;

namespace FeatureDemandPlanning.Helpers
{
    public static class HtmlHelperExtensions
    {
        public static MvcHtmlString DropDownListForExtended<TModel, TProperty>(this HtmlHelper<TModel> htmlHelper, 
                                                                                Expression<Func<TModel, TProperty>> expression, 
                                                                                IEnumerable<SelectListItem> selectList, 
                                                                                object htmlAttributes,
                                                                                Expression<Func<TModel, bool>> enabledExpression)
        {
            Func<TModel, bool> enabledMethod = enabledExpression.Compile();
            var enabled = enabledMethod(htmlHelper.ViewData.Model);
            
            var attrs = HtmlHelper.AnonymousObjectToHtmlAttributes(htmlAttributes);
            if (!enabled)
            {
                attrs.Add("disabled", "disabled");
            }
            return htmlHelper.DropDownListFor(expression, selectList, attrs);
        }
    }
}