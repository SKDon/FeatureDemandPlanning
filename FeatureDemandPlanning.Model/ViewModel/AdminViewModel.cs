using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class AdminViewModel : SharedModelBase
    {
        public AdminViewModel() : base()
        {

        }

        public static AdminViewModel GetModel(IDataContext context)
        {
            return new AdminViewModel
            {
                Configuration = context.ConfigurationSettings
            };
        }
    }
}