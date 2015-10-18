CREATE TABLE [dbo].[OXO_Master_MarketGroup] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Group_Name]    NVARCHAR (500) NULL,
    [Extra_Info]    NVARCHAR (500) NULL,
    [Make]          NVARCHAR (500) NULL,
    [Active]        BIT            NULL,
    [Display_Order] INT            NULL,
    [Created_By]    NVARCHAR (8)   NULL,
    [Created_On]    DATETIME       NULL,
    [Updated_By]    NVARCHAR (8)   NULL,
    [Last_Updated]  DATETIME       NULL,
    CONSTRAINT [PK_OXO_Master_Market] PRIMARY KEY CLUSTERED ([Id] ASC)
);

