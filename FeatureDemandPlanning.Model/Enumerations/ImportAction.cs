namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum ImportAction
    {
        NotSet = 0,
        MapMissingMarket = 1,
        AddMissingDerivative = 2,
        MapMissingDerivative = 3,
        AddMissingFeature = 4,
        MapMissingFeature = 5,
        AddMissingTrim = 6,
        MapMissingTrim = 7,
        IgnoreException = 8,
        AddSpecialFeature = 9,
        Exception = 10,
        ImportQueue = 11,
        ImportQueueItem = 12,

        Upload = 100,
        Summary,
    }
}
