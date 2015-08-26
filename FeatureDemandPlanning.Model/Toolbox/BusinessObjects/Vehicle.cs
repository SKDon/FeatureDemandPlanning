using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Vehicle : BusinessObject, IVehicle, IEqualityComparer<IVehicle>
    {
        public int? VehicleId { get; set; }
        public int? ProgrammeId { get; set; }
        public int? GatewayId { get; set; }
        public string Make { get; set; }
        public string Code { get; set; }
        public string ModelYear { get; set; }
        public string DerivativeCode { get; set; }
        public string Gateway { get; set; }
        public string ImageUri { get; set; }
        public string Description { get; set; }
        public string FullDescription { get; set; }
        
        public IEnumerable<Programme> Programmes 
        {
            get
            {
                return _programmes;
            } 
            set
            {
                _programmes = value;
            }
        }

        public Programme GetProgramme()
        {
            if (Programmes == null || !Programmes.Any())
                return null;

            return Programmes.First();
        }

        public IEnumerable<ModelTrim> ListTrimLevels()
        {
            var programme = GetProgramme();
            if (programme == null)
                return Enumerable.Empty<ModelTrim>();

            return programme.AllTrims;
        }

        public override string ToString()
        {
            var sb = new StringBuilder();
            if (!string.IsNullOrEmpty(Code))
            {
                sb.Append(Code);
                sb.Append(" - ");
            }

            if (!string.IsNullOrEmpty(Description))
            {
                sb.Append(Description);
            }

            return sb.ToString().Trim();
        }

        public bool Equals(IVehicle x, IVehicle y)
        {
            if (x == null || y == null)
                return false;

            return IsMakeEquivalent(x, y) &&
                IsCodeEquivalent(x, y) &&
                IsModelYearEquivalent(x, y) &&
                IsGatewayEquivalent(x, y);
        }

        public int GetHashCode(IVehicle obj)
        {
            return new { obj.Make, obj.Code, obj.ModelYear, obj.Gateway }.GetHashCode();
        }

        private bool IsMakeEquivalent(IVehicle x, IVehicle y)
        {
            return string.IsNullOrEmpty(x.Make) ||
                string.IsNullOrEmpty(y.Make) ||
                x.Make.Equals(y.Make, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsCodeEquivalent(IVehicle x, IVehicle y)
        {
            return string.IsNullOrEmpty(x.Code) ||
                string.IsNullOrEmpty(y.Make) ||
                x.Code.Equals(y.Code, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsModelYearEquivalent(IVehicle x, IVehicle y)
        {
            return string.IsNullOrEmpty(x.ModelYear) ||
                string.IsNullOrEmpty(y.ModelYear) ||
                x.ModelYear.Equals(y.ModelYear, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsGatewayEquivalent(IVehicle x, IVehicle y)
        {
            return string.IsNullOrEmpty(x.Gateway) ||
                string.IsNullOrEmpty(y.Gateway) ||
                x.Gateway.Equals(y.Gateway, StringComparison.InvariantCultureIgnoreCase);
        }

        private IEnumerable<Programme> _programmes = new List<Programme>();
    }
}
