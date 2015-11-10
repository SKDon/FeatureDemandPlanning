using FeatureDemandPlanning.Wcf.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Wcf.Test
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Starting FeatureDemandPlanning.Wcf.Service...");

            using (ServiceHost host = new ServiceHost(typeof(FdpService)))
            {
                host.Open();

                Console.WriteLine("Service up and running at:");
                foreach (var ea in host.Description.Endpoints)
                {
                    Console.WriteLine(ea.Address);
                }

                Console.ReadLine();
                Console.WriteLine("Stopping service...");
                host.Close();
                Console.WriteLine("Service stopped...Closing");
            }
        }
    }
}
