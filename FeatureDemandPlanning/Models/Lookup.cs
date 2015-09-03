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
    public class Lookup : SharedModelBase
    {
        public IEnumerable<SelectListItem> Makes { get; set; }
        public IEnumerable<SelectListItem> Programmes { get; set; }
        public IEnumerable<SelectListItem> ModelYears { get; set; }
        public IEnumerable<SelectListItem> Gateways { get; set; }

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

            if (programmes.Any(i => i.Selected == true))
            {
                programmes.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "" });
            }
            else
            {
                programmes.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "", Selected = true });
            }

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

            if (modelYears.Any(i => i.Selected == true))
            {
                modelYears.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "" });
            }
            else
            {
                modelYears.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "", Selected = true });
            }

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

            if (gateways.Any(i => i.Selected == true))
            {
                gateways.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "" });
            }
            else
            {
                gateways.Insert(0, new SelectListItem { Text = "-- SELECT --", Value = "", Selected = true });
            }

            return gateways;
        }

        public Lookup(IDataContext dataContext) : base(dataContext)
        {
            _availableVehicles = dataContext.Vehicle.ListAvailableVehicles(new VehicleFilter());

            Makes = Enumerable.Empty<SelectListItem>();
            Programmes = Enumerable.Empty<SelectListItem>();
            ModelYears = Enumerable.Empty<SelectListItem>();
            Gateways = Enumerable.Empty<SelectListItem>();
        }

        public Lookup(IDataContext dataContext, IVehicle lookupVehicle)
            : this(dataContext)
        {
            _lookupVehicle = lookupVehicle;

            //if (!(lookupVehicle is EmptyVehicle))
            //{
                Makes = ListMakes();
                Programmes = ListProgrammes();
                ModelYears = ListModelYears();
                Gateways = ListGateways();
            //}
        }

        private IEnumerable<IVehicle> _availableVehicles = Enumerable.Empty<Vehicle>();
        private IVehicle _lookupVehicle = new EmptyVehicle();
    }
}