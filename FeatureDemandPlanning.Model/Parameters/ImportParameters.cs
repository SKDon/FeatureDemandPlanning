using System;
using FeatureDemandPlanning.Model.Enumerations;
using System.Web;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class ImportParameters : JQueryDataTableParameters
    {
        public int? ImportQueueId { get; set; }
        public int? ImportStatusId { get; set; }
        public int? ProgrammeId { get; set; }
        public string FilterMessage { get; set; }
        public ImportAction Action { get; set; }

        public HttpPostedFileBase UploadFile { get; set; }
        public string UploadFilePath { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public int? DocumentId { get; set; }

        public ImportParameters()
        {
            FilterMessage = string.Empty;
        }
        public bool HasImportQueueId()
        {
            return ImportQueueId.HasValue;
        }
        public static ImportParameters GetActionSpecificParameters(ImportParameters fromParameters)
        {
            var parameters = new ImportParameters()
            {
                Action = fromParameters.Action
            };
            switch (fromParameters.Action)
            {
                case ImportAction.Upload:
                    parameters.UploadFile = fromParameters.UploadFile;
                    parameters.CarLine = fromParameters.CarLine;
                    parameters.ModelYear = fromParameters.ModelYear;
                    parameters.Gateway = fromParameters.Gateway;
                    parameters.DocumentId = fromParameters.DocumentId;
                    break;
                case ImportAction.DeleteImport:
                    parameters.ImportQueueId = fromParameters.ImportQueueId;
                    break;
                case ImportAction.NotSet:
                    break;
                case ImportAction.MapMissingMarket:
                    break;
                case ImportAction.AddMissingDerivative:
                    break;
                case ImportAction.MapMissingDerivative:
                    break;
                case ImportAction.AddMissingFeature:
                    break;
                case ImportAction.MapMissingFeature:
                    break;
                case ImportAction.AddMissingTrim:
                    break;
                case ImportAction.MapMissingTrim:
                    break;
                case ImportAction.IgnoreException:
                    break;
                case ImportAction.AddSpecialFeature:
                    break;
                case ImportAction.Exception:
                    break;
                case ImportAction.ImportQueue:
                    break;
                case ImportAction.ImportQueueItem:
                    break;
                case ImportAction.MapOxoDerivative:
                    break;
                case ImportAction.IgnoreAll:
                    break;
                case ImportAction.MapOxoTrim:
                    break;
                case ImportAction.MapOxoFeature:
                    break;
                case ImportAction.ProcessTakeRateData:
                    break;
                case ImportAction.Summary:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }
            return parameters;
        }
    }
}
