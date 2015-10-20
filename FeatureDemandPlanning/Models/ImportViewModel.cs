using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class ImportViewModel : SharedModelBase
    {
        public ImportQueue CurrentImport { get { return _currentImport; } set { _currentImport = value; } }
        public ImportError CurrentException { get { return _currentException; } set { _currentException = value; } }
        public DerivativeMapping CurrentDerivativeMapping { get { return _currentDerivativeMapping; } set { _currentDerivativeMapping = value; } }
        public PagedResults<ImportError> Exceptions { get; set; }
        public PagedResults<ImportQueue> ImportQueue { get; set; }
        
        public dynamic Configuration { get; set; }

        public ImportViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
        }

        private ImportQueue _currentImport = new EmptyImportQueue();
        private ImportError _currentException = new EmptyImportError();
        private DerivativeMapping _currentDerivativeMapping = new EmptyDerivativeMapping();
        private ForecastTrimMapping _currentTrimMapping = new EmptyTrimMapping();
    }
}