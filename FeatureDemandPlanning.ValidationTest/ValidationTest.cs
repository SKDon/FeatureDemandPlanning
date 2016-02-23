using System;
using System.Diagnostics;
using System.Threading.Tasks;
using FeatureDemandPlanning.Bindings.Modules;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Parameters;
using FeatureDemandPlanning.Model.Validators;
using Ninject;
using Ninject.Parameters;

namespace FeatureDemandPlanning.ValidationTest
{
    public class ValidationTest
    {
        public static void Main(string[] args)
        {
            try
            {
                
                Task.Run(() =>
                {
                    var test = new ValidationTest();
                    test.RunAsync();
                }).Wait();
                
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
            Console.ReadLine();
        }

        private static IKernel GetKernel()
        {
            var kernel = new StandardKernel();
            kernel.Load(new DataContextModule(), new SecurityModule(), new ControllerModule());

            return kernel;
        }

        private async void RunAsync()
        {
            const int takeRateId = 2;
            const int marketId = 17;

            var kernel = GetKernel();
            var context = kernel.Get<IDataContext>(new ConstructorArgument("cdsId", "bweston2"));
            var p = new TakeRateParameters
            {
                TakeRateId = takeRateId,
                MarketId = marketId
            };
            var filter = TakeRateFilter.FromTakeRateParameters(p);

            var watch = Stopwatch.StartNew();

            var rawData = await context.TakeRate.GetRawData(filter);

            watch.Stop();
            Console.WriteLine("Total Execution Time: {0} ms", watch.ElapsedMilliseconds);
            watch.Start();

            var results = await Validator.Validate(context, rawData);
            watch.Stop();
            Console.WriteLine("Total Execution Time: {0} ms", watch.ElapsedMilliseconds);

            foreach (var error in results.Errors)
            {
                Console.WriteLine(error.ErrorMessage);
                if (error.CustomState == null)
                {
                    Console.WriteLine("I am stateless :-(");
                }
            }

            watch.Stop();
            Console.WriteLine("Total Execution Time: {0} ms", watch.ElapsedMilliseconds);
        }
    }
}
