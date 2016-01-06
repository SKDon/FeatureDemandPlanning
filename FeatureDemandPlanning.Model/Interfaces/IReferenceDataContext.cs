using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IReferenceDataContext
    {
        IEnumerable<ReferenceList> ListReferencesByKey(string key);
    }
}
