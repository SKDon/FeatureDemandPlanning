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
                r => r == UserRole.Editor || r == UserRole.MarketReviewer);
        }
        public bool HasApproverRole()
        {
            return Roles.Any(r => r == UserRole.Approver);
        }
        public bool HasCloneRole()
        {
            return Roles.Any(r => r == UserRole.Cloner);
        }
        public bool HasReviewerRole()
        {
            return Roles.Any(r => r == UserRole.MarketReviewer || r == UserRole.Approver);
        }
        public bool HasAccessAllProgrammesRole()
        {
            return Roles.Any(r => r == UserRole.AllProgrammes);
        }
        public bool HasAccessAllMarketsRole()
        {
            return Roles.Any(r => r == UserRole.AllMarkets);
        }
        public bool IsMarketEditable(int marketId)
        {
            return Markets.Any(m => m.Action == UserAction.Edit && m.MarketId == marketId) ||
                (HasEditRole() && HasAccessAllMarketsRole());
        }
        public bool IsProgrammeEditable(int programmeId)
        {
            return Programmes.Any(
                p => p.Action == UserAction.Edit && p.ProgrammeId == programmeId) ||
                   (HasEditRole() && HasAccessAllProgrammesRole());
        }
        public string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                FdpUserId.GetValueOrDefault().ToString(),
                CDSId, 
                FullName,
                Mail,
                Roles.ToCommaSeperatedString(),
                Programmes.ToCommaSeperatedString(),
                Markets.ToCommaSeperatedString(),
                IsActive ? "YES" : "NO",
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
                IsAdmin = parameters.IsAdmin.GetValueOrDefault(),
                Mail = parameters.Mail
            };
        }
    }
}
