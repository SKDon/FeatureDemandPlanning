using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IEmailDataContext 
    {
        IEnumerable<EmailTemplate> ListEmailTemplates();
        EmailTemplate GetEmailTemplate(string emailEvent);
        bool SaveTemplate(EmailTemplate templateToSave);
    }
}
