CREATE TABLE [dbo].[Fdp_TakeRateDataItemAudit] (
    [FdpVolumeDataItemAuditId] INT            IDENTITY (1, 1) NOT NULL,
    [AuditOn]                  DATETIME       NOT NULL,
    [AuditBy]                  NVARCHAR (50)  CONSTRAINT [DF_Fdp_TakeRateDataItemAudit_AuditBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]		   INT			  NOT NULL,
	[MarketId]				   INT			  NOT NULL,
	[ModelId]                  INT            NULL,
    [FdpModelId]               INT            NULL,
    [FeatureId]                INT            NULL,
    [FdpFeatureId]             INT            NULL,
    [FeaturePackId]            INT            NULL,
    [Volume]                   INT            NOT NULL,
    [PercentageTakeRate]       DECIMAL (5, 4) NOT NULL,
    CONSTRAINT [PK_Fdp_VolumeDataItemAudit] PRIMARY KEY CLUSTERED ([FdpVolumeDataItemAuditId] ASC)
);






GO


