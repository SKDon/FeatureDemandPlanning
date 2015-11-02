using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Vehicle: BusinessObject
    {
        public string Name { get; set; }
        public string AKA { get; set; }
        public string Make { get; set; }     
        public string Active { get; set; }
        public List<Programme> Programmes { get; set; }       

        // A blank constructor
        public Vehicle() { ;}

    }
}