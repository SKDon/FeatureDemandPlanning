using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IConfigurationDataContext
    {
        dynamic Configuration { get; }
    }
}
