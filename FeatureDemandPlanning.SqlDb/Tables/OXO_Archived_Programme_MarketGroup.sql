CREATE TABLE [dbo].[OXO_Archived_Programme_MarketGroup] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Doc_Id]        INT            NULL,
    [Programme_Id]  INT            NULL,
    [Group_Name]    NVARCHAR (500) NULL,
    [Extra_Info]    NVARCHAR (500) NULL,
    [Active]        BIT            NULL,
    [Clone_Id]      INT            NULL,
    [Display_Order] INT            NULL,
    [Created_By]    NVARCHAR (8)   NULL,
    [Created_On]    DATETIME       NULL,
    [Updated_By]    NVARCHAR (8)   NULL,
    [Last_Updated]  DATETIME       NULL,
    CONSTRAINT [PK_OXO_Archived_Programme_Market] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Archived_Prog_MktGrp]
    ON [dbo].[OXO_Archived_Programme_MarketGroup]([Doc_Id] ASC, [Programme_Id] ASC);

