using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class Vehicle : BusinessObject, IVehicle, IEquatable<Vehicle>, IEqualityComparer<Vehicle>
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
        
        public string FullDescription
        {
            get
            {
                if (!string.IsNullOrEmpty(Gateway))
                {
                    return string.Format("{0} ({1}, {2})", Description, ModelYear, Gateway);
                }
                else
                {
                    return string.Format("{0} ({1})", Description, ModelYear);
                }
            }
        }
        public string Description { get; set; }
        
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

        public IList<TrimMapping> TrimMappings
        {
            get
            {
                return _trimMappings;
            }
            set
            {
                _trimMappings = value;
            }
        }

        public IEnumerable<OXODoc> AvailableDocuments
        {
            get
            {
                return _availableDocuments;
            }
            set
            {
                _availableDocuments = value;
            }
        }

        public IEnumerable<FdpVolumeHeader> AvailableImports
        {
            get
            {
                return _availableImports;
            }
            set
            {
                _availableImports = value;
            }
        }

        public IEnumerable<BusinessObjects.Model> AvailableModels
        {
            get
            {
                return _availableModels;
            }
            set
            {
                _availableModels = value;
            }
        }

        public IEnumerable<MarketGroup> AvailableMarketGroups
        {
            get
            {
                return _availableMarketGroups;
            }
            set
            {
                _availableMarketGroups = value;
            }
        }

        //public IEnumerable<Market> AvailableMarkets
        //{
        //    get
        //    {
        //        return _availableMarkets;
        //    }
        //    set
        //    {
        //        _availableMarkets = value;
        //    }
        //}

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

        public bool Equals(Vehicle other)
        {
            if (other == null)
                return false;

            return IsMakeEquivalent(other) &&
                IsCodeEquivalent(other) &&
                IsModelYearEquivalent(other);
        }

        public bool Equals(Vehicle x, Vehicle y)
        {
            return x == y;
        }

        public override int GetHashCode()
        {
            unchecked
            {
                int hash = 17;

                hash = hash * 23 + (string.IsNullOrEmpty(Make) ? string.Empty : Make).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(Code) ? string.Empty : Code).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(ModelYear) ? string.Empty : ModelYear).GetHashCode();
                hash = hash * 23 + (string.IsNullOrEmpty(Gateway) ? string.Empty : Gateway).GetHashCode();
               
                return hash;
            }
        }

        public int GetHashCode(Vehicle obj)
        {
            return obj.GetHashCode();
        }

        public static Vehicle FromVehicle(IVehicle vehicle)
        {
            return new Vehicle() {

                VehicleId = vehicle.VehicleId,
                ProgrammeId = vehicle.ProgrammeId,
                GatewayId = vehicle.GatewayId,
                Make = vehicle.Make,
                Code = vehicle.Code,
                ModelYear = vehicle.ModelYear,
                Gateway = vehicle.Gateway,
                ImageUri = vehicle.ImageUri,
                Description = vehicle.Description,
                //FullDescription = vehicle.FullDescription,
                Programmes = vehicle.Programmes,
                AvailableDocuments = vehicle.AvailableDocuments,
                AvailableImports = vehicle.AvailableImports,
                AvailableModels = vehicle.AvailableModels
            };
        }

        private bool IsMakeEquivalent(Vehicle other)
        {
            var thisMake = string.IsNullOrEmpty(Make) ? string.Empty : Make;
            var otherMake = string.IsNullOrEmpty(other.Make) ? string.Empty : other.Make;

            return thisMake.Equals(otherMake, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsCodeEquivalent(Vehicle other)
        {
            var thisCode = string.IsNullOrEmpty(Code) ? string.Empty : Code;
            var otherCode = string.IsNullOrEmpty(other.Code) ? string.Empty : other.Code;
            
            return thisCode.Equals(otherCode, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsModelYearEquivalent(Vehicle other)
        {
            var thisModelYear = string.IsNullOrEmpty(ModelYear) ? string.Empty : ModelYear;
            var otherModelYear = string.IsNullOrEmpty(other.ModelYear) ? string.Empty : other.ModelYear;

            return thisModelYear.Equals(otherModelYear, StringComparison.InvariantCultureIgnoreCase);
        }

        private bool IsGatewayEquivalent(Vehicle other)
        {
            var thisGateway = string.IsNullOrEmpty(Gateway) ? string.Empty : Gateway;
            var otherGateway = string.IsNullOrEmpty(other.Gateway) ? string.Empty : other.Gateway;

            return thisGateway.Equals(otherGateway, StringComparison.InvariantCultureIgnoreCase);
        }

        private IEnumerable<Programme> _programmes = new List<Programme>();
        private IList<TrimMapping> _trimMappings = new List<TrimMapping>();
        private IEnumerable<OXODoc> _availableDocuments = new List<OXODoc>();
        private IEnumerable<FdpVolumeHeader> _availableImports = new List<FdpVolumeHeader>();
        private IEnumerable<BusinessObjects.Model> _availableModels = new List<BusinessObjects.Model>();
        private IEnumerable<MarketGroup> _availableMarketGroups = new List<MarketGroup>();
        //private IEnumerable<Market> _availableMarkets = new List<Market>();
    }
}
