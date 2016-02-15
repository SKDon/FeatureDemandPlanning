using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class EmailDataContext : BaseDataContext, IEmailDataContext
    {
        private readonly EmailTemplateDataStore _templateData;

        public EmailDataContext(string cdsId) : base(cdsId)
        {
            _templateData = new EmailTemplateDataStore(cdsId);
        }
        public EmailTemplate GetEmailTemplate(EmailEvent forEmailEvent)
        {
            return _templateData.EmailTemplateGet(forEmailEvent);
        }
    }
}
