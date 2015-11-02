using FeatureDemandPlanning.Model.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Filters
{
    public class ImportQueueFilter : FilterBase
    {
        public int? ImportQueueId { get; set; }
        public int? ExceptionId { get; set; }

        public ImportExceptionType ExceptionType 
        { 
            get { return _exceptionType; }
            set { _exceptionType = value; }
        }
        public string FilterMessage { get; set; }

        public ImportQueueFilter()
        {
        }

        public ImportQueueFilter(int importQueueId) : this()
        {
            ImportQueueId = importQueueId;
        }

        public static ImportQueueFilter FromExceptionId(int exceptionId)
        {
            return new ImportQueueFilter()
            {
                ExceptionId = exceptionId
            };
        }

        //public static ImportQueueFilter FromImportExceptionParameters(ImportExceptionParameters parameters)
        //{
        //    var filter = new ImportQueueFilter(parameters.ImportQueueId);
        //    if ()
        //}

        private ImportExceptionType _exceptionType = ImportExceptionType.NotSet;
    }
}
