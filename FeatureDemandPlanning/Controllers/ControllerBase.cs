using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Helpers;
using System.Configuration;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Results;

namespace FeatureDemandPlanning.Controllers
{
    public class ControllerBase : Controller
    {
        public dynamic ConfigurationSettings { get { return _dataContext.ConfigurationSettings; } }
        public ControllerType ControllerType { get { return _controllerType; } set { _controllerType = value; } }
        public IDataContext DataContext { get { return _dataContext; } }
        
        public string UserName 
        { 
            get 
            {
                return GetCdsId();
            } 
        }
        
        public int PageIndex { get; set; }
        public int PageSize { get; set; }

        public ControllerBase()
        {
            _dataContext = DataContextFactory.CreateDataContext(GetCdsId());
            
            PageIndex = 0;
            PageSize = ConfigurationSettings.DefaultPageSize;
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
        private string GetCdsId()
        {
            var context = System.Web.HttpContext.Current;

            if (context != null && context.User != null && context.User.Identity != null)
            {
                return AppHelper.GetWindowsID(context.User);
            }
            return Request.ServerVariables["REMOTE_USER"];
        }

        private IDataContext _dataContext;
        private ControllerType _controllerType = ControllerType.Default;
    }
}
