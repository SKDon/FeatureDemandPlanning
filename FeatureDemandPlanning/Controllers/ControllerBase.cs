﻿using System;
using System.Reflection;
using System.Web.Mvc;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Results;
using log4net;

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

        public ControllerBase()
        {
            DataContext = DependencyResolver.Current.GetService<IDataContext>();
            
            PageIndex = 0;
            PageSize = ConfigurationSettings.GetInteger("DefaultPageSize");
        }
        public ControllerBase(ControllerType controllerType) : this()
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
            return Helpers.SecurityHelper.GetAuthenticatedUser();
        }

        private ControllerType _controllerType = ControllerType.Default;
        protected static readonly Logger Log = Logger.Instance;
    }
}
