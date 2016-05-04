namespace FeatureDemandPlanning.Helpers
{
    public static class OxoHelper
    {
        public static string ParseFeatureApplicability(string featureApplicability)
        {
            return featureApplicability
                .Replace("*", string.Empty)
                .Replace("(", string.Empty)
                .Replace(")", string.Empty)
                .Replace("1-", string.Empty)
                .Replace("2-", string.Empty)
                .Replace("3-", string.Empty)
                .ToUpper();
        }
    }
}
