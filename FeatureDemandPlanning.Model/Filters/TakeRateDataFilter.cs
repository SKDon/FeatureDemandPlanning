using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class TakeRateDataFilter : ProgrammeFilter
    {
        public TakeRateDataAction Action { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public int? FdpVolumeHeaderId { get; set; }
        public int? MarketGroupId { get; set; }
        public int? MarketId { get; set; }
        public IEnumerable<Model> Models { get; set; }

        public TakeRateDataFilter()
        {
            Action = TakeRateDataAction.NotSet;
            Mode = TakeRateResultMode.PercentageTakeRate;
            Models = Enumerable.Empty<Model>();
        }
        public static TakeRateDataFilter FromParameters(TakeRateDataParameters parameters)
        {
            return new TakeRateDataFilter()
            {
                OxoDocId = parameters.OxoDocId,
                MarketGroupId = parameters.MarketGroupId,
                MarketId = parameters.MarketId,
                Mode = parameters.ResultsMode,
                Models = parameters.Models
            };
        }
        public static TakeRateDataFilter FromTakeRateDataViewModel(ViewModel.TakeRateDataViewModel takeRateDataView)
        {
            return new TakeRateDataFilter()
            {
                ProgrammeId = takeRateDataView.Programme.Id,
                Gateway = takeRateDataView.Programme.Gateway,
                OxoDocId = takeRateDataView.Document.Id
            };
        }
    }
}
