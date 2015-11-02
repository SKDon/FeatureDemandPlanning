using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.DataStore.DataStore;

namespace FeatureDemandPlanning.DataStore
{
    public class DerivativeDataStore : DataStoreBase
    {
        #region "Constructors"
        
        public DerivativeDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        #endregion

        public IEnumerable<Derivative> DerivativeGetMany(int programmeId)
        {
            IEnumerable<Derivative> retVal = Enumerable.Empty<Derivative>();

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@ProgrammeId", programmeId, dbType: DbType.Int32);
                    para.Add("@IncludeAllDerivatives", true, dbType: DbType.Boolean);

                    retVal = conn.Query<Derivative>("Fdp_DerivativeMapping_GetMany", para, commandType: CommandType.StoredProcedure);
                    if (retVal.Any())
                    {
                        retVal = retVal.Where(d => d.IsMappedDerivative == false);
                    }
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("FdpVolumeDataStore.DerivativeGetMany", ex.Message, CurrentCDSID);
                    throw;
                }
            }
            return retVal;
        }
    }
}
