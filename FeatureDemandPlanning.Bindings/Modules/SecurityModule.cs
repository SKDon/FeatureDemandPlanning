using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Security;
using Ninject;
using Ninject.Modules;

namespace FeatureDemandPlanning.Bindings.Modules
{
    public class SecurityModule : NinjectModule
    {
        public override void Load()
        {
            Bind<HasAccessToProgrammePolicy>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());
            Bind<HasAccessToMarketPolicy>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());
            Bind<DefaultSecurityPolicy>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());
            Bind<CustomRoleProvider>()
                .ToSelf()
                .WithConstructorArgument("context", context => context.Kernel.Get<IDataContext>());
        }
    }
}
