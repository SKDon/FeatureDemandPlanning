using System;
using System.Web.Mvc;
using System.Web.Routing;
using Ninject;

namespace FeatureDemandPlanning.Bindings
{
    public class ControllerFactory : DefaultControllerFactory
    {
        public IKernel Kernel { get; private set; }

        public ControllerFactory(IKernel kernel)
        {
            Kernel = kernel;
        }
        protected override IController GetControllerInstance(RequestContext requestContext, Type controllerType)
        {
            IController controller = null;

            if (controllerType != null)
                controller = (IController)Kernel.Get(controllerType);

            return controller; 
        }
    }
}
