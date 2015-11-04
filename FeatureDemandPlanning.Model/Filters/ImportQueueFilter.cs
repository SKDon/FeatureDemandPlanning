using enums = FeatureDemandPlanning.Model.Enumerations;
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

        public enums.ImportExceptionType ExceptionType 
        { 
            get { return _exceptionType; }
            set { _exceptionType = value; }
        }

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

        private enums.ImportExceptionType _exceptionType = enums.ImportExceptionType.NotSet;
    }
}
