CREATE TABLE [dbo].[Fdp_ValidationIgnore] (
    [FdpValidationIgnoreId] INT            IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId]     INT            NOT NULL,
    [MarketId]              INT            NOT NULL,
    [Message]               NVARCHAR (MAX) NOT NULL,
    [IsActive]              BIT            CONSTRAINT [DF_Fdp_ValidationIgnore_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_ValidationIgnore] PRIMARY KEY CLUSTERED ([FdpValidationIgnoreId] ASC),
    CONSTRAINT [FK_Fdp_ValidationIgnore_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_ValidationIgnore_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_ValidationIgnore_Cover]
    ON [dbo].[Fdp_ValidationIgnore]([FdpVolumeHeaderId] ASC, [MarketId] ASC)
    INCLUDE([Message]);

