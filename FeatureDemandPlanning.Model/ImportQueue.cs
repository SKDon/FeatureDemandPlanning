using FeatureDemandPlanning.Model.Parameters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class ImportQueue
    {
        public int? ImportQueueId { get; set; }
        public int? ImportId { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string CreatedBy { get; set; }
        public string OriginalFileName { get; set; }
        public string FilePath { get; set; }
        public string Description { get; set; }
        public int ErrorCount { get; set; }
        public bool HasErrors { get; set; }

        public ImportType ImportType { get; set; }
        public ImportStatus ImportStatus { get; set; }
        public IEnumerable<ImportError> Errors { get; set; }
        public int ProgrammeId { get; set; }
        public string VehicleName { get; set; }
        public string VehicleAKA { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }
        public int? DocumentId { get; set; }
        public string Document { get; set; }

        public string VehicleDescription
        {
            get
            {
                return string.Format("{0} - {1} ({2}, {3}) - v{4}", 
                    VehicleName, 
                    VehicleAKA, 
                    ModelYear, 
                    Gateway,
                    Document);
            }
        }
        public int? LineNumber { get; set; }

        public int? TotalPages { get; set; }
        public int? TotalRecords { get; set; }

        public DataTable ImportData { get; set; }

        public ImportQueue()
        {
            ImportType = new ImportType() { ImportTypeDefinition = enums.ImportType.PPO };
            ImportStatus = new ImportStatus() { ImportStatusCode = enums.ImportStatus.Queued };
        }
        public void SetStatus(enums.ImportStatus newStatus)
        {
            if (newStatus != ImportStatus.ImportStatusCode)
                ImportStatus = new ImportStatus() { ImportStatusCode = newStatus };
        }

        public static ImportQueue FromParameters(ImportParameters parameters)
        {
            return new ImportQueue()
            {
                ProgrammeId = parameters.ProgrammeId.GetValueOrDefault(),
                ModelYear = parameters.ModelYear,
                Gateway = parameters.Gateway,
                DocumentId = parameters.DocumentId,
                FilePath = parameters.UploadFilePath,
                OriginalFileName = parameters.UploadFile.FileName
            };
        }

        public string[] ToJQueryDataTableResult()
        {
            return new string[] {
                CreatedOn.ToString("g"), 
                CreatedBy,
                VehicleDescription,
                OriginalFileName,
                ImportStatus.Status,
                ImportQueueId.ToString(),
                HasErrors ? "YES" : "NO",
                ErrorCount.ToString()
            };
        }
    }
}
