using System.Collections.Generic;

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

        public string Name
        {
            get
            {
                if (Body is EmptyModelBody || Engine is EmptyModelEngine || Transmission is EmptyModelTransmission)
                    return DerivativeCode;

                return string.IsNullOrEmpty(DerivativeCode) ? 
                    string.Format("{0} {1} {2}", Body.Name, Engine.Name, Transmission.Name) : 
                    string.Format("{0} - {1} {2} {3}", DerivativeCode, Body.Name, Engine.Name, Transmission.Name);
            }
        }

        public string Identifier
        {
            get
            {
                return !string.IsNullOrEmpty(DerivativeCode) ? 
                    string.Format("{0}|{1}|{2}|{3}", DerivativeCode, BodyId, EngineId, TransmissionId) : 
                    string.Format("{0}|{1}|{2}", BodyId, EngineId, TransmissionId);
            }
        }

        public Derivative()
        {
            Body = new EmptyModelBody();
            Engine = new EmptyModelEngine();
            Transmission = new EmptyModelTransmission();
        }

        public static Derivative FromIdentifier(string identifier)
        {
            var elements = identifier.Split('|');
            if (elements.Length == 4)
            {
                return new Derivative()
                {
                    DerivativeCode = elements[0],
                    BodyId = int.Parse(elements[1]),
                    EngineId = int.Parse(elements[2]),
                    TransmissionId = int.Parse(elements[3])
                };
            }
            return new Derivative()
            {
                BodyId = int.Parse(elements[0]),
                EngineId = int.Parse(elements[1]),
                TransmissionId = int.Parse(elements[2])
            };
        }

        public string[] ToJQueryDataTableResult()
        {
            return new[]
            {
                string.Empty,
                string.Empty,
                string.Empty,
                string.Empty,
                DerivativeCode,
                Body.Name,
                Engine.Name,
                Transmission.Name
            };
        }
    }

    public class DerivativeComparer : IEqualityComparer<Model>
    {
        public bool Equals(Model x, Model y)
        {
            return x.BodyId == y.BodyId && x.EngineId == y.EngineId && x.TransmissionId == y.TransmissionId;
        }

        public int GetHashCode(Model obj)
        {
            return ((obj.BodyId * 10) + (obj.EngineId * 100) + (obj.TransmissionId * 1000)).GetHashCode();
        }
    }
}
