using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model
{
    public class ImportQueue
    {
        public int? ImportQueueId { get; set; }
        public DateTime CreatedOn { get; set; }
        public DateTime? UpdatedOn { get; set; }
        public string CreatedBy { get; set; }
        public string FilePath { get; set; }
        public string Description { get; set; }
        public bool HasErrors { get; set; }

        public ImportType ImportType { get; set; }
        public ImportStatus ImportStatus { get; set; }
        public IEnumerable<ImportError> Errors { get; set; }
        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public int? TotalPages { get; set; }
        public int? TotalRecords { get; set; }

        public ImportQueue()
        {
            ImportType = new ImportType() { ImportTypeDefinition = enums.ImportType.Fdp };
            ImportStatus = new ImportStatus() { ImportStatusCode = enums.ImportStatus.Queued };
            CreatedOn = DateTime.Now;
        }
        
        public ImportQueue(string cdsId, string filePath) : this()
        {
            CreatedBy = cdsId;
            FilePath = filePath;
        }
        public void SetStatus(enums.ImportStatus newStatus)
        {
            if (newStatus != ImportStatus.ImportStatusCode)
                ImportStatus = new ImportStatus() { ImportStatusCode = newStatus };
        }
    }
}
