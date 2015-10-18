CREATE TABLE [dbo].[Fdp_MarketMapping] (
    [FdpMarketMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [ImportMarket]       NVARCHAR (50) NOT NULL,
    [MappedMarket]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Fdp_MarketMapping] PRIMARY KEY CLUSTERED ([FdpMarketMappingId] ASC)
);

