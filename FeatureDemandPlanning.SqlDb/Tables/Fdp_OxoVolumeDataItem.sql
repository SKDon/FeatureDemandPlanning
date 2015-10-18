CREATE TABLE [dbo].[Fdp_OxoVolumeDataItem] (
    [FdpOxoVolumeDataItemId] INT            IDENTITY (1, 1) NOT NULL,
    [Section]                NVARCHAR (100) NOT NULL,
    [ModelId]                INT            NOT NULL,
    [FeatureId]              INT            NULL,
    [MarketGroupId]          INT            NULL,
    [MarketId]               INT            NOT NULL,
    [TrimId]                 INT            NOT NULL,
    [FdpOxoDocId]            INT            NOT NULL,
    [Volume]                 INT            NULL,
    [PercentageTakeRate]     DECIMAL (5, 4) NULL,
    [CreatedBy]              NVARCHAR (16)  CONSTRAINT [DF_Fdp_OxoVolumeData_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [CreatedOn]              DATETIME       CONSTRAINT [DF_Fdp_OxoVolumeData_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]              NVARCHAR (16)  NULL,
    [LastUpdated]            DATETIME       NULL,
    [PackId]                 INT            NULL,
    [IsActive]               BIT            CONSTRAINT [DF_Fdp_OxoVolumeDataItem_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_OxoVolumeDataItem] PRIMARY KEY CLUSTERED ([FdpOxoVolumeDataItemId] ASC),
    CONSTRAINT [FK_Fdp_OxoVolumeData_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_OxoVolumeData_OXO_Programme_Model] FOREIGN KEY ([ModelId]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_Fdp_OxoVolumeData_OXO_Programme_Pack] FOREIGN KEY ([PackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id]),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItem_FDP_OXODoc] FOREIGN KEY ([FdpOxoDocId]) REFERENCES [dbo].[Fdp_OxoDoc] ([FdpOxoDocId]),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItem_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItem_OXO_Programme_MarketGroup] FOREIGN KEY ([MarketGroupId]) REFERENCES [dbo].[OXO_Programme_MarketGroup] ([Id]),
    CONSTRAINT [FK_Fdp_OxoVolumeDataItem_OXO_Programme_Trim] FOREIGN KEY ([TrimId]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_OxoVolumeDataItem_ModelId]
    ON [dbo].[Fdp_OxoVolumeDataItem]([ModelId] ASC)
    INCLUDE([FeatureId], [TrimId], [Volume], [FdpOxoDocId], [MarketGroupId], [MarketId]);


GO
CREATE TRIGGER [dbo].[Fdp_OxoVolumeDataItem_Update] ON dbo.Fdp_OxoVolumeDataItem
FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	-- Parent table stores the inserted values, no need to duplicate in the audit

    INSERT INTO Fdp_OxoVolumeDataItemAudit
    (
		  AuditBy
		, AuditOn
		, AuditAction
		, FdpOxoVolumeDataItemId
		, Section
		, ModelId
		, FeatureId
		, MarketGroupId
		, MarketId
		, TrimId
		, FdpOxoDocId
		, Volume
		, PercentageTakeRate
		, CreatedBy
		, CreatedOn
		, UpdatedBy
		, LastUpdated
		, PackId
		, IsActive
    )
    SELECT 
		  I.UpdatedBy
		, I.LastUpdated
		, 'UPDATE'
		, D.FdpOxoVolumeDataItemId
		, D.Section
		, D.ModelId
		, D.FeatureId
		, D.MarketGroupId
		, D.MarketId
		, D.TrimId
		, D.FdpOxoDocId
		, D.Volume
		, D.PercentageTakeRate
		, D.CreatedBy
		, D.CreatedOn
		, D.UpdatedBy
		, D.LastUpdated
		, D.PackId
		, D.IsActive
    FROM
    DELETED AS D
    JOIN INSERTED AS I ON D.FdpOxoVolumeDataItemId = I.FdpOxoVolumeDataItemId

END
