namespace FeatureDemandPlanning.Model
{
    public class Derivative
    {
        public string DerivativeCode { get; set; }
        
        public int? BodyId { get; set; }
        public int? EngineId { get; set; }
        public int? TransmissionId { get; set; }

        public ModelBody Body { get; set; }
        public ModelEngine Engine { get; set; }
        public ModelTransmission Transmission { get; set; }

        public bool IsMappedDerivative { get; set; }

        public string Name
        {
            get
            {
                if (Body is EmptyModelBody || Engine is EmptyModelEngine || Transmission is EmptyModelTransmission)
                    return DerivativeCode;

                return string.Format("{0} - {1} {2} {3}", DerivativeCode, Body.Name, Engine.Name, Transmission.Name);
            }
        }

        public Derivative()
        {
            Body = new EmptyModelBody();
            Engine = new EmptyModelEngine();
            Transmission = new EmptyModelTransmission();
        }
    }
}
