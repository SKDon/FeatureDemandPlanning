using System.Data;

namespace FeatureDemandPlanning.Model.Dapper
{
    public partial class DynamicParameters
    {
        public static DynamicParameters FromCDSId(string cdsId, string parameterName = "CDSId")
        {
            var parameters = new DynamicParameters();
            parameters.Add("@" + parameterName, cdsId, dbType: DbType.String);

            return parameters;
        }
    }
}
