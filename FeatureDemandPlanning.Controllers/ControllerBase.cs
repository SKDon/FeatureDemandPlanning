using System;
using System.Web.Mvc;
using FeatureDemandPlanning.Helpers;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Results;

namespace FeatureDemandPlanning.Controllers
{
    public class ControllerBase : Controller
    {
        public ConfigurationSettings ConfigurationSettings { get { return DataContext.ConfigurationSettings; } }
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
