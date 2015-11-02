using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IUserDataContext
    {
        SystemUser GetUser();
        IEnumerable<Permission> ListPermissions();
        IEnumerable<NameValuePair> ListPreferences();
        IEnumerable<Programme> ListAllowedProgrammes();
        IEnumerable<Programme> ListAvailableProgrammes();
        IEnumerable<string> ListAvailableAdminSections();
        IEnumerable<string> ListAvailableReports();
    }
}
