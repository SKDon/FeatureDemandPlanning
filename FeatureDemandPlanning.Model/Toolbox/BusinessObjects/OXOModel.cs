
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FeatureDemandPlanning.Dapper;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.BusinessObjects
{
    [Serializable]
    public class Model : BusinessObject
    {
        private string _formattedName;
        private string _formattedNameWithBR; 

        public string VehicleName { get; set; }
        public string VehicleAKA { get; set; }
        public string ModelYear { get; set; }
        public int ProgrammeId { get; set; }
        public int BodyId { get; set; }
        public int EngineId { get; set; }
        public int TransmissionId { get; set; }
        public int TrimId { get; set; }
        public string BMC { get; set; }
        public string CoA { get; set; }
        public bool KD { get; set; }
        public int ChangesetId { get; set; }
        public int MarketsCount { get; set; }
        private string DisplayFormat { get; set; }     
        public string Name 
        { 
            set
            {
                _formattedName = value;
            }

            get
            {
                if (String.IsNullOrEmpty(_formattedName))
                {
                    _formattedName = FormatName(false);
                }

                return _formattedName;
            }
        }
        public string NameWithBR
        {
            set
            {
                _formattedNameWithBR = value;
            }

            get
            {
                if (String.IsNullOrEmpty(_formattedNameWithBR))
                {
                    _formattedNameWithBR = FormatName(true);
                }

                return _formattedNameWithBR;
            }
        }
        public bool Available { get; set; }
        public string BodyShape { get; set; }
        public string Doors { get; set; }
        public string Wheelbase { get; set; }
        public string EngineSize { get; set; }
        public string FuelType { get; set; }
        public string Cylinder { get; set; }
        public string Turbo { get; set; }
        public string Power { get; set; }
        public string DriveTrain { get; set; }
        public string TransType { get; set; }
        public string TrimName { get; set; }
        public string TrimLevel { get; set; }
        public string DPCK { get; set; }
        public string GSFId { get; set; }
        public string GSFBody { get; set; }
        public string GSFEngine { get; set; }
        public string GSFNameWithBr { get; set; }

        // A blank constructor
        public Model() {;}

        private string FormatName(bool withBR = false)
        {
            string retval = "";
            if (!String.IsNullOrEmpty(DisplayFormat))
            {
            retval = DisplayFormat;
            if (Body != null)
            {
                retval.Replace("[sh]", "" + Body.Shape + " ");
                retval.Replace("[dr]", "" + Body.Doors + " ");
                retval.Replace("[wb]", "" + Body.Wheelbase + " ");
            }
            if (Engine != null)
            {
                string engineSize = "" + Engine.Size + (Engine.FuelType == "Diesel" ? "D" : "");
                retval.Replace("[sz]", "" + engineSize + " ");
                retval.Replace("[cy]", "" + Engine.Cylinder + " ");
                retval.Replace("[tb]", "" + Engine.Turbo + " ");
                retval.Replace("[pw]", "" + Engine.Power + " ");
            }
            if (Transmission != null)
            {
                string driveTrain = (Transmission.Drivetrain == "SWB" ? "" : "" + Transmission.Drivetrain + " ");
                retval.Replace("[dv]", "" + driveTrain);
                retval.Replace("[gr]", "" + Transmission.Name + " ");
            }
            if (Trim != null)
            {
                retval.Replace("[tr]", "" + Trim.Name + " ");
            }

            retval.Trim();

            if (!withBR)
                retval.Replace("#", "");
            }

            return retval;
        }
       
        [ScriptIgnore]
        public ModelEngine Engine { get; set; }
        [ScriptIgnore]
        public ModelBody Body { get; set; }
        [ScriptIgnore]
        public ModelTransmission Transmission { get; set; }
        [ScriptIgnore]
        public ModelTrim Trim { get; set; }
      
    }
}