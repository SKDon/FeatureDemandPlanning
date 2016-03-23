namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ImportExceptionType
    {
        NotSet = 0,
        MissingMarket = 1,
        MissingFeature = 2,
        MissingDerivative = 3,
        MissingTrim = 4,

        NoFeatureCode = 201,
        NoHistoricFeature = 202,
        NoOxoFeature = 203,
        NoSpecialFeature = 204,

        NoBmc = 301,
        NoHistoricDerivative = 302,
        NoOxoDerivative = 303,

        NoDpck = 401,
        NoHistoricTrim = 402,
        NoOxoTrim = 403
    }
}
