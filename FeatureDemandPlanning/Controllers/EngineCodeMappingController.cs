using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using FeatureDemandPlanning.Comparers;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace FeatureDemandPlanning.Controllers
{
    public class EngineCodeMappingController : ControllerBase
    {
        public EngineCodeMappingController()
        {
            PageIndex = 1;
            PageSize = DataContext.ConfigurationSettings.DefaultPageSize;
            ControllerType = ControllerType.SectionChild;
        }

        [HttpGet]
        public ActionResult EngineCodeMapping()
        {
            var engineCodeMappingModel = GetFullAndPartialEngineCodeMappingViewModel(new EngineCodeFilter()
            {
                PageSize = PageSize,
                PageIndex = PageIndex
            });

            if (!engineCodeMappingModel.EngineCodeMappings.CurrentPage.Any())
            {
                engineCodeMappingModel.SetProcessState(
                    new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Warning, "No programmes available matching search criteria"));
            }
            else
            {
                // Get a count of the number of programmes vs the number of engine codes actually mapped

                var numberOfProgrammes = engineCodeMappingModel.EngineCodeMappings.CurrentPage.Select(e => e.Id).Distinct();
                var numberOfMappings = engineCodeMappingModel.EngineCodeMappings.CurrentPage.Where(e => !String.IsNullOrEmpty(e.ExternalEngineCode));

                engineCodeMappingModel.SetProcessState(
                    new BusinessObjects.ProcessState(Enumerations.ProcessStatus.Information, String.Format("{0} programmes, {1} mapped engine codes matching search criteria", numberOfProgrammes, numberOfMappings)));
            }

            return View("EngineCodeMapping", engineCodeMappingModel);
        }

        [HttpGet]
        public ActionResult EngineCodeMappings(JQueryDataTableParameters param)
        {
            var js = new JavaScriptSerializer();

            var filter = new EngineCodeFilter();
            filter.InitialiseFromJson(param);
            //if (!string.IsNullOrEmpty(param.sSearch))
            //{
            //    filter = (EngineCodeFilter)js.Deserialize(param.sSearch, typeof(EngineCodeFilter));
            //}

            var results = GetFullAndPartialEngineCodeMappingViewModel(filter).EngineCodeMappings;
            var jQueryResult = new JQueryDataTableResultModel(0, 0);

            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (results.CurrentPage.Any())
            {
                jQueryResult.iTotalRecords = results.TotalRecords;
                jQueryResult.iTotalDisplayRecords = results.TotalRecords;

                foreach (var result in results.CurrentPage)
                {
                    var stringResult = new string[] 
                    { 
                        result.VehicleMake, 
                        string.Format("{0} - {1}", result.VehicleName, result.VehicleAKA),
                        result.ModelYear,
                        string.Format("{0} {1}", result.EngineSize, result.Cylinder),
                        result.Fuel,
                        result.Power,
                        result.Electrification,
                        result.ExternalEngineCode,
                        result.Id.ToString(),
                        result.EngineId.ToString()
                    };

                    jQueryResult.aaData.Add(stringResult);
                }

                // As we have a simple array of columns, sorting is easier at this point as we can it by array index
                if (param.order != null && param.order.Any())
                {
                    var sort = param.order.First();
                    jQueryResult.aaData.Sort(new StringArrayIndexComparer(sort.column, sort.dir.Equals("ASC", StringComparison.OrdinalIgnoreCase) ? false : true));
                }
            }

            return Json(jQueryResult, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult EditEngineCodeMapping(EngineCodeMapping mapping)
        {
            mapping = DataContext.Vehicle.UpdateEngineCodeMapping(mapping);

            return Json(mapping, JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Gets the full and partial view model to be used by the controller actions
        /// </summary>
        /// <returns></returns>
        private EngineCodeMappingViewModel GetFullAndPartialEngineCodeMappingViewModel(EngineCodeFilter filter)
        {
            var engineCodeMappingModel = new EngineCodeMappingViewModel(DataContext)
            {
                EngineCodeMappings = DataContext.Vehicle.ListEngineCodeMappings(filter),
                PageSize = PageSize,
                PageIndex = PageIndex
            };

            if (engineCodeMappingModel.EngineCodeMappings.CurrentPage.Any())
            {
                engineCodeMappingModel.TotalPages = engineCodeMappingModel.EngineCodeMappings.TotalPages;
                engineCodeMappingModel.TotalRecords = engineCodeMappingModel.EngineCodeMappings.TotalRecords;
            }

            return engineCodeMappingModel;
        }
    }
}