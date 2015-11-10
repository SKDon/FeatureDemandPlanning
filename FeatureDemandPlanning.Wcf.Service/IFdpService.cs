using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Wcf.Service
{
    [ServiceContract]
    public interface IFdpService
    {
        [OperationContract]
        bool IsAlive();

        [OperationContract]
        Task<ImportQueue> ProcessQueuedItem(int importQueueId);
    }
}
