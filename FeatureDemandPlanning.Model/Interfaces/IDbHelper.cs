using System.Collections.Generic;
using System.Data;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IDbHelper
    {
        string GetConnectionString();
        IDbConnection GetDBConnection();
        IEnumerable<ReferenceList> RefLists(string listName = null);
    }
}
