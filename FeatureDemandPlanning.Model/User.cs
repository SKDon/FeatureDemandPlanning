using System;
using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model
{
    public class User
    {
        public int? FdpUserId { get; set; }
        public string CDSId { get; set; }
        public string FullName { get; set; }
        public string Mail { get; set; }
        public bool IsActive { get; set; }
        public bool IsAdmin { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public IEnumerable<UserRole> Roles { get; set; }
        public IEnumerable<UserMarketMapping> Markets { get; set; }
        public IEnumerable<UserProgrammeMapping> Programmes { get; set; } 

        public User()
        {
            Roles = Enumerable.Empty<UserRole>();
            Programmes = Enumerable.Empty<UserProgrammeMapping>();
            Markets = Enumerable.Empty<UserMarketMapping>();
        }

        public bool HasEditRole()
        {
            return Roles.Any(
                r => r == UserRole.Administrator || r == UserRole.Editor || r == UserRole.MarketReviewer);
        }
        public bool IsMarketEditable(int marketId)
        {
            return Markets.Any(m => m.Action == UserAction.Edit && m.MarketId == marketId);
        }
        public bool IsProgrammeEditable(int programmeId)
        {
            return Programmes.Any(
                p => p.Action == UserAction.Edit && p.ProgrammeId == programmeId);
        }
        public string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpUserId.GetValueOrDefault().ToString(),
                CDSId, 
                FullName,
                Programmes.ToCommaSeperatedString(),
                IsActive ? "YES" : "NO",
                IsAdmin ? "YES" : "NO",
                CreatedOn.HasValue ? CreatedOn.Value.ToString("dd/MM/yyyy HH:mm") : string.Empty,
                CreatedBy,
                Markets.ToCommaSeperatedString()
            };
        }

        public static User FromParameters(UserParameters parameters)
        {
            return new User()
            {
                CDSId = parameters.CDSId,
                FullName = parameters.FullName,
                IsAdmin = parameters.IsAdmin.GetValueOrDefault(),
            };
        }
    }
}
