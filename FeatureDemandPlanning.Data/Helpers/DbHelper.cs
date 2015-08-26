using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.Helpers
{
    public static class DbHelper
    {
        public static string GetConnectionString()
        {
            return new DbHelperNonSingleton().GetConnectionString();
        }

        public static IDbConnection GetDBConnection()
        {
            return new DbHelperNonSingleton().GetDBConnection();
        }


        public static IEnumerable<ReferenceList> RefLists(string listName = null)
        {
            return new DbHelperNonSingleton().RefLists(listName);
        }
    }

    public class DbHelperNonSingleton : IDbHelper
    {
        public string GetConnectionString()
        {
            // need to get this from the web.config           
            string retVal = ConfigurationManager.ConnectionStrings["RADS"].ConnectionString;
            return retVal;
        }

        public IDbConnection GetDBConnection()
        {
            SqlConnection conn = new SqlConnection(GetConnectionString());
            conn.Open();

            return conn;
        }


        public IEnumerable<ReferenceList> RefLists(string listName = null)
        {
            ReferenceListDataStore ds = new ReferenceListDataStore("system");
            return ds.ReferenceListGetMany(listName);
        }
    }
}