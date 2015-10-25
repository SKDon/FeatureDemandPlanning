using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using FeatureDemandPlanning.Helpers;
using System.Configuration;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.Controllers
{
    public class ControllerBase : Controller
    {
        public dynamic ConfigurationSettings { get { return _dataContext.ConfigurationSettings; } }
        public ControllerType ControllerType { get { return _controllerType; } set { _controllerType = value; } }
        public IDataContext DataContext { get { return _dataContext; } }
        
        public string UserName { get { return _dataContext.User.GetUser().CDSID; } }
        
        public int PageIndex { get; set; }
        public int PageSize { get; set; }

        public ControllerBase()
        {
            _dataContext = DataContextFactory.CreateDataContext(GetCdsId());
            
            PageIndex = 0;
            PageSize = ConfigurationSettings.DefaultPageSize;
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
