

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Model.Dapper;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;

namespace FeatureDemandPlanning.DataStore
{
    public class VehicleDataStore : DataStoreBase
    {

        public VehicleDataStore(string cdsid)
        {
            this.CurrentCDSID = cdsid;
        }

        public IEnumerable<Vehicle> VehicleGetMany(string make, bool deepGet = false)             
        {
            IEnumerable<Vehicle> retVal = null;
            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    List<Vehicle> vehicles;

                    var para = new DynamicParameters();
                    para.Add("@p_make", make, dbType: DbType.String, size: 500);
                    using (var multi = conn.QueryMultiple("dbo.OXO_Vehicle_GetMany", para, commandType: CommandType.StoredProcedure))
                    {
                        vehicles = multi.Read<Vehicle>().ToList();
                        if (deepGet)
                        {
                            var programmes = multi.Read<Programme>().ToList();
                            foreach (var vehicle in vehicles)
                            {
                                vehicle.Programmes = programmes.Where(c => c.ParentId == vehicle.Id).ToList();
                            }
                        }
                    }

                    retVal = vehicles;
                }
                catch (Exception ex)
                {
                    AppHelper.LogError("VehicleDataStore.VehicleGetMany", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }

        public Vehicle VehicleGet(int id, bool deepGet = false)
        {
            Vehicle retVal = null;

            using (IDbConnection conn = DbHelper.GetDBConnection())
            {
                try
                {
                    var para = new DynamicParameters();
                    para.Add("@p_Id", id, dbType: DbType.Int32);
                   // para.Add("@p_deep_get", deepGet, dbType: DbType.Boolean);
                    using (var multi = conn.QueryMultiple("dbo.OXO_Vehicle_Get", para, commandType: CommandType.StoredProcedure))
                    {
                        retVal = multi.Read<Vehicle>().FirstOrDefault(); ;
                        var programmes = multi.Read<Programme>().ToList();
                        if (retVal != null)
                            retVal.Programmes = programmes.ToList();
                    }


                }
                catch (Exception ex)
                {
                    AppHelper.LogError("VehicleDataStore.VehicleGet", ex.Message, CurrentCDSID);
                }
            }

            return retVal;
        }
    }
}