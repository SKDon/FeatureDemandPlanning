using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class AdminViewModel : SharedModelBase
    {
        public AdminViewModel(IDataContext dataContext) : base(dataContext)
        {

        }
    }
}