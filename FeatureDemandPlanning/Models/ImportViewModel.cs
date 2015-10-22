using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Context;
using FeatureDemandPlanning.Enumerations;
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
        public TrimMapping CurrentTrimMapping { get { return _currentTrimMapping; } set { _currentTrimMapping = value; } }
        public ImportExceptionAction CurrentAction { get { return _currentImportExceptionAction; } set { _currentImportExceptionAction = value; } }

        public PagedResults<ImportError> Exceptions { get; set; }
        public PagedResults<ImportQueue> ImportQueue { get; set; }

        public Programme Programme { get; set; }
        public string Gateway { get; set; }

        public IEnumerable<ModelEngine> AvailableEngines { get; set; }
        public IEnumerable<ModelTransmission> AvailableTransmissions { get; set; }
        public IEnumerable<ModelBody> AvailableBodies { get; set; }
        public IEnumerable<ModelTrim> AvailableTrim { get; set; }
        public IEnumerable<SpecialFeature> AvailableSpecialFeatures { get; set; }
        
        public dynamic Configuration { get; set; }

        public ImportViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
        }

        private ImportQueue _currentImport = new EmptyImportQueue();
        private ImportError _currentException = new EmptyImportError();
        private DerivativeMapping _currentDerivativeMapping = new EmptyDerivativeMapping();
        private TrimMapping _currentTrimMapping = new EmptyTrimMapping();
        private ImportExceptionAction _currentImportExceptionAction = ImportExceptionAction.NotSet;
    }
}