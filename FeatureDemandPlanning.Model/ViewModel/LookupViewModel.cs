using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Comparers;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class LookupViewModel : SharedModelBase
    {
        public IEnumerable<IVehicle> AvailableVehicles { get; set; }
        public IVehicle LookupVehicle { get; set; }
        public IEnumerable<SelectListItem> Makes { get; set; }
        public IEnumerable<SelectListItem> Programmes { get; set; }
        public IEnumerable<SelectListItem> ModelYears { get; set; }
        public IEnumerable<SelectListItem> Gateways { get; set; }
        public IEnumerable<SelectListItem> TrimLevels { get; set; }

        private IEnumerable<SelectListItem> ListMakes()
        {
            var makes = AvailableVehicles
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
            var programmes = AvailableVehicles
                //.Where(v => LookupVehicle is EmptyVehicle ||
                //        (
                //            v.Make.Equals(LookupVehicle.Make, StringComparison.OrdinalIgnoreCase))
                //        )
                .Distinct(new UniqueVehicleByNameComparer())
                .Select(v => new SelectListItem
                {
                    Text = v.Description,
                    Value = v.Code,
                    Selected = !(LookupVehicle is EmptyVehicle) &&
                        LookupVehicle.ProgrammeId.GetValueOrDefault() == v.ProgrammeId
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
            var modelYears = AvailableVehicles
                    .Where(v => LookupVehicle is EmptyVehicle ||
                            (
                                v.Make.Equals(LookupVehicle.Make, StringComparison.OrdinalIgnoreCase) &&
                                v.ProgrammeId == LookupVehicle.ProgrammeId)
                            )
                    .Select(v => v.ModelYear)
                    .Distinct()
                    .Select(my => new SelectListItem
                    {
                        Text = my,
                        Value = my,
                        Selected = !(LookupVehicle is EmptyVehicle) && !string.IsNullOrEmpty(LookupVehicle.ModelYear) &&
                            LookupVehicle.ModelYear.Equals(my, StringComparison.OrdinalIgnoreCase)
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
            var gateways = AvailableVehicles
                .Where(v => LookupVehicle is EmptyVehicle ||
                        (
                            v.Make.Equals(LookupVehicle.Make, StringComparison.OrdinalIgnoreCase) &&
                            v.ProgrammeId == LookupVehicle.ProgrammeId &&
                            v.ModelYear.Equals(LookupVehicle.ModelYear, StringComparison.OrdinalIgnoreCase
                        )))
                .Select(v => v.Gateway)
                .Distinct()
                .Select(g => new SelectListItem
                {
                    Text = g,
                    Value = g,
                    Selected = !(LookupVehicle is EmptyVehicle) && !string.IsNullOrEmpty(LookupVehicle.Gateway) &&
                        LookupVehicle.Gateway.Equals(g, StringComparison.OrdinalIgnoreCase)
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
            if (LookupVehicle is EmptyVehicle || !LookupVehicle.Programmes.Any())
                return Enumerable.Empty<SelectListItem>();

            var trimLevels = LookupVehicle.Programmes.First()
                .AllTrims.Select(t => new SelectListItem()
            {
                Text = t.Name,
                Value = t.Id.ToString()
            }).ToList();

            AppendDefaultItem(trimLevels);

            return trimLevels;
        }

        public LookupViewModel()
            : base()
        {
            InitialiseMembers();
        }
        public static LookupViewModel GetModel(IDataContext context)
        {
            var model = new LookupViewModel()
            {
                Configuration = context.ConfigurationSettings
            };

            model.AvailableVehicles = context.Vehicle.ListAvailableVehicles(new VehicleFilter());
            model.Makes = model.ListMakes();
            model.Programmes = model.ListProgrammes();
            model.ModelYears = model.ListModelYears();
            model.Gateways = model.ListGateways();
            model.TrimLevels = model.ListTrimLevels();

            return model;
        }

        public static async Task<LookupViewModel> GetModelForVehicle(IVehicle forVehicle, IDataContext context)
        {
            var model = GetModel(context);
            model.LookupVehicle = await context.Vehicle.GetVehicle(VehicleFilter.FromVehicle(forVehicle));
            model.Makes = model.ListMakes();
            model.Programmes = model.ListProgrammes();
            model.ModelYears = model.ListModelYears();
            model.Gateways = model.ListGateways();
            model.TrimLevels = model.ListTrimLevels();

            return model;
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
        private void InitialiseMembers()
        {
            Makes = Enumerable.Empty<SelectListItem>();
            Programmes = Enumerable.Empty<SelectListItem>();
            ModelYears = Enumerable.Empty<SelectListItem>();
            Gateways = Enumerable.Empty<SelectListItem>();
            TrimLevels = Enumerable.Empty<SelectListItem>();
            LookupVehicle = new EmptyVehicle();
            AvailableVehicles = Enumerable.Empty<IVehicle>();
        }
    }
}