using System;

namespace FeatureDemandPlanning.Model
{
    public class UserDataItem
    {
        public int? FdpUserId { get; set; }
        public string CDSId { get; set; }
        public string FullName { get; set; }
        public string Mail { get; set; }
        public bool IsActive { get; set; }
        public bool IsAdmin { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public string Roles { get; set; }
        public string Programmes { get; set; }
        public string Markets { get; set; }

        public User ToUser()
        {
            return new User()
            {
                CDSId = CDSId,
                FdpUserId = FdpUserId,
                FullName = FullName,
                IsAdmin = IsAdmin,
                IsActive = IsActive,
                CreatedOn = CreatedOn,
                CreatedBy = CreatedBy
            };
        }

        public string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpUserId.GetValueOrDefault().ToString(),
                CDSId, 
                FullName,
                Mail,
                Roles,
                Programmes,
                Markets,
                IsActive ? "YES" : "NO"
                
            };
        }
    }
}
