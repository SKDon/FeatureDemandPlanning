using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;

namespace FeatureDemandPlanning.DataStore
{
    public class EmailDataContext : BaseDataContext, IEmailDataContext
    {
        private EmailTemplateDS _templateData = null;

        public EmailDataContext(string cdsid) : base(cdsid)
        {
            _templateData = new EmailTemplateDS(cdsid);
        }

        public IEnumerable<BusinessObjects.EmailTemplate> ListEmailTemplates()
        {
            return _templateData.EmailTemplateGetMany();
        }

        public BusinessObjects.EmailTemplate GetEmailTemplate(string emailEvent)
        {
            return _templateData.EmailTemplateGet(emailEvent);
        }

        public bool SaveTemplate(BusinessObjects.EmailTemplate templateToSave)
        {
            return _templateData.EmailTemplateSave(templateToSave);
        }
    }
}
