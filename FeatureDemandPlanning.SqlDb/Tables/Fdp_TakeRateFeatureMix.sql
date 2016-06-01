CREATE TABLE [dbo].[Fdp_TakeRateFeatureMix] (
    [FdpTakeRateFeatureMixId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Fdp_TakeRateFeatureMix_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (25)  CONSTRAINT [DF_Fdp_TakeRateFeatureMix_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NULL,
    [FeatureId]               INT            NULL,
    [FdpFeatureId]            INT            NULL,
    [FeaturePackId]           INT            NULL,
    [Volume]                  INT            CONSTRAINT [DF_Fdp_TakeRateFeatureMix_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]      DECIMAL (5, 4) CONSTRAINT [DF_Fdp_TakeRateFeatureMix_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    [FeatureIdentifier]       AS             (case when [FeatureId] IS NOT NULL then 'O'+CONVERT([nvarchar](10),[FeatureId],0) else 'P'+CONVERT([nvarchar](10),[FeaturePackId],0) end) PERSISTED,
    CONSTRAINT [PK_Fdp_TakeRateFeatureMix] PRIMARY KEY CLUSTERED ([FdpTakeRateFeatureMixId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_TakeRateFeatureMix_Fdp_Feature] FOREIGN KEY ([FdpFeatureId]) REFERENCES [dbo].[Fdp_Feature] ([FdpFeatureId]),
    CONSTRAINT [FK_Fdp_TakeRateFeatureMix_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_TakeRateFeatureMix_OXO_Programme_Pack] FOREIGN KEY ([FeaturePackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);






GO

CREATE TRIGGER [dbo].[tr_Fdp_TakeRateFeatureMix_Audit] ON [dbo].[Fdp_TakeRateFeatureMix] FOR UPDATE
AS
	DECLARE @Type AS CHAR(1);
	
	-- Put the old "deleted" values into the audit as the primary table contains the new record values

	INSERT INTO Fdp_TakeRateFeatureMixAudit
	(
		  AuditOn
		, AuditBy
		, FdpTakeRateFeatureMixId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  ISNULL(ISNULL(D.UpdatedOn, D.CreatedOn), GETDATE())
		, ISNULL(ISNULL(D.UpdatedBy, D.CreatedBy), SUSER_SNAME())
		, D.FdpTakeRateFeatureMixId
		, D.Volume
		, D.PercentageTakeRate
		
	FROM deleted	AS D
	JOIN inserted	AS I ON D.FdpTakeRateFeatureMixId = I.FdpTakeRateFeatureMixId
GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_TakeRateFeatureMix_Cover]
    ON [dbo].[Fdp_TakeRateFeatureMix]([FdpVolumeHeaderId] ASC, [MarketId] ASC, [FeatureId] ASC, [FdpFeatureId] ASC, [FeaturePackId] ASC, [FeatureIdentifier] ASC)
    INCLUDE([PercentageTakeRate], [Volume]) WITH (FILLFACTOR = 90);

