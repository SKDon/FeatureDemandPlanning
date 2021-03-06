﻿namespace FeatureDemandPlanning.Model.Filters
{
    public class EngineCodeFilter : ProgrammeFilter
    {
        public int? EngineId { get; set; }

        public string EngineSize { get; set; }
        public string Cylinder { get; set; }
        public string Fuel { get; set; }
        public string Power { get; set; }
        public string Electrification { get; set; }
        public string DerivativeCode { get; set; }
    }
}
