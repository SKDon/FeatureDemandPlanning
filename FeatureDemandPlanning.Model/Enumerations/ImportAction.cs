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
        MapOxoDerivative = 13,
        IgnoreAll = 14,
        MapOxoTrim = 15,
        MapOxoFeature = 16,
        ProcessTakeRateData = 17,
        DeleteImport = 18,

        Upload = 100,
        Summary
        
    }
}
