using FeatureDemandPlanning.Model.Parameters;
using System;

namespace FeatureDemandPlanning.Model
{
    public class User
    {
        public int? FdpUserId { get; set; }
        public string CDSId { get; set; }
        public string FullName { get; set; }
        public bool IsActive { get; set; }
        public bool IsAdmin { get; set; }
        public string Programmes { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }


        public string[] ToJQueryDataTableResult()
        {
            return new string[] 
            { 
                FdpUserId.GetValueOrDefault().ToString(),
                CDSId, 
                FullName,
                !string.IsNullOrEmpty(Programmes) ? Programmes : "-",
                IsActive == true ? "YES" : "NO",
                IsAdmin == true ? "YES" : "NO",
                CreatedOn.HasValue ? CreatedOn.Value.ToString("dd/MM/yyyy HH:mm") : string.Empty,
                CreatedBy
            };
        }

        public static User FromParameters(UserParameters parameters)
        {
            return new User()
            {
                CDSId = parameters.CDSId,
                FullName = parameters.FullName,
                IsAdmin = parameters.IsAdmin.GetValueOrDefault()
            };
        }
    }
}
