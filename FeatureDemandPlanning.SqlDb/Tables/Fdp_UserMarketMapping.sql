CREATE TABLE [dbo].[Fdp_UserMarketMapping] (
    [FdpUserMarketMappingId] INT IDENTITY (1, 1) NOT NULL,
    [FdpUserId]              INT NOT NULL,
    [MarketId]               INT NOT NULL,
    [FdpUserActionId]        INT NOT NULL,
    [IsActive]               INT NOT NULL,
    CONSTRAINT [PK_Fdp_UserMarketMapping] PRIMARY KEY CLUSTERED ([FdpUserMarketMappingId] ASC),
    CONSTRAINT [FK_Fdp_UserMarketMapping_Fdp_User] FOREIGN KEY ([FdpUserId]) REFERENCES [dbo].[Fdp_User] ([FdpUserId]),
    CONSTRAINT [FK_Fdp_UserMarketMapping_Fdp_UserAction] FOREIGN KEY ([FdpUserActionId]) REFERENCES [dbo].[Fdp_UserAction] ([FdpUserActionId]),
    CONSTRAINT [FK_Fdp_UserMarketMapping_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);

