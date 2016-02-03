using System.Reflection;
using log4net;

namespace FeatureDemandPlanning.Security
{
    public class PolicyViolationHandlerBase
    {
        protected static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}