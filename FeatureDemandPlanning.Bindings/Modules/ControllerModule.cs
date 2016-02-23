using FeatureDemandPlanning.Controllers;
using FeatureDemandPlanning.Model.Interfaces;
using Ninject;
using Ninject.Modules;

namespace FeatureDemandPlanning.Bindings.Modules
{
    public class ControllerModule : NinjectModule
    {
        public override void Load()
        {
            Bind<AdminController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<DerivativeController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<DerivativeMappingController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<FeatureController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<FeatureMappingController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<HomeController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<IgnoredExceptionController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<ImportController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<ImportExceptionController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<MarketController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<MarketMappingController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<MarketReviewController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<NewsController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<SpecialFeatureMappingController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<TakeRateController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<TakeRateDataController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<TrimController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<TrimMappingController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<UserController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());

            Bind<VehicleController>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());
        }
    }
}
