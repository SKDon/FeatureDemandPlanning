using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Enumerations;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IVolume
    {
        OXODoc Document { get; set; }
        Vehicle Vehicle { get; set; }

        Market Market { get; set; }
        MarketGroup MarketGroup { get; set; }

        VolumeResultMode Mode { get; set; }

        int TotalDerivatives { get; set; }

        IEnumerable<FdpVolumeHeader> FdpVolumeHeaders { get; set; }
        VolumeData VolumeData { get; set; }
    }
}
