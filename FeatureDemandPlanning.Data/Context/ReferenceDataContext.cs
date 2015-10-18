using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.DataStore
{
    public class ReferenceDataContext : BaseDataContext, IReferenceDataContext
    {
        public ReferenceDataContext(string cdsId)
            : base(cdsId)
        {
            _referenceDataStore = new ReferenceListDataStore(cdsId);
        }

        public IEnumerable<BusinessObjects.ReferenceList> ListReferencesByKey(string key)
        {
            return _referenceDataStore.ReferenceListGetMany(key);
        }

        private ReferenceListDataStore _referenceDataStore;
    }
}
