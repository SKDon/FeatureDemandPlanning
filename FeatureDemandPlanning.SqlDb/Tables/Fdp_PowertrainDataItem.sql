CREATE TABLE [dbo].[Fdp_PowertrainDataItem] (
    [FdpPowertrainDataItemId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Fdp_PowertrainDataItem_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_PowertrainDataItem_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NOT NULL,
    [BodyId]                  INT            NOT NULL,
    [EngineId]                INT            NOT NULL,
    [TransmissionId]          INT            NOT NULL,
    [Volume]                  INT            CONSTRAINT [DF_Fdp_PowertrainDataItem_Volume] DEFAULT ((0)) NOT NULL,
    [PercentageTakeRate]      DECIMAL (5, 4) CONSTRAINT [DF_Fdp_PowertrainDataItem_PercentageTakeRate] DEFAULT ((0)) NOT NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_PowertrainDataItem] PRIMARY KEY CLUSTERED ([FdpPowertrainDataItemId] ASC),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_OXO_Programme_Body] FOREIGN KEY ([BodyId]) REFERENCES [dbo].[OXO_Programme_Body] ([Id]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_OXO_Programme_Engine] FOREIGN KEY ([EngineId]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id]),
    CONSTRAINT [FK_Fdp_PowertrainDataItem_OXO_Programme_Transmission] FOREIGN KEY ([TransmissionId]) REFERENCES [dbo].[OXO_Programme_Transmission] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_PowertrainDataItem]
    ON [dbo].[Fdp_PowertrainDataItem]([FdpVolumeHeaderId] ASC, [MarketId] ASC, [BodyId] ASC, [EngineId] ASC, [TransmissionId] ASC);

