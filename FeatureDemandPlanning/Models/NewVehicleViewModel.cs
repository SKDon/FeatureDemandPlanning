using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Comparers;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Models
{
    public class NewVehicleViewModel : SharedModelBase
    {
        public IEnumerable<SelectListItem> Makes { get; set; }
        public IEnumerable<SelectListItem> Programmes { get; set; }
        public IEnumerable<SelectListItem> ModelYears { get; set; }
        public IEnumerable<SelectListItem> Gateways { get; set; }

        private IEnumerable<SelectListItem> ListMakes()
        {
            return _availableVehicles
                .Select(v => v.Make)
                .Distinct()
                .Select(m => new SelectListItem
                {
                    Text = m,
                    Value = m,
                    Selected = !(_lookupVehicle is EmptyVehicle) &&
                        _lookupVehicle.Make.Equals(m, StringComparison.OrdinalIgnoreCase)
                });
        }

        private IEnumerable<SelectListItem> ListProgrammes()
        {
            return _availableVehicles
                .Where(v => _lookupVehicle is EmptyVehicle ||
                        (
                            v.Make.Equals(_lookupVehicle.Make, StringComparison.OrdinalIgnoreCase))
                        )
                .Distinct(new UniqueVehicleByNameComparer())
                .Select(v => new SelectListItem
                {
                    Text = v.Description,
                    Value = v.ProgrammeId.ToString(),
                    Selected = !(_lookupVehicle is EmptyVehicle) &&
                        _lookupVehicle.ProgrammeId.GetValueOrDefault() == v.ProgrammeId
                });
        }

        private IEnumerable<SelectListItem> ListModelYears()
        {
            return _availableVehicles
                    .Where(v => _lookupVehicle is EmptyVehicle ||
                            (
                                v.Make.Equals(_lookupVehicle.Make, StringComparison.OrdinalIgnoreCase) &&
                                v.ProgrammeId == _lookupVehicle.ProgrammeId)
                            )
                    .Select(v => v.ModelYear)
                    .Distinct()
                    .Select(my => new SelectListItem
                    {
                        Text = my,
                        Value = my,
                        Selected = !(_lookupVehicle is EmptyVehicle) &&
                            _lookupVehicle.ModelYear.Equals(my, StringComparison.OrdinalIgnoreCase)
                    });
        }

        private IEnumerable<SelectListItem> ListGateways()
        {
            return _availableVehicles
                .Where(v => _lookupVehicle is EmptyVehicle ||
                        (
                            v.Make.Equals(_lookupVehicle.Make, StringComparison.OrdinalIgnoreCase) &&
                            v.ProgrammeId == _lookupVehicle.ProgrammeId &&
                            v.ModelYear.Equals(_lookupVehicle.ModelYear, StringComparison.OrdinalIgnoreCase
                        )))
                .Select(v => v.Gateway)
                .Distinct()
                .Select(g => new SelectListItem
                {
                    Text = g,
                    Value = g,
                    Selected = !(_lookupVehicle is EmptyVehicle) &&
                        _lookupVehicle.Gateway.Equals(g, StringComparison.OrdinalIgnoreCase)
                });
        }

        public NewVehicleViewModel(IDataContext dataContext, IVehicle lookupVehicle)
            : base(dataContext)
        {
            _availableVehicles = dataContext.Vehicle.ListAvailableVehicles(new VehicleFilter());

            Makes = ListMakes();
            Programmes = ListProgrammes();
            ModelYears = ListModelYears();
            Gateways = ListGateways();
        }

        private IEnumerable<IVehicle> _availableVehicles = Enumerable.Empty<Vehicle>();
        private IVehicle _lookupVehicle = new EmptyVehicle();
    }
}