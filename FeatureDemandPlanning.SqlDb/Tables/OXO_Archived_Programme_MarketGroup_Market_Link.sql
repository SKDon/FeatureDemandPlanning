CREATE TABLE [dbo].[OXO_Archived_Programme_MarketGroup_Market_Link] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Doc_Id]          INT            NOT NULL,
    [Programme_Id]    INT            NOT NULL,
    [Market_Group_Id] INT            NOT NULL,
    [Country_Id]      INT            NOT NULL,
    [Sub_Region]      NVARCHAR (500) NULL,
    [CDSID]           NVARCHAR (50)  NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_MarketGroup_Market_Link] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_Doc_Group_Market]
    ON [dbo].[OXO_Archived_Programme_MarketGroup_Market_Link]([Doc_Id] ASC, [Programme_Id] ASC, [Market_Group_Id] ASC, [Country_Id] ASC);

