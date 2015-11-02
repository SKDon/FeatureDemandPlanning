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
        public AdminViewModel(IDataContext dataContext) : base(dataContext)
        {

        }
    }
}