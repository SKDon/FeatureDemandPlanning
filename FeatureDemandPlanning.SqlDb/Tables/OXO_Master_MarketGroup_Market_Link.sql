CREATE TABLE [dbo].[OXO_Master_MarketGroup_Market_Link] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Market_Group_Id] INT            NOT NULL,
    [Country_Id]      INT            NOT NULL,
    [Sub_Region]      NVARCHAR (500) NULL,
    CONSTRAINT [PK_OXO_Master_MarketGroup_Market_Link] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OXO_Master_Market_Country_Link_OXO_Master_Country] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_OXO_Master_Market_Country_Link_OXO_Master_Market] FOREIGN KEY ([Market_Group_Id]) REFERENCES [dbo].[OXO_Master_MarketGroup] ([Id])
);

