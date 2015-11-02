using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
                    AppHelper.LogError("NewsDataStore.FdpNewsGetMany", ex.Message, CurrentCDSID);
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
