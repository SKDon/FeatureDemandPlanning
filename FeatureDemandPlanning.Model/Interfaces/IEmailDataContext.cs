using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.BusinessObjects;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IEmailDataContext 
    {
        IEnumerable<EmailTemplate> ListEmailTemplates();
        EmailTemplate GetEmailTemplate(string emailEvent);
        bool SaveTemplate(EmailTemplate templateToSave);
    }
}
