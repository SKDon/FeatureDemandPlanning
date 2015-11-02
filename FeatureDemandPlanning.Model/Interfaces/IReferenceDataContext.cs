using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IReferenceDataContext
    {
        IEnumerable<ReferenceList> ListReferencesByKey(string key);
    }
}
