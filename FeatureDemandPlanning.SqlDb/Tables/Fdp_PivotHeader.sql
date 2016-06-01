CREATE TABLE [dbo].[Fdp_PivotHeader] (
    [FdpPivotHeaderId]  INT            IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId] INT            NOT NULL,
    [MarketId]          INT            NULL,
    [ModelIds]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Fdp_PivotHeader] PRIMARY KEY CLUSTERED ([FdpPivotHeaderId] ASC),
    CONSTRAINT [FK_Fdp_PivotHeader_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_PivotHeader_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_PivotHeader_Cover]
    ON [dbo].[Fdp_PivotHeader]([FdpVolumeHeaderId] ASC, [MarketId] ASC);

