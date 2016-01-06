using System.ComponentModel.DataAnnotations;

namespace FeatureDemandPlanning.Model
{
    public enum ProgrammFileCategory
    {
        Upload,
        Publish
    }

    public class OXOProgrammeFile : BusinessObject
    {
        public int ProgrammeId { get; set; }

        public string VehicleName { get; set; }
        public string ModelYear { get; set; }
        public string FileCategory { get; set; }
        public string FileComment { get; set; }
        public string FileName { get; set; }
        public string FileExt { get; set; }
        public string FileDesc { get; set; }
        public string FileType { get; set; }
        public int FileSize { get; set; }
        public string Gateway { get; set; }
        public string PACN { get; set; }

        [Required]
        public byte[] FileContent { get; set; }
        public string UploadedBy { get; set; }
        public string DateUploaded { get; set; }
           
        // A blank constructor
        public OXOProgrammeFile() {;}
    }
}