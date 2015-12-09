CREATE TABLE [dbo].[Fdp_TakeRateSummary] (
    [FdpTakeRateSummaryId]       INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]                  DATETIME      CONSTRAINT [DF_Fdp_TakeRateSummary_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                  NVARCHAR (25) CONSTRAINT [DF_Fdp_TakeRateSummary_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]          INT           NOT NULL,
    [FdpSpecialFeatureMappingId] INT           NOT NULL,
    [MarketId]                   INT           NULL,
    [ModelId]                    INT           NULL,
    [FdpModelId]                 INT           NULL,
    [Volume]                     INT           CONSTRAINT [DF_Fdp_TakeRateSummary_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]         INT           CONSTRAINT [DF_Fdp_TakeRateSummary_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]                  DATETIME      NULL,
    [UpdatedBy]                  NVARCHAR (16) NULL,
    CONSTRAINT [PK_Fdp_TakeRateSummary] PRIMARY KEY CLUSTERED ([FdpTakeRateSummaryId] ASC)
);




GO
CREATE TRIGGER [dbo].[tr_Fdp_TakeRateSummary_Audit] ON [dbo].[Fdp_TakeRateSummary] FOR UPDATE
AS
	DECLARE @Type AS CHAR(1);
	
	-- Put the old "deleted" values into the audit as the primary table contains the new record values

	INSERT INTO Fdp_TakeRateSummaryAudit
	(
		  AuditOn
		, AuditBy
		, FdpTakeRateSummaryId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  ISNULL(D.UpdatedOn, D.CreatedOn)
		, ISNULL(D.UpdatedBy, D.CreatedBy)
		, D.FdpTakeRateSummaryId
		, D.Volume
		, D.PercentageTakeRate
		
	FROM deleted	AS D
	JOIN inserted	AS I ON D.FdpTakeRateSummaryId = I.FdpTakeRateSummaryId