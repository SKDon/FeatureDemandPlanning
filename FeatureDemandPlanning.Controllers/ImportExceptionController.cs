using FeatureDemandPlanning.Model.Attributes;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.ViewModel;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Results;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Validators;
using FluentValidation;
using MvcSiteMapProvider.Web.Mvc.Filters;

namespace FeatureDemandPlanning.Controllers
{
    public class ImportExceptionController : ControllerBase
    {
        public ImportExceptionController(IDataContext context) : base(context, ControllerType.SectionChild)
        {
        }
        [HttpGet]
        [ActionName("Index")]
        [SiteMapTitle("ImportName")]
        public ActionResult ImportExceptionsPage(int importQueueId)
        {
            return RedirectToAction("ImportExceptionsPage", new ImportExceptionParameters() { ImportQueueId = importQueueId });
        }
        [HttpGet]
        [SiteMapTitle("ImportName")]
        public async Task<ActionResult> ImportExceptionsPage(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var importView = await ImportViewModel.GetModel(DataContext,
                                    new ImportQueueFilter(parameters.ImportQueueId.Value)
                                    {
                                        ExceptionType = parameters.ExceptionType,
                                        PageIndex = PageIndex,
                                        PageSize = PageSize,
                                        Action = ImportAction.ImportQueueItem
                                    });

            var displayName = string.Format("Import Exceptions - {0} - {1:dd/MM/yyyy}", importView.Programme.ToShortString(), importView.CurrentImport.CreatedOn);
            ViewData["ImportName"] = displayName;

            return View(importView);
        }
        [HttpGet]
        public async Task<ActionResult> ImportSummary(ImportExceptionParameters parameters)
        {
            var importView = await ImportViewModel.GetModel(DataContext,
                                    new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault())
                                    {
                                        Action = ImportAction.Summary
                                    });
            
            return PartialView("_ImportSummary", importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public async Task<ActionResult> ListImportExceptions(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var filter = new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault())
            {
                ExceptionType = parameters.ExceptionType,
                FilterMessage = parameters.FilterMessage,
                Action = ImportAction.ImportQueueItem
            };
            filter.InitialiseFromJson(parameters);

            var results = await ImportViewModel.GetModel(DataContext, filter);
            var jQueryResult = new JQueryDataTableResultModel(results);

            // Iterate through the results and put them in a format that can be used by jQuery datatables
            if (!results.HasExceptions()) return Json(jQueryResult);
            jQueryResult.TotalSuccess = results.Exceptions.TotalSuccess;
            jQueryResult.TotalFail = results.Exceptions.TotalFail;

            foreach (var result in results.Exceptions.CurrentPage)
            {
                jQueryResult.aaData.Add(result.ToJQueryDataTableResult());
            }
            return Json(jQueryResult);
        }
        [HttpPost]
        public async Task<ActionResult> ContextMenu(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifier);

            var importView = await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault()));

            return PartialView("_ContextMenu", importView);
        }
        [HttpPost]
        [HandleError(View = "_ModalError")]
        public async Task<ActionResult> ModalContent(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithAction);

            var importView = await GetModelFromParameters(parameters);

            return PartialView(GetContentPartialViewName(parameters.Action), importView);
        }
        [HttpPost]
        [HandleErrorWithJson]
        public ActionResult ModalAction(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ExceptionIdentifierWithActionProgrammeAndGateway);
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, Enum.GetName(parameters.Action.GetType(), parameters.Action));

            if (parameters.Action == ImportAction.MapOxoDerivative)
            {
                TempData["MapOxoDerivative"] = parameters.ImportDerivativeCodes;
            }
            if (parameters.Action == ImportAction.IgnoreAll)
            {
                TempData["IgnoreAll"] = parameters.ExceptionIds;
            }
            if (parameters.Action == ImportAction.MapOxoTrim)
            {
                TempData["MapOxoTrim"] = parameters.ImportTrimLevels;
            }
            if (parameters.Action == ImportAction.MapOxoFeature)
            {
                TempData["MapOxoFeature"] = parameters.ImportFeatureCodes;
            }
            if (parameters.Action == ImportAction.AddSpecialFeature)
            {
                TempData["AddSpecialFeature"] = parameters.ImportFeatureCodes;
            }

            return RedirectToAction(Enum.GetName(parameters.Action.GetType(), parameters.Action), parameters.GetActionSpecificParameters());
        }

        [HttpGet]
        public async Task<ActionResult> RefreshWorktray(ImportExceptionParameters parameters)
        {
            ImportExceptionParametersValidator
                .ValidateImportExceptionParameters(parameters, ImportExceptionParametersValidator.ImportQueueIdentifier);

            var filter = ImportQueueFilter.FromParameters(parameters);
            var queuedItem = await DataContext.Import.GetImportQueue(filter);
            
            DataContext.Import.ReprocessImportQueue(queuedItem);

            return RedirectToAction("ImportExceptionsPage", parameters);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingDerivative(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var derivative = new FdpDerivative()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                DerivativeCode = parameters.DerivativeCode,
                BodyId = parameters.BodyId.GetValueOrDefault(),
                EngineId = parameters.EngineId.GetValueOrDefault(),
                TransmissionId = parameters.TransmissionId.GetValueOrDefault()
            };
            importView.CurrentException = await DataContext.Import.AddDerivative(filter, derivative);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var feature = new FdpFeature()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                FeatureCode = parameters.ImportFeatureCode,
                BrandDescription = parameters.FeatureDescription,
                FeatureGroupId = parameters.FeatureGroupId
            };
            importView.CurrentException = await DataContext.Import.AddFeature(filter, feature);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddMissingTrim(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var trim = new FdpTrim()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                Name = parameters.TrimName,
                Abbreviation = parameters.TrimAbbreviation,
                Level = parameters.TrimLevel,
                DPCK = parameters.DPCK,
                BMC = parameters.DerivativeCode
            };
            importView.CurrentException = await DataContext.Import.AddTrim(filter, trim);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> AddSpecialFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);

            var importFeatures = (IEnumerable<string>)TempData["AddSpecialFeature"];

            foreach (var importFeature in importFeatures)
            {
                var specialFeature = new FdpSpecialFeature()
                {
                    DocumentId = parameters.DocumentId.GetValueOrDefault(),
                    ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                    Gateway = parameters.Gateway,
                    FeatureCode = importFeature,
                    Type = new FdpSpecialFeatureType()
                    {
                        FdpSpecialFeatureTypeId = parameters.SpecialFeatureTypeId
                    }
                };

                await DataContext.Import.AddSpecialFeature(filter, specialFeature);
            }
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingDerivative(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault());
            var derivative = Derivative.FromIdentifier(parameters.DerivativeCode);
            var importView = await GetModelFromParameters(parameters);

            //var derivative = importView.AvailableDerivatives
            //    .First(d => d.DerivativeCode.Equals(parameters.DerivativeCode, StringComparison.InvariantCultureIgnoreCase));

            var derivativeMapping = new FdpDerivativeMapping()
            {
                ImportDerivativeCode = parameters.ImportDerivativeCode,
                
                DocumentId = parameters.DocumentId.GetValueOrDefault(),
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                DerivativeCode = derivative.DerivativeCode,
                BodyId = derivative.BodyId.GetValueOrDefault(),
                EngineId = derivative.EngineId.GetValueOrDefault(),
                TransmissionId = derivative.TransmissionId.GetValueOrDefault()
            };
            importView.CurrentException = await DataContext.Import.MapDerivative(filter, derivativeMapping);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapOxoDerivative(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault());

            var derivative = Derivative.FromIdentifier(parameters.DerivativeCode);
            var importView = await GetModelFromParameters(parameters);

            var importDerivatives = (IEnumerable<string>) TempData["MapOxoDerivative"];
            
            foreach (var importDerivative in importDerivatives)
            {
                var derivativeMapping = new FdpDerivativeMapping()
                {
                    ImportDerivativeCode = importDerivative,
                    DocumentId = parameters.DocumentId.GetValueOrDefault(),
                    ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                    Gateway = parameters.Gateway,
                    DerivativeCode = derivative.DerivativeCode,
                    BodyId = derivative.BodyId.GetValueOrDefault(),
                    EngineId = derivative.EngineId.GetValueOrDefault(),
                    TransmissionId = derivative.TransmissionId.GetValueOrDefault()
                };

                await DataContext.Import.MapDerivative(filter, derivativeMapping);
            }
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapOxoTrim(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault());

            var trim = ModelTrim.FromIdentifier(parameters.TrimIdentifier);
            var importView = await GetModelFromParameters(parameters);

            var importTrimLevels = (IEnumerable<string>)TempData["MapOxoTrim"];

            foreach (var importTrimLevel in importTrimLevels)
            {
                var trimMapping = new FdpTrimMapping()
                {
                    ImportTrim = importTrimLevel,
                    DocumentId = parameters.DocumentId.GetValueOrDefault(),
                    ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                    Gateway = parameters.Gateway,
                    TrimId = trim.Id
                };

                await DataContext.Import.MapTrim(filter, trimMapping);
            }
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapOxoFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault());

            var feature = FdpFeature.FromIdentifier(parameters.FeatureIdentifier);
            var importView = await GetModelFromParameters(parameters);

            var importFeatures = (IEnumerable<string>)TempData["MapOxoFeature"];

            foreach (var importFeature in importFeatures)
            {
                var featureMapping = new FdpFeatureMapping()
                {
                    ImportFeatureCode = importFeature,
                    DocumentId = parameters.DocumentId.GetValueOrDefault(),
                    ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                    Gateway = parameters.Gateway,
                    FeatureCode = feature.FeatureCode
                };
                if (feature.FeaturePackId.HasValue)
                {
                    featureMapping.FeaturePackId = feature.FeaturePackId;
                }
                else
                {
                    featureMapping.FeatureId = feature.FeatureId;
                }

                await DataContext.Import.MapFeature(filter, featureMapping);
            }
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingFeature(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var feature = importView.AvailableFeatures
                .First(f => f.FeatureCode.Equals(parameters.FeatureCode, StringComparison.InvariantCultureIgnoreCase));

            var featureMapping = new FdpFeatureMapping()
            {
                ImportFeatureCode = parameters.ImportFeatureCode,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                FeatureId = feature.FeatureId,
                FeaturePackId = feature.FeaturePackId
            };
            importView.CurrentException = await DataContext.Import.MapFeature(filter, featureMapping);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingTrim(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var trimMapping = new FdpTrimMapping()
            {
                ImportTrim = parameters.ImportTrim,
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                Gateway = parameters.Gateway,
                DocumentId = parameters.DocumentId
            };
            if (!string.IsNullOrEmpty(parameters.TrimIdentifier))
            {
                if (parameters.TrimIdentifier.StartsWith("F"))
                {
                    trimMapping.FdpTrimId = int.Parse(parameters.TrimIdentifier.Substring(1));
                }
                else
                {
                    trimMapping.TrimId = int.Parse(parameters.TrimIdentifier.Substring(1));
                }
            }
            importView.CurrentException = await DataContext.Import.MapTrim(filter, trimMapping);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> MapMissingMarket(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);
            var marketMapping = new FdpMarketMapping()
            {
                ImportMarket = parameters.ImportMarket,
                MarketId = parameters.MarketId,
                ProgrammeId = parameters.ProgrammeId,
                Gateway = parameters.Gateway,
                IsGlobalMapping = parameters.IsGlobalMapping
            };
            importView.CurrentException = await DataContext.Import.MapMarket(filter, marketMapping);
            await DeactivateException(importView.CurrentException);
            await ReProcessException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> ProcessTakeRateData(ImportExceptionParameters parameters)
        {
            var filter = new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault());
            var queuedItem = DataContext.Import.GetImportQueue(filter).Result;
            var results = DataContext.Import.ProcessTakeRateData(queuedItem).Result;

            if (queuedItem.HasErrors)
            {
                return Json(JsonActionResult.GetFailure("Import file still contains errors, unable to process take rate data"));
            }

            if (results == null || !results.TakeRateId.HasValue)
            {
                return Json(JsonActionResult.GetFailure("Take Rate file not created"), JsonRequestBehavior.AllowGet);
            }
            
            // Validate the data for each market

            var takeRateParameters = new TakeRateParameters()
            {
                TakeRateId = results.TakeRateId
            };
            var takeRateFilter = TakeRateFilter.FromTakeRateParameters(takeRateParameters);

            // Get the markets and iterate through them, validating in turn

            var availableMarkets = DataContext.Market.ListMarkets(takeRateFilter).Result;
            foreach (var market in availableMarkets)
            {
                takeRateFilter.Action = TakeRateDataItemAction.Validate;
                takeRateFilter.MarketId = market.Id;
                var takeRateView = await TakeRateViewModel.GetModel(DataContext, takeRateFilter);

                try
                {
                    var interimResults = Validator.Validate(takeRateView.RawData);
                    await Validator.Persist(DataContext, takeRateFilter, interimResults, true);
                }
                catch (ValidationException vex)
                {
                    // Just in case someone has thrown an exception from the validation, which we don't actually want
                    Log.Warning(vex);
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                }
            }

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> IgnoreException(ImportExceptionParameters parameters)
        {
            var filter = ImportQueueFilter.FromExceptionId(parameters.ExceptionId.Value);
            var importView = await GetModelFromParameters(parameters);

            importView.CurrentException = await DataContext.Import.IgnoreException(filter);
            //await DeactivateException(importView.CurrentException);

            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }
        [HandleErrorWithJson]
        public async Task<ActionResult> IgnoreAll(ImportExceptionParameters parameters)
        {
            parameters.ExceptionIds = (IEnumerable<int>) TempData["IgnoreAll"];
            var exceptionIds = parameters.ExceptionIds as IList<int> ?? parameters.ExceptionIds.ToList();
            var lastExceptionId = exceptionIds.Last();
            foreach (var exceptionId in exceptionIds)
            {
                var filter = ImportQueueFilter.FromExceptionId(exceptionId);
                await DataContext.Import.IgnoreException(filter, exceptionId == lastExceptionId);
            }
            return Json(JsonActionResult.GetSuccess(), JsonRequestBehavior.AllowGet);
        }

        #region "Private Methods"

        private async Task<ImportViewModel> GetModelFromParameters(ImportExceptionParameters parameters)
        {
            if (parameters.Action == ImportAction.ProcessTakeRateData)
            {
                return await ImportViewModel.GetModel(
                DataContext,
                new ImportQueueFilter(parameters.ImportQueueId.GetValueOrDefault()) { Action = parameters.Action },
                parameters.Action);
            }
            return await ImportViewModel.GetModel(
                DataContext,
                ImportQueueFilter.FromExceptionId(parameters.ExceptionId.GetValueOrDefault()),
                parameters.Action);
        }
        private async Task<ImportError> DeactivateException(ImportError exception)
        {
            var filter = ImportQueueFilter.FromExceptionId(exception.FdpImportErrorId);
            filter.IsActive = false;

            return await DataContext.Import.SaveException(filter);
        }
        private async Task<ImportResult> ReProcessException(ImportError exception)
        {
            if (!ConfigurationSettings.GetBoolean("ReprocessImportAfterHandleError"))
                return null;

            var queuedItem = new ImportQueue()
            {
                ImportId = exception.FdpImportId,
                ImportQueueId = exception.ImportQueueId,
                LineNumber = int.Parse(exception.LineNumber)
            };
            return await Task.FromResult(DataContext.Import.ReprocessImportQueue(queuedItem));
        }
       
        #endregion
    }
}