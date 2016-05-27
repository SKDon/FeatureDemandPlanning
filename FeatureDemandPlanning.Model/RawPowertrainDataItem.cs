namespace FeatureDemandPlanning.Model
{
    public class RawPowertrainDataItem
    {
        public int FdpVolumeHeaderId { get; set; }
		public int FdpPowertrainDataItemId { get; set; }
		public int MarketId { get; set; }
		public string Market { get; set; }
		public int MarketGroupId { get; set; }
		public string MarketGroup { get; set; }
        public string DerivativeCode { get; set; }
		public int BodyId { get; set; }
		public int EngineId { get; set; }
		public int TransmissionId { get; set; }
		public string Cylinder { get; set; }
		public string Doors { get; set; }
		public string Drivetrain { get; set; }
		public string Electrification { get; set; }
		public string FuelType { get; set; }
		public string Shape { get; set; }
		public string Size { get; set; }
        public string Power { get; set; }
		public string Turbo { get; set; }
		public string Type { get; set; }
		public string Wheelbase { get; set; }
		public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }
        public bool IsDirty { get; set; }
        public int NumberOfModels { get; set; }
    }
}
