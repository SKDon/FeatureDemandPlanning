using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IEmailDataContext 
    {
        EmailTemplate GetEmailTemplate(EmailEvent forEmailEvent);
    }
}
