
/*===============================================================================
 *
 *      Code Comment Block Here.
 *      
 *      Generated by Code Generator on 02/06/2014 13:04  
 * 
 *===============================================================================
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Programme : BusinessObject
    {
        public int VehicleId { get; set; }
        public string VehicleName { get; set; }
        public string VehicleAKA { get; set; }
        public string VehicleMake { get; set; }
        public string VehicleDisplayFormat { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public DateTime PS { get; set; }
        public DateTime J1 { get; set; }
        public string Notes { get; set; }
        public string ProductManager { get; set; }
        public string RSGUID { get; set; }
        public bool OXOEnabled { get; set; }
        public IEnumerable<ModelEngine> AllEngines { get; set; }
        public IEnumerable<ModelBody> AllBodies { get; set; }
        public IEnumerable<ModelTransmission> AllTransmissions { get; set; }
        public IEnumerable<ModelTrim> AllTrims { get; set; }
        public string PSText
        {
            get { return PS.ToShortDateString(); }
        }
        public string J1Text
        {
            get { return J1.ToShortDateString(); }
        }
        public bool CanEdit { get; set; }
        public bool UseOACode { get; set; }

        // A blank constructor
        public Programme() {
            AllEngines = Enumerable.Empty<ModelEngine>();
            AllBodies = Enumerable.Empty<ModelBody>();
            AllTrims = Enumerable.Empty<ModelTrim>();
            AllTransmissions = Enumerable.Empty<ModelTransmission>();
        }

        public int TotalRecords { get; set; }
        public int TotalPages { get; set; }
    }
}