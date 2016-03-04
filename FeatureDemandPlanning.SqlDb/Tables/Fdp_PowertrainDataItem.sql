CREATE TABLE [dbo].[Fdp_PowertrainDataItem] (
    [FdpPowertrainDataItemId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Fdp_PowertrainDataItem_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_PowertrainDataItem_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NOT NULL,
    [FdoOxoDerivativeId]      INT            NULL,
    [FdpDerivativeId]         INT            NULL,
    [Volume]                  INT            CONSTRAINT [DF_Fdp_PowertrainDataItem_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]      DECIMAL (5, 4) CONSTRAINT [DF_Fdp_PowertrainDataItem_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_PowertrainDataItem] PRIMARY KEY CLUSTERED ([FdpPowertrainDataItemId] ASC),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_Fdp_Derivative] FOREIGN KEY ([FdpDerivativeId]) REFERENCES [dbo].[Fdp_Derivative] ([FdpDerivativeId]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_Fdp_OxoDervivative] FOREIGN KEY ([FdoOxoDerivativeId]) REFERENCES [dbo].[Fdp_OxoDervivative] ([FdpOxoDervivativeId]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);




GO
CREATE TRIGGER [dbo].[tr_Fdp_PowertrainDataItem_Audit] ON dbo.Fdp_PowertrainDataItem FOR UPDATE
AS
	DECLARE @Type AS CHAR(1);
	
	-- Put the old "deleted" values into the audit as the primary table contains the new record values

	INSERT INTO Fdp_PowertrainDataItemAudit
	(
		  AuditOn
		, AuditBy
		, FdpPowertrainDataItemId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  ISNULL(ISNULL(D.UpdatedOn, D.CreatedOn), GETDATE())
		, ISNULL(ISNULL(D.UpdatedBy, D.CreatedBy), SUSER_SNAME())
		, D.FdpPowertrainDataItemId
		, D.Volume
		, D.PercentageTakeRate
		
	FROM deleted	AS D
	JOIN inserted	AS I ON D.FdpPowertrainDataItemId = I.FdpPowertrainDataItemId