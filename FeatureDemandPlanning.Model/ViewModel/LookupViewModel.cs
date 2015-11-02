using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Comparers;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class LookupViewModel : SharedModelBase
    {
        public IEnumerable<SelectListItem> Makes { get; set; }
        public IEnumerable<SelectListItem> Programmes { get; set; }
        public IEnumerable<SelectListItem> ModelYears { get; set; }
        public IEnumerable<SelectListItem> Gateways { get; set; }
        public IEnumerable<SelectListItem> TrimLevels { get; set; }

        private IEnumerable<SelectListItem> ListMakes()
        {
            var makes = _availableVehicles
                .Select(v => v.Make)
                .Distinct()
                .Select(m => new SelectListItem
                {
                    Text = m,
                    Value = m
                }).ToList();

            if (!makes.Any() || makes.Count() == 1)
            {
                return makes;
            }

            if (makes.Any(i => i.Selected == true))
            {
                makes.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "" });
            }
            else
            {
                makes.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "", Selected = true });
            }

            return makes;
        }

        private IEnumerable<SelectListItem> ListProgrammes()
        {
            var programmes = _availableVehicles
                //.Where(v => _lookupVehicle is EmptyVehicle ||
                //        (
                //            v.Make.Equals(_lookupVehicle.Make, StringComparison.OrdinalIgnoreCase))
                //        )
                .Distinct(new UniqueVehicleByNameComparer())
                .Select(v => new SelectListItem
                {
                    Text = v.Description,
                    Value = v.Code,
                    Selected = !(_lookupVehicle is EmptyVehicle) &&
                        _lookupVehicle.ProgrammeId.GetValueOrDefault() == v.ProgrammeId
                }).ToList();

            if (!programmes.Any() || programmes.Count() == 1)
            {
                return programmes;
            }

            AppendDefaultItem(programmes);

            return programmes;
        }

        private IEnumerable<SelectListItem> ListModelYears()
        {
            var modelYears = _availableVehicles
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
                        Selected = !(_lookupVehicle is EmptyVehicle) && !string.IsNullOrEmpty(_lookupVehicle.ModelYear) &&
                            _lookupVehicle.ModelYear.Equals(my, StringComparison.OrdinalIgnoreCase)
                    }).ToList();

            if (!modelYears.Any() || modelYears.Count() == 1)
            {
                return modelYears;
            }

            AppendDefaultItem(modelYears);

            return modelYears;
        }

        private IEnumerable<SelectListItem> ListGateways()
        {
            var gateways = _availableVehicles
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
                    Selected = !(_lookupVehicle is EmptyVehicle) && !string.IsNullOrEmpty(_lookupVehicle.Gateway) &&
                        _lookupVehicle.Gateway.Equals(g, StringComparison.OrdinalIgnoreCase)
                }).ToList();

            if (!gateways.Any() || gateways.Count() == 1)
            {
                return gateways;
            }

            AppendDefaultItem(gateways);

            return gateways;
        }

        public IEnumerable<SelectListItem> ListTrimLevels()
        {
            if (_lookupVehicle is EmptyVehicle || !_lookupVehicle.Programmes.Any())
                return Enumerable.Empty<SelectListItem>();

            var trimLevels = _lookupVehicle.Programmes.First()
                .AllTrims.Select(t => new SelectListItem()
            {
                Text = t.Name,
                Value = t.Id.ToString()
            }).ToList();

            AppendDefaultItem(trimLevels);

            return trimLevels;
        }

        public LookupViewModel(IDataContext dataContext) : base(dataContext)
        {
            _availableVehicles = dataContext.Vehicle.ListAvailableVehicles(new VehicleFilter());

            Makes = Enumerable.Empty<SelectListItem>();
            Programmes = Enumerable.Empty<SelectListItem>();
            ModelYears = Enumerable.Empty<SelectListItem>();
            Gateways = Enumerable.Empty<SelectListItem>();
            TrimLevels = Enumerable.Empty<SelectListItem>();
        }

        public LookupViewModel(IDataContext dataContext, IVehicle lookupVehicle)
            : this(dataContext)
        {
            _lookupVehicle = dataContext.Vehicle.GetVehicle(VehicleFilter.FromVehicle(lookupVehicle));

            Makes = ListMakes();
            Programmes = ListProgrammes();
            ModelYears = ListModelYears();
            Gateways = ListGateways();
            TrimLevels = ListTrimLevels();
        }

        private void AppendDefaultItem(IList<SelectListItem> selectList)
        {
            if (selectList.Any(i => i.Selected == true))
            {
                selectList.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "" });
            }
            else
            {
                selectList.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "", Selected = true });
            }
        }

        private IEnumerable<IVehicle> _availableVehicles = Enumerable.Empty<Vehicle>();
        private IVehicle _lookupVehicle = new EmptyVehicle();
    }
}