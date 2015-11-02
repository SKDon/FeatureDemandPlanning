using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;
using OXO.BusinessObjects;

namespace OXO
{
    public class GreaterThanEqualToAttribute : ValidationAttribute, IClientValidatable 
    {
        public GreaterThanEqualToAttribute(string otherProperty)
            : base("{0} must be greater than or equal to {1}")
        {
            OtherProperty = otherProperty;
        }

        public string OtherProperty { get; set; }

        public override string FormatErrorMessage(string name)
        {
            return string.Format(ErrorMessageString, name, OtherProperty);
        }

        protected override ValidationResult IsValid(object firstValue, ValidationContext validationContext)
        {
            //for now always return success    
            //var firstComparable = firstValue as IComparable;
            //var secondComparable = GetSecondComparable(validationContext);

            //if (firstComparable != null && secondComparable != null)
            //{
            //    if (firstComparable.CompareTo(secondComparable) < 0)
            //    {
            //        return new ValidationResult(
            //            FormatErrorMessage(validationContext.DisplayName));
            //    }
            //}

            return ValidationResult.Success;
        }

        protected IComparable GetSecondComparable(ValidationContext validationContext)
        {
            var propertyInfo = validationContext.ObjectType.GetProperty(OtherProperty);
            if (propertyInfo != null)
            {
                var secondValue = propertyInfo.GetValue(
                    validationContext.ObjectInstance, null);
                return secondValue as IComparable;
            }
            return null;
        }

        protected string GetOtherDisplayName(ValidationContext validationContext)
        {
            var metadata = ModelMetadataProviders.Current.GetMetadataForProperty(
                null, validationContext.ObjectType, OtherProperty);
            if (metadata != null)
            {
                return metadata.GetDisplayName();
            }
            return OtherProperty;
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule();
            rule.ErrorMessage = FormatErrorMessage(metadata.GetDisplayName());
            rule.ValidationParameters.Add("other", OtherProperty);
            rule.ValidationType = "greaterthanequalto";
            yield return rule;
        }


    }

    public class CustomTaskPreferenceAttribute : ValidationAttribute, IClientValidatable
    {
        public CustomTaskPreferenceAttribute() : base("Please specify a completed {0}") { ; }

        public override string FormatErrorMessage(string name)
        {
            return string.Format(ErrorMessageString, name);
        }

        protected override ValidationResult IsValid(object firstValue, ValidationContext validationContext)
        {
            var firstComparable = firstValue as IComparable;
            return ValidationResult.Success; // return true for now.
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule();
            rule.ErrorMessage = FormatErrorMessage(metadata.GetDisplayName());
            rule.ValidationType = "test";
            yield return rule;
        }


    }

    public class WorkingDayAttribute : ValidationAttribute, IClientValidatable
    {
        public WorkingDayAttribute() : base("Please specify a working day") { ; }

        public override string FormatErrorMessage(string name)
        {
            return string.Format(ErrorMessageString, name);
        }

        protected override ValidationResult IsValid(object dateValue, ValidationContext validationContext)
        {
            return ValidationResult.Success; // return true for now.
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule();
            rule.ErrorMessage = FormatErrorMessage(metadata.GetDisplayName());
            rule.ValidationType = "testworkingday";
            yield return rule;
        }
    }

    public class FutureDateAttribute : ValidationAttribute, IClientValidatable
    {
        public FutureDateAttribute() : base("Please specify a future day") { ; }

        public override string FormatErrorMessage(string name)
        {
            return string.Format(ErrorMessageString, name);
        }

        protected override ValidationResult IsValid(object dateValue, ValidationContext validationContext)
        {
            return ValidationResult.Success; // return true for now.
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule();
            rule.ErrorMessage = FormatErrorMessage(metadata.GetDisplayName());
            rule.ValidationType = "testfuturedate";
            yield return rule;
        }
    }

    public class ExistingUserAttribute : ValidationAttribute
    {
        public ExistingUserAttribute() : base("CDSID is not a registered user with VIC system") { ; }

        public override string FormatErrorMessage(string name)
        {
            return string.Format(ErrorMessageString, name);
        }

        protected override ValidationResult IsValid(object cdsid, ValidationContext validationContext)
        {
            if (cdsid != null)
            {
                SystemUserDS ds = new SystemUserDS("system");
                SystemUser user = ds.SystemUserGet(cdsid.ToString(), true);
                if (user != null)
                {
                    return ValidationResult.Success;
                }
                else
                {
                    return new ValidationResult(
                        FormatErrorMessage(validationContext.DisplayName));
                }
            }
            else
                return ValidationResult.Success;
        }
        
    }

}