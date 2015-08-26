using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Script.Serialization;
using System.Configuration;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.BusinessObjects
{
    [Serializable]
    public class SystemUser : BusinessObject
    {
        //Private Member
        private string _cdsid;
        private IEnumerable<Permission> _permissions;
        private IEnumerable<NameValuePair> _preference;
        private IEnumerable<Programme> _allowedProgramme;
        private IEnumerable<Programme> _availableProgramme;
        private IDataContext _dataContext = null;

        private const string ProgrammeKey = "Programme";
        private const string ReportKey = "Rpt";
        private const string AdminKey = "Adm";
        
        private const string AddKey = "CanAdd";
        private const string EditKey = "CanEdit";
        private const string ViewKey = "CanView";
        private const string PublishKey = "CanPublish";
        private const string MarketInputKey = "CanAccessMarketData";
        private const string AccessKey = "CanAccess";

        public SystemUser()
        {

        }

        public SystemUser(string cdsId, IDataContext dataContext)
        {
            CDSID = cdsId;
            _dataContext = dataContext;
        }

        [Required]
        [StringLength(10)]
        public string CDSID
        {
            get
            {
                if (!string.IsNullOrEmpty(_cdsid))
                    return _cdsid.ToLower();
                else
                    return _cdsid;
            }
            set
            {
                _cdsid = value;
            }
        }
        [Required]
        [StringLength(50)]
        public string Title { get; set; }
        [Required]
        [StringLength(100)]
        public string Firstnames { get; set; }
        [Required]
        [StringLength(100)]
        public string Surname { get; set; }
        [Required]
        [StringLength(500)]
        public string Department { get; set; }
        [Required]
        [StringLength(500)]
        public string JobTitle { get; set; }
        [StringLength(300)]
        public string SeniorManager { get; set; }
        [Required]
        [StringLength(100)]
        [RegularExpression(@"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}", ErrorMessage = "Must be a valid email address")]
        public string Email 
        {
            get
            {
                return CDSID + ConfigurationManager.AppSettings["EmailAddressAddOn"].ToString();
            }
        
        }

        public string AllowedProgrammeString { get; set; }
        public string AllowedSectionString { get; set; }
        
        public DateTime? RegisteredOn { get; set; }
        public bool IsAdmin { get; set; }
        public string DepartmentText { get; set; }
        
        public string FullNameTitle
        {
            get
            {
                return string.Format("{0} {1} {2}", Title, Firstnames, Surname);
            }
        }
        // Calculated field here
        public string Fullname { get { return String.Format("{0} {1}", Firstnames, Surname); } }
        public bool IsRegistered { get { return RegisteredOn != null; } }

        public string ProgrammeList { get; set; }

        [ScriptIgnore]
        public IEnumerable<Permission> Permissions
        {
            get 
            {
                if (_permissions == null && !String.IsNullOrEmpty(CDSID))
                {
                    _permissions = _dataContext.User.ListPermissions();
                }
                return _permissions;
            }
            set 
            {
                _permissions = value;
            }
        }

        [ScriptIgnore]
        public IEnumerable<NameValuePair> Preferences
        {
            get
            {
                if (_preference == null)
                {
                    _preference = _dataContext.User.ListPreferences();
                }
                return _preference;
            }
            set
            {
                _preference = value;
            }
        }

        [ScriptIgnore]
        public IEnumerable<Programme> AllowedProgrammes
        {
            get
            {
                if (_allowedProgramme == null)
                {
                    _allowedProgramme = _dataContext.User.ListAllowedProgrammes();
                }
                return _allowedProgramme;
            }
            set
            {
                _allowedProgramme = value;
            }
        }

        [ScriptIgnore]
        public IEnumerable<Programme> AvailableProgrammes
        {
            get
            {
                if (_availableProgramme == null)
                {
                    _availableProgramme = _dataContext.User.ListAvailableProgrammes();
                }
                return _availableProgramme;
            }
            set
            {
                _availableProgramme = value;
            }
        }

        public bool CanEditProgramme(int progId)
        {
            return IsProgrammeOperationAllowed(EditKey, progId);
        }

        public bool CanViewProgramme(int progId)
        {
            return IsProgrammeOperationAllowed(ViewKey, progId);
        }

        public bool AllowAdd()
        {
            return IsProgrammeOperationAllowed(AddKey);
        }

        public bool AllowEdit()
        {
            return IsProgrammeOperationAllowed(EditKey);
        }

        public bool AllowMarketInput()
        {
            return IsProgrammeOperationAllowed(MarketInputKey);
        }

        public bool AllowPublish()
        {
            return IsProgrammeOperationAllowed(PublishKey);
        }


        public bool IsAllowedAdminSection(string section = null)
        {
            if (this.IsAdmin)
                return true;

            if (section == null)
            {
                return Permissions.Any(p => p.ObjectType.StartsWith(AdminKey));
            }
            else
            {
                return Permissions.Any(p => p.ObjectType == section && p.Operation == AccessKey);
            }
        }

        public IEnumerable<Permission> AllowedAdminSection(string section = null)
        {

            if (section == null)
                return Permissions.Where(p => p.ObjectType.StartsWith(AdminKey));
            else
                return Permissions.Where(p => p.ObjectType == section && p.Operation == AccessKey);
        }

        public List<string> AvailableAdminSection()
        {
            List<string> availSection = _dataContext.User.ListAvailableAdminSections().ToList();
            if (Permissions != null)
            {
                IEnumerable<Permission> allowedSection = Permissions.Where(p => p.ObjectType.StartsWith(AdminKey));
                List<string> retVal = new List<string>();

                foreach (string section in availSection)
                {
                    if (allowedSection.Where(p => p.ObjectType == section).Count() == 0)
                        retVal.Add(section);
                }

                return retVal;
            }
            else
            {
                return availSection;
            }
        }

        public bool IsAllowedReport(string report = null)
        {
            if (this.IsAdmin)
                return true;

            if (string.IsNullOrEmpty(report))
            {
                return Permissions.Any(p => p.ObjectType.StartsWith(ReportKey));
            }
            else
            {
                return Permissions.Any(p => p.ObjectType == report && p.Operation == ViewKey);
            }
        }

        public IEnumerable<Permission> AllowedReportSection(string report)
        {

            if (string.IsNullOrEmpty(report))
                return Permissions.Where(p => p.ObjectType.StartsWith(ReportKey));
            else
                return Permissions.Where(p => p.ObjectType == report && p.Operation == ViewKey);
        }

        public List<string> ListAvailableReports()
        {
            List<string> availSection = _dataContext.User.ListAvailableReports().ToList();
            if (Permissions != null)
            {
                IEnumerable<Permission> allowedSection = Permissions.Where(p => p.ObjectType.StartsWith(ReportKey));
                List<string> retVal = new List<string>();

                foreach (string section in availSection)
                {
                    if (allowedSection.Where(p => p.ObjectType == section).Count() == 0)
                        retVal.Add(section);
                }

                return retVal;
            }
            else
            {
                return availSection;
            }
        }

        private bool IsProgrammeOperationAllowed(string operationKey)
        {
            bool retVal = false;
            if (Permissions == null)
                return retVal;

            retVal = Permissions.Any(p => p.ObjectType == ProgrammeKey && p.Operation == operationKey);

            return retVal;
        }

        private bool IsProgrammeOperationAllowed(string operationKey, int? progId)
        {
            bool retVal = false;
            if (Permissions == null)
                return retVal;

            retVal = Permissions.Any(p => p.ObjectType == ProgrammeKey && 
                                     p.Operation == operationKey &&
                                     p.ObjectId == progId);

            return retVal;
        }
    }

}