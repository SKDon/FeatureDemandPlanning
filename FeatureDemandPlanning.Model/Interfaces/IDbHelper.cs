using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IDbHelper
    {
        string GetConnectionString();
        IDbConnection GetDBConnection();
        IEnumerable<ReferenceList> RefLists(string listName = null);
    }
}
