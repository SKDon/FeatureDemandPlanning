using System;
using System.Web.Caching;
using System.Web.Mvc;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Results;
using FluentValidation;

namespace FeatureDemandPlanning.Controllers
{
    public class ControllerBase : Controller
    {
        public ConfigurationSettings ConfigurationSettings
        {
            get
            {
                var settings = (ConfigurationSettings)System.Web.HttpContext.Current.Cache.Get("ConfigurationSettings");
                if (settings != null) return settings; 

                settings = DataContext.ConfigurationSettings;
                System.Web.HttpContext.Current.Cache.Insert("ConfigurationSettings", settings, null, DateTime.Now.AddMinutes(30),
                    Cache.NoSlidingExpiration);

                return settings;
            }
        }

        public ControllerType ControllerType { get { return _controllerType; } set { _controllerType = value; } }
        public IDataContext DataContext { get; private set; }

        public string UserName 
        { 
            get 
            {
                return GetCdsId();
            } 
        }
        
        public int PageIndex { get; set; }
        public int PageSize { get; set; }

        public ControllerBase(IDataContext context)
        {
            DataContext = context;
            
            PageIndex = 0;
            PageSize = ConfigurationSettings.GetInteger("DefaultPageSize");
        }
        public ControllerBase(IDataContext context, ControllerType controllerType) : this(context)
        {
            ControllerType = controllerType;
        }
        public JsonResult JsonGet(object data)
        {
            return Json(data, JsonRequestBehavior.AllowGet);
        }
        public JsonResult JsonGetSuccess()
        {
            return JsonGet(JsonActionResult.GetSuccess());
        }
        public JsonResult JsonGetSuccess(string message)
        {
            return JsonGet(JsonActionResult.GetSuccess(message));
        }
        public JsonResult JsonGetSuccess(object data)
        {
            return JsonGet(JsonActionResult.GetSuccess(data));
        }
        public JsonResult JsonGetSuccess(object data, string message)
        {
            return JsonGet(JsonActionResult.GetSuccess(data, message));
        }
        public JsonResult JsonGetFailure(string message)
        {
            return JsonGet(JsonActionResult.GetFailure(message));
        }
        protected string GetContentPartialViewName(object forAction)
        {
            return string.Format("_{0}", Enum.GetName(forAction.GetType(), forAction));
        }
        private string GetCdsId()
        {
            return SecurityHelper.GetAuthenticatedUser();
        }

        private ControllerType _controllerType = ControllerType.Default;
        protected static readonly Logger Log = Logger.Instance;
    }
}
