using FeatureDemandPlanning.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ProcessState
    {
        #region "Public Properties"

        public ProcessStatus Status { get; set; }
        public IList<string> Messages { get; set; }
        public ApplicationException Exception { get; set; }

        #endregion

        #region "Constructors"

        public ProcessState()
        {
            Status = ProcessStatus.Success;
            Messages = new List<string>();
        }

        public ProcessState(ProcessStatus status)
        {
            Status = status;
            Messages = new List<string>();
        }

        public ProcessState(ProcessStatus status, params string[] statusMessages) : this(status)
        {
            Messages = statusMessages.ToList<string>();
        }

        public ProcessState(ApplicationException ex) : this(ProcessStatus.Failure)
        {
            Exception = ex;
            AddMessage(ex.Message);
        }

        #endregion

        #region "Public Methods"

        public static ProcessState FromException(string message, ApplicationException ex)
        {
            var state = new ProcessState(ex);
            state.Messages = new List<string>() { message };

            return state;
        }

        public void AddMessage(string message)
        {
            Messages.Add(message);
        }

        #endregion
    }
}
