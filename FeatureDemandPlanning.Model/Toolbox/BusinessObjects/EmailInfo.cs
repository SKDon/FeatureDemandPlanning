using System;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class EmailInfo
    {
        public string AddressFrom { get; set; }
        public string AddressTo { get; set; }
        public string AddressCC { get; set; }
        public Object Payload { get; set; }

    }

    public class SystemErrorInfo
    {
        public string DateTime { get; set; }
        public string UserCDSID { get; set; }
        public string Method { get; set; }
        public string Message { get; set; }
    }

    public class EmailTemplate : BusinessObject
    {
        public string Event { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
    }    
}