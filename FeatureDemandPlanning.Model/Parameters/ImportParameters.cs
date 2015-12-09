using FeatureDemandPlanning.Model.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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

            if (fromParameters.Action == ImportAction.Upload)
            {
                parameters.UploadFile = fromParameters.UploadFile;
                parameters.CarLine = fromParameters.CarLine;
                parameters.ModelYear = fromParameters.ModelYear;
                parameters.Gateway = fromParameters.Gateway;
                parameters.DocumentId = fromParameters.DocumentId;
            }
            return parameters;
        }
    }
}
