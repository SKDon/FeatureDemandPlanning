using System;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateDocumentHeader
    {
        public int? FdpVolumeHeaderId { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public bool IsManuallyEntered { get; set; }
        public int? FdpImportId { get; set; }
        public string ImportFilePath { get; set; }
        public Vehicle Vehicle { get; set; }

        // These properties will be consumed when the Vehicle property is hydrated and are needed when returning results from the database

        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public override string ToString()
        {
            return string.Format("{0:dd/MM/yyyy} - {1}", CreatedOn, Vehicle.FullDescription);
        }
    }
}
