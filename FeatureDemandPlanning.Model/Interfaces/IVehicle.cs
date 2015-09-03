using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IVehicle
    {
        int? VehicleId { get; set; }
        int? ProgrammeId { get; set; }
        int? GatewayId { get; set; }

        string Make { get; set; }
        string Code { get; set; }
        string Description { get; set;  }
        string FullDescription { get; set; }
        string ModelYear { get; set; }
        string Gateway { get; set; }
        string ImageUri { get; set; }

        IEnumerable<Programme> Programmes { get; set; }

        Programme GetProgramme();
        IEnumerable<ModelTrim> ListTrimLevels();
    }
}
