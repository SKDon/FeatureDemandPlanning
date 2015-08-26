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

namespace FeatureDemandPlanning.Controllers
{
    /// <summary>
    /// Determines the type of controller that this represents and therefore which layout is rendered
    /// </summary>
    public enum ControllerType
    {
        Default = 0,
        SectionParent = 1,
        SectionChild = 2
    }

    public class ControllerBase : Controller
    {
        public IDataContext DataContext { get { return _dataContext; } }
        public string UserName { get { return _dataContext.User.GetUser().CDSID; } }
        public ControllerType ControllerType { get { return _controllerType; } set { _controllerType = value; } }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }

        public ControllerBase()
        {
            _dataContext = DataContextFactory.CreateDataContext(GetCdsId());
            
            PageIndex = 1;
            PageSize = DataContext.ConfigurationSettings.DefaultPageSize;
        }

        private string GetCdsId()
        {
            var context = System.Web.HttpContext.Current;
            var userId = String.Empty;

            if (context != null && context.User != null && context.User.Identity != null)
            {
                userId = AppHelper.GetWindowsID(context.User);
            }
            else
            {
                userId = Request.ServerVariables["REMOTE_USER"];
            }

            return userId;
        }

        private IDataContext _dataContext;
        private ControllerType _controllerType = ControllerType.Default;
    }
}
