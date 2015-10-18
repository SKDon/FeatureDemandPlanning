CREATE TABLE [dbo].[OXO_Item_Data_Hist] (
    [Id]        INT           IDENTITY (1, 1) NOT NULL,
    [Item_Id]   INT           NULL,
    [Section]   NVARCHAR (50) NULL,
    [Item_Code] NVARCHAR (50) NULL,
    [Prev_Code] NVARCHAR (50) NULL,
    [Set_Id]    INT           NULL,
    CONSTRAINT [PK_OXO_Item_Data_Hist] PRIMARY KEY CLUSTERED ([Id] ASC)
);

