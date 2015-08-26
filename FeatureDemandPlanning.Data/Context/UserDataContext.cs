using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.DataStore
{
    public class UserDataContext : BaseDataContext, IUserDataContext
    {
        private OXOPermissionDataStore _permissions = null;
        private SystemUserDataStore _userDataStore = null;
        private ReferenceListDataStore _referenceListDataStore = null;
        
        public UserDataContext(string cdsId) : base(cdsId)
        {
            _permissions = new OXOPermissionDataStore(cdsId);
            _userDataStore = new SystemUserDataStore(cdsId);
            _referenceListDataStore = new ReferenceListDataStore(cdsId);
        }

        public SystemUser GetUser()
        {
            return _userDataStore.SystemUserGet(CDSID);
        }

        public IEnumerable<BusinessObjects.Permission> ListPermissions()
        {
            return _permissions.PermissionGetMany(CDSID, null);
        }

        public IEnumerable<NameValuePair> ListPreferences()
        {
            yield return null;
        }

        public IEnumerable<BusinessObjects.Programme> ListAllowedProgrammes()
        {
            return _userDataStore.SystemUserProgrammes(CDSID, true);
        }

        public IEnumerable<BusinessObjects.Programme> ListAvailableProgrammes()
        {
            return _userDataStore.SystemUserProgrammes(CDSID, false);
        }

        public IEnumerable<string> ListAvailableAdminSections()
        {
            return _referenceListDataStore.ReferenceListGetMany("Adm-Section").Select(r => r.Description);
        }

        public IEnumerable<string> ListAvailableReports()
        {
            return _referenceListDataStore.ReferenceListGetMany("Rpt-Section").Select(r => r.Description);
        }
    }
}
