CREATE TABLE [dbo].[Fdp_MarketMapping] (
    [FdpMarketMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedOn]          DATETIME      CONSTRAINT [DF_Fdp_MarketMapping_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (16) CONSTRAINT [DF_Fdp_MarketMapping_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ImportMarket]       NVARCHAR (50) NOT NULL,
    [MappedMarketId]     INT           NOT NULL,
    [ProgrammeId]        INT           NULL,
    [Gateway]            NVARCHAR (50) NULL,
    [IsGlobalMapping]    BIT           CONSTRAINT [DF_Fdp_MarketMapping_IsGlobalMapping] DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT           CONSTRAINT [DF_Fdp_MarketMapping_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]          DATETIME      NULL,
    [UpdatedBy]          NVARCHAR (16) NULL,
    CONSTRAINT [PK_Fdp_MarketMapping] PRIMARY KEY CLUSTERED ([FdpMarketMappingId] ASC),
    CONSTRAINT [FK_Fdp_MarketMapping_OXO_Master_Market] FOREIGN KEY ([MappedMarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_MarketMapping_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_MarketMapping_ProgrammeId]
    ON [dbo].[Fdp_MarketMapping]([ProgrammeId] ASC, [MappedMarketId] ASC);

