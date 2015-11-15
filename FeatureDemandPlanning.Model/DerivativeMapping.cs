namespace FeatureDemandPlanning.Model
{
    public class DerivativeMapping
    {
        public int FdpDerivativeMappingId { get; set; }

        public string ImportDerivativeCode { get; set; }

        public int ProgrammeId { get; set; }
        public int BodyId { get; set; }
        public int EngineId { get; set; }
        public int TransmissionId { get; set; }
    }
}
