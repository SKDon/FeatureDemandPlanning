using System;
using System.Collections.Generic;
using System.Reflection;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using RADsHelpers.Helpers;
using RADsHelpers.DataAccess;
using RADsHelpers.BusinessObjects;
using log4net;

namespace FeatureDemandPlanning.Helpers
{
    public class EmailParameters
    {
        public string Subject { get; set; }
        public string BodyText { get; set; }
        public EmailEvent EmailEvent { get; set; }
        public EmailInfo EmailInfo { get; set; }

        public EmailParameters()
        {
            Subject = string.Empty;
            BodyText = string.Empty;
            EmailEvent = EmailEvent.NotSet;
            EmailInfo = new EmailInfo();
        }
    }
    public static class EmailHelper
    {
        public static bool SendEmail(EmailParameters parameters,
                                     IDataContext context)
        {
            var retVal = true;

            SetBodyText(parameters, context);
            try
            {
                var addresses = new List<QueueEmailAddress>();
                var email = new QueueEmail();
                var fromAddr = new QueueEmailAddress
                {
                    AddressType = EmailType.From.ToString(),
                    EmailAddress = parameters.EmailInfo.AddressFrom
                };
                addresses.Add(fromAddr);

                var toAddr = new QueueEmailAddress
                {
                    AddressType = EmailType.To.ToString(),
                    EmailAddress = parameters.EmailInfo.AddressTo
                };
                addresses.Add(toAddr);

                if (!string.IsNullOrEmpty(parameters.EmailInfo.AddressCC))
                {
                    var ccAddr = new QueueEmailAddress
                    {
                        AddressType = EmailType.CC.ToString(),
                        EmailAddress = parameters.EmailInfo.AddressCC
                    };
                    addresses.Add(ccAddr);
                }

                email.Subject = parameters.Subject;
                email.Body = parameters.BodyText;
                email.Addresses = addresses;
                email.App = Application;
                email.CreatedBy = context.CurrentCDSId;

                QueueEmailData.Send(email, context.CurrentCDSId);
            }
            catch (Exception ex)
            {
                retVal = false;
                Log.Error(ex);
            }

            return retVal;
        }

        private static void SetBodyText(EmailParameters parameters, IDataContext context)
        {
            try
            {
                var template = context.Email.GetEmailTemplate(parameters.EmailEvent);
                if (template != null)
                {
                    parameters.Subject = "" + template.Subject;
                    parameters.BodyText = "" + template.Body;
                }
                MapPropertyToPlaceHolder(parameters);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }
        private static void MapPropertyToPlaceHolder(EmailParameters parameters)
        {
            try
            {
                foreach (var currentPayload in parameters.EmailInfo.Payload)
                {
                    MapPropertyToPlaceHolder(parameters, currentPayload);
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }
        private static void MapPropertyToPlaceHolder(EmailParameters parameters, object forPayload)
        {
            var payLoadType = forPayload.GetType();
            if (!payLoadType.Name.Equals("TakeRateSummary")) return;

            foreach (var propertyInfo in payLoadType.GetProperties())
            {
                MapPropertyToPlaceHolder(parameters, forPayload, propertyInfo);
            }
        }
        private static void MapPropertyToPlaceHolder(EmailParameters parameters, object forPayload,
            PropertyInfo propertyInfo)
        {
            var placeHolder = string.Format("#{0}#", propertyInfo.Name);
            var value = propertyInfo.GetValue(forPayload, null);
            if (value != null)
            {
                parameters.Subject = parameters.Subject.Replace(placeHolder, value.ToString());
                parameters.BodyText = parameters.BodyText.Replace(placeHolder, value.ToString());
            }
            else
            {
                parameters.Subject = parameters.Subject.Replace(placeHolder, "N/A");
                parameters.BodyText = parameters.BodyText.Replace(placeHolder, "N/A");
            }
        }

        private const string Application = "FDP";
        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}