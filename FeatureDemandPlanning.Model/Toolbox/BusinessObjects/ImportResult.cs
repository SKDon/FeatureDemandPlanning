using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ImportResult
    {
        public ImportStatus Status { get; set; }
        public int NumberOfRecords { get; set; }
        public IEnumerable<ImportError> Exceptions { get; set; }

        public ImportResult()
        {
            Status = new ImportStatus();
        }

        public void AddException(ImportError errorToAdd)
        {
            _exceptions.Add(errorToAdd);
        }

        private IList<ImportError> _exceptions = new List<ImportError>();
    }
}
