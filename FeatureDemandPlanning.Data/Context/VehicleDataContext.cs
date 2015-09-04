using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.DataStore
{
    public class VehicleDataContext : BaseDataContext, IVehicleDataContext
    {
        public VehicleDataContext(string cdsId) : base(cdsId)
        {
            _vehicleDataStore = new VehicleDataStore(cdsId);
            _programmeDataStore = new ProgrammeDataStore(cdsId);
        }

        public IVehicle GetVehicle(VehicleFilter filter)
        {
            if (!filter.ProgrammeId.HasValue)
                return new EmptyVehicle();
            
            var programme = _programmeDataStore.ProgrammeGetConfiguration(filter.ProgrammeId.Value);
            if (programme == null)
                return new EmptyVehicle();

            var vehicle = HydrateVehicleFromProgramme(programme);
            vehicle.Gateway = filter.Gateway;
            vehicle.ModelYear = filter.ModelYear;

            return vehicle;
        }

        public IEnumerable<string> ListAvailableMakes()
        {
            var programmes = _programmeDataStore.ProgrammeGetMany();
            if (programmes == null || !programmes.Any())
            {
                return Enumerable.Empty<string>();
            }

            return programmes.Select(p => p.VehicleMake).Distinct().OrderBy(p => p);
        }

        public PagedResults<EngineCodeMapping> ListEngineCodeMappings(EngineCodeFilter filter)
        {
            var results = new PagedResults<EngineCodeMapping>();

            var engineCodeMappings = _programmeDataStore.EngineCodeMappingGetMany();
            if (engineCodeMappings == null || !engineCodeMappings.Any())
                return results;

            // Filter the results 
            // TO DO, get this in the database as parameters

            engineCodeMappings = engineCodeMappings
                .Where(e => !filter.ProgrammeId.HasValue || e.Id == filter.ProgrammeId.Value)
                .Where(e => !filter.VehicleId.HasValue || e.VehicleId == filter.VehicleId.Value)
                .Where(e => String.IsNullOrEmpty(filter.Name) || e.VehicleName.Equals(filter.Name, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Make) || e.VehicleMake.Equals(filter.Make, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.ModelYear) || e.ModelYear.Equals(filter.ModelYear, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Gateway) || e.Gateway.Equals(filter.Gateway, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.DerivativeCode) || (string.IsNullOrEmpty(e.ExternalEngineCode) ? string.Empty : e.ExternalEngineCode.ToUpper()).Contains(filter.DerivativeCode.ToUpper()))
                .Where(e => !filter.EngineId.HasValue || e.EngineId == filter.EngineId.Value)
                .Where(e => String.IsNullOrEmpty(filter.EngineSize) || e.EngineSize.Equals(filter.EngineSize, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Cylinder) || e.Cylinder.Equals(filter.Cylinder, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Fuel) || e.Fuel.Equals(filter.Fuel, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Power) || e.Power.Equals(filter.Power, StringComparison.InvariantCultureIgnoreCase))
                .Where(e => String.IsNullOrEmpty(filter.Electrification) || e.Electrification.Equals(filter.Electrification, StringComparison.InvariantCultureIgnoreCase));

            results.TotalRecords = engineCodeMappings.Count();

            if (filter.PageIndex.HasValue && filter.PageSize.HasValue)
            {
                results.CurrentPage = engineCodeMappings.Skip((filter.PageIndex.Value - 1) * filter.PageSize.Value).Take(filter.PageSize.Value);
                results.PageIndex = filter.PageIndex.Value;
                results.PageSize = filter.PageSize.Value;
            }
            else
            {
                results.CurrentPage = engineCodeMappings;
            }

            return results;
        }

        public EngineCodeMapping UpdateEngineCodeMapping(EngineCodeMapping mapping)
        {
            return _programmeDataStore.EngineCodeMappingSave(mapping);
        }

        public IEnumerable<Programme> ListProgrammes(ProgrammeFilter filter)
        {
            var programmes = _programmeDataStore.ProgrammeByGatewayGetMany();
            if (programmes == null || !programmes.Any())
                return Enumerable.Empty<Programme>();

            programmes = programmes
                .Where(p => !filter.ProgrammeId.HasValue || p.Id == filter.ProgrammeId.Value)
                .Where(p => !filter.VehicleId.HasValue || p.VehicleId == filter.VehicleId.Value)
                .Where(p => String.IsNullOrEmpty(filter.Name) || p.VehicleName.Equals(filter.Name, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => String.IsNullOrEmpty(filter.Make) || p.VehicleMake.Equals(filter.Make, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => String.IsNullOrEmpty(filter.ModelYear) || p.ModelYear.Equals(filter.ModelYear, StringComparison.InvariantCultureIgnoreCase))
                .Where(p => String.IsNullOrEmpty(filter.Gateway) || p.Gateway.Equals(filter.Gateway, StringComparison.InvariantCultureIgnoreCase));


            return programmes;
        }

        public IEnumerable<IVehicle> ListAvailableVehicles(VehicleFilter filter)
        {
            var programmes = ListProgrammes(filter);
            if (programmes == null || !programmes.Any())
                return Enumerable.Empty<IVehicle>();

            return programmes.Select(p => HydrateVehicleFromProgramme(p, filter.VehicleIndex));
        }

        private IVehicle HydrateVehicleFromProgramme(BusinessObjects.Programme programme)
        {
            return HydrateVehicleFromProgramme(programme, null);
        }

        private IVehicle HydrateVehicleFromProgramme(BusinessObjects.Programme programme, int? vehicleIndex)
        {
            if (programme == null)
                return new EmptyVehicle();

            return new Vehicle()
            {
                Make = programme.VehicleMake,
                Code = programme.VehicleName,
                ProgrammeId = programme.Id,
                ModelYear = programme.ModelYear,
                Gateway = vehicleIndex.GetValueOrDefault() == 0 ? programme.Gateway : string.Empty,
                Description = String.Format("{0} - {1}", programme.VehicleName, programme.VehicleAKA),
                FullDescription = vehicleIndex.GetValueOrDefault() == 0 ?
                    string.Format("{0} - {1} ({2}, {3})",
                        programme.VehicleName,
                        programme.VehicleAKA,
                        programme.ModelYear,
                        programme.Gateway) :
                    string.Format("{0} - {1} ({2})",
                        programme.VehicleName,
                        programme.VehicleAKA,
                        programme.ModelYear),
                Programmes = new List<Programme>() { programme },
                TrimMapping = ListTrimMappings(programme, vehicleIndex)
            };
        }

        private IDictionary<ModelTrim, IList<ModelTrim>> ListTrimMappings(Programme programme, int? vehicleIndex)
        {
            var trimMapping = new Dictionary<ModelTrim, IList<ModelTrim>>();
            if (programme.AllTrims == null || !programme.AllTrims.Any())
                return trimMapping;

            foreach (var trimLevel in programme.AllTrims) {
                trimMapping.Add(trimLevel, new List<ModelTrim>());
            }

            // TODO populate the actual mappings

            return trimMapping;
        }

        private VehicleDataStore _vehicleDataStore = null;
        private ProgrammeDataStore _programmeDataStore = null;
    }
}
