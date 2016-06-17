CREATE TABLE [dbo].[Fdp_VolumeDataItem] (
    [FdpVolumeDataItemId]         INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]                   DATETIME       CONSTRAINT [DF_Fdp_VolumeDataItem_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                   NVARCHAR (16)  NULL,
    [FdpVolumeHeaderId]           INT            NOT NULL,
    [IsManuallyEntered]           BIT            CONSTRAINT [DF_Fdp_VolumeDataItem_IsManuallyEntered] DEFAULT ((1)) NOT NULL,
    [MarketId]                    INT            NULL,
    [MarketGroupId]               INT            NULL,
    [ModelId]                     INT            NULL,
    [FdpModelId]                  INT            NULL,
    [TrimId]                      INT            NULL,
    [FdpTrimId]                   INT            NULL,
    [FeatureId]                   INT            NULL,
    [FdpFeatureId]                INT            NULL,
    [FeaturePackId]               INT            NULL,
    [Volume]                      INT            CONSTRAINT [DF_Fdp_VolumeDataItem_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]          DECIMAL (5, 4) CONSTRAINT [DF_Fdp_VolumeDataItem_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]                   DATETIME       NULL,
    [UpdatedBy]                   NVARCHAR (16)  NULL,
    [OriginalFdpVolumeDataItemId] INT            NULL,
    CONSTRAINT [PK_Fdp_VolumeDataItem] PRIMARY KEY CLUSTERED ([FdpVolumeDataItemId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Fdp_VolumeDataItem_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Programme_Model] FOREIGN KEY ([ModelId]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Programme_Pack] FOREIGN KEY ([FeaturePackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);


























GO







GO



GO



GO



GO
CREATE TRIGGER [dbo].[tr_Fdp_TakeRateDataItem_Audit] ON [dbo].[Fdp_VolumeDataItem] FOR UPDATE
AS
	DECLARE @Type AS CHAR(1);
	
	-- Put the old "deleted" values into the audit as the primary table contains the new record values

	INSERT INTO Fdp_TakeRateDataItemAudit
	(
		  AuditOn
		, AuditBy
		, FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  ISNULL(ISNULL(D.UpdatedOn, D.CreatedOn), GETDATE())
		, ISNULL(ISNULL(D.UpdatedBy, D.CreatedBy), SUSER_SNAME())
		, D.FdpVolumeHeaderId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		
	FROM deleted	AS D
GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_VolumeDataItem_MarketModelAndFeature]
    ON [dbo].[Fdp_VolumeDataItem]([FdpVolumeHeaderId] ASC, [MarketId] ASC, [ModelId] ASC, [FeatureId] ASC, [FeaturePackId] ASC, [OriginalFdpVolumeDataItemId] ASC)
    INCLUDE([CreatedBy], [CreatedOn], [FdpFeatureId], [FdpModelId], [FdpTrimId], [FdpVolumeDataItemId], [IsManuallyEntered], [MarketGroupId], [PercentageTakeRate], [TrimId], [UpdatedBy], [UpdatedOn], [Volume]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_VolumeDataItem_FeatureModelAndMarket]
    ON [dbo].[Fdp_VolumeDataItem]([FdpVolumeHeaderId] ASC, [FeatureId] ASC, [FeaturePackId] ASC, [ModelId] ASC, [MarketId] ASC, [OriginalFdpVolumeDataItemId] ASC)
    INCLUDE([CreatedBy], [CreatedOn], [FdpFeatureId], [FdpModelId], [FdpTrimId], [FdpVolumeDataItemId], [IsManuallyEntered], [MarketGroupId], [PercentageTakeRate], [TrimId], [UpdatedBy], [UpdatedOn], [Volume]) WITH (FILLFACTOR = 90);

