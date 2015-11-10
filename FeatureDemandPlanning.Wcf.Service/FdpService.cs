using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Security.Principal;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Wcf.Service
{
    public class FdpService : IFdpService
    {
        public IDataContext DataContext { get; set; }
        
        public bool IsAlive()
        {
            Console.WriteLine("IsAlive: {0}", WindowsIdentity.GetCurrent().Name);

            return true;
        }

        //[OperationBehavior(Impersonation=ImpersonationOption.Required)]
        public async Task<ImportQueue> ProcessQueuedItem(int importQueueId)
        {
            Console.WriteLine("ProcessQueuedItem: {0}", importQueueId);

            DataContext = DataContextFactory.CreateDataContext(WindowsIdentity.GetCurrent().Name);
            return await DataContext.Import.GetImportQueue(new ImportQueueFilter(importQueueId));
        }
    }
}
