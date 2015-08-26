using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net.Mail;
using System.Reflection;
using System.Collections;
using System.Configuration;
using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Model.RADSMailService;
using FeatureDemandPlanning.Interfaces;

namespace FeatureDemandPlanning.Helpers
{
    public enum EmailEvent
    {
        RuleAdded,
        RuleChange,
        FeatureAdded,
        Error
    };

    public static class EmailHelper 
    {
        private static readonly string smtpServer = "smtprelay.jlrint.com";
        private static readonly int smtpServerPort = 25;

        public static bool SendEmail(IDataContext dataContext, EmailEvent emailEvent, EmailInfo emailInfo)
        {
            bool retVal = true;
            string subject = "";
            string bodyText = "";

            MailAddress from = new MailAddress(emailInfo.AddressFrom);
            MailAddress to = new MailAddress(emailInfo.AddressTo);
           
            SetBodyText(dataContext, emailEvent, emailInfo.Payload, ref subject, ref bodyText);           
           
            MailMessage message = new MailMessage(from, to);
            message.Subject = subject;
            message.Body = bodyText;

            SmtpClient client = new SmtpClient(smtpServer);         
            client.Port = smtpServerPort;        
            try
            {
                client.Send(message);
            }
            catch (Exception ex)
            {
                retVal = false;
                AppHelper.LogError("EmailHelper.SendEmail", ex.Message, "SYSTEM");
            }

            return retVal;
        }

        public static bool SendEmailViaWS(IDataContext dataContext, EmailEvent emailEvent, EmailInfo emailInfo)
        {
            bool retVal = true;
            string subject = "";
            string bodyText = "";

            try
            {
                switch (emailEvent)
                {
                    default:
                        // call general mapping
                        SetBodyText(dataContext, emailEvent, emailInfo.Payload, ref subject, ref bodyText);
                        break;
                }

                string sendEmail = ConfigurationManager.AppSettings["SendEmail"];
                if (String.IsNullOrEmpty(sendEmail) || Boolean.Parse(sendEmail))
                {
                    //using these two lines only in dev.
                    JLRCommonHeader commonHeader = new JLRCommonHeader();
                    commonHeader.NullMessage = "0";
                    AuthHeader credentials = new AuthHeader();
                    credentials.UserName = "fromradsonly";
                    credentials.Password = "0a8b3772-094a-4cd9-a379-2464d3bec56b";
                    SendMailSoapClient webservice = new SendMailSoapClient();
                    string reply = webservice.SendMailRequest(commonHeader, credentials, emailInfo.AddressFrom, emailInfo.AddressTo, subject, bodyText, (emailInfo.AddressCC == null ? "" : emailInfo.AddressCC), "", "VICBooker");
                }
            }
            catch (Exception ex)
            {
                retVal = false;
                AppHelper.LogError("EmailHelper.SendEmailViaWS", ex.Message, "SYSTEM");
            }

            return retVal;
        }

        private static void SetBodyText(IDataContext dataContext, EmailEvent emailEvent, object payLoad,ref string subjectText,ref string bodyText)
        {
            
            try
            {
                EmailTemplate template = dataContext.Email.GetEmailTemplate(emailEvent.ToString());
                if (template != null)
                {
                    subjectText = "" + template.Subject;
                    bodyText = "" + template.Body; 
                }

                MapPropertyToPlaceHolder(payLoad,ref subjectText,ref bodyText);
            }
            catch (Exception ex)
            {
                AppHelper.LogError("EmailHelper.SetBodyText", ex.Message, "SYSTEM");
            }
     
        }

        
        
       
        private static void MapPropertyToPlaceHolder(object payLoad,ref string subject,ref string bodyText)
        {
            var payLoadType = payLoad.GetType();

            try
            {
                foreach (PropertyInfo propertyInfo in payLoadType.GetProperties())
                {
                    // do stuff here
                    string placeHolder = string.Format("#{0}#", propertyInfo.Name);
                    var value = propertyInfo.GetValue(payLoad, null);
                    if (value != null)
                    {
                        subject = subject.Replace(placeHolder, value.ToString());
                        bodyText = bodyText.Replace(placeHolder, value.ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                AppHelper.LogError("EmailHelper.MapPropertyToPlaceHolder", ex.Message, "SYSTEM");
            }
        }
    }
}