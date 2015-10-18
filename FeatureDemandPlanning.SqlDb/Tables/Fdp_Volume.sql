CREATE TABLE [dbo].[Fdp_Volume] (
    [FdpVolumeId]       INT IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId] INT NOT NULL,
    [IsManuallyEntered] BIT CONSTRAINT [DF_Fdp_Volume_IsManuallyEntered] DEFAULT ((0)) NOT NULL,
    [MarketId]          INT NOT NULL,
    [MarketGroupId]     INT NULL,
    [ModelId]           INT NOT NULL,
    [TrimId]            INT NOT NULL,
    [EngineId]          INT NOT NULL,
    [Volume]            INT NOT NULL,
    CONSTRAINT [PK_Fdp_Volume] PRIMARY KEY CLUSTERED ([FdpVolumeId] ASC),
    CONSTRAINT [FK_Fdp_Volume_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_Volume_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_Volume_OXO_Master_MarketGroup] FOREIGN KEY ([MarketGroupId]) REFERENCES [dbo].[OXO_Programme_MarketGroup] ([Id]),
    CONSTRAINT [FK_Fdp_Volume_OXO_Programme_Engine] FOREIGN KEY ([EngineId]) REFERENCES [dbo].[OXO_Programme_Engine] ([Id]),
    CONSTRAINT [FK_Fdp_Volume_OXO_Programme_Model] FOREIGN KEY ([ModelId]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_Fdp_Volume_OXO_Programme_Trim] FOREIGN KEY ([TrimId]) REFERENCES [dbo].[OXO_Programme_Trim] ([Id])
);

