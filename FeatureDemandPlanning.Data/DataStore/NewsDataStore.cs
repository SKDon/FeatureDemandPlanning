using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace FeatureDemandPlanning.DataStore
{
    public class NewsDataStore : DataStoreBase
    {
         #region "Constructors"
        
        public NewsDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        #endregion

        public IEnumerable<News> NewsGetMany()
        {
            var results = Enumerable.Empty<News>();

            using (IDbConnection connection = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    results = connection.Query<News>("dbo.Fdp_News_GetMany", para, commandType: CommandType.StoredProcedure);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    throw;
                }
            }
            return results;
        }

        public void NewsSave(News newsToSave)
        {

        }
    }
   
}
