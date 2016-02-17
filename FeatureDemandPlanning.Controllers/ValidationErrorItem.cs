namespace FeatureDemandPlanning.Controllers
{
    public class ValidationErrorItem
    {
        public string ErrorMessage { get; set; }
        public object CustomState { get; set; }

        public ValidationErrorItem()
        {

        }

        public ValidationErrorItem(string errorMessage, object customState)
        {
            ErrorMessage = errorMessage;
            CustomState = customState;
        }
    }
}
