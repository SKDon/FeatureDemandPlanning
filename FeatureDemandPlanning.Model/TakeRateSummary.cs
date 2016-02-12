﻿using System;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateSummary
    {
        public int TakeRateId { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public int OxoDocId { get; set; }
        public string OxoDocument { get; set; }

        public int FdpTakeRateStatusId { get; set; }
        public string Status { get; set; }
        public string StatusDescription { get; set; }

        public string Version { get; set; }
        public bool IsCompleted { get; set; }

        public MarketReview MarketReview { get; set; }

        public string[] ToJQueryDataTableResult()
        {
            return new[] 
            { 
                TakeRateId.ToString(),
                CreatedOn.ToString("dd/MM/yyyy"),
                CreatedBy,
                OxoDocument,
                Version,
                Status,
                UpdatedOn.HasValue ? UpdatedOn.Value.ToString("dd/MM/yyyy HH:mm") : "-",
                !string.IsNullOrEmpty(UpdatedBy) ? UpdatedBy : "-",
                //OxoDocId.ToString(),
                IsCompleted.ToString()
            };
        }
        public bool IsPublished()
        {
            return ((Enumerations.TakeRateStatus) FdpTakeRateStatusId) == Enumerations.TakeRateStatus.Published;
        }
    }
}
