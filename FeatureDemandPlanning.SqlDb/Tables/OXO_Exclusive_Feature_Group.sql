CREATE TABLE [dbo].[OXO_Exclusive_Feature_Group] (
    [Id]           INT            NOT NULL,
    [EFG_Code]     NVARCHAR (10)  NULL,
    [EFG_Desc]     NVARCHAR (100) NULL,
    [EFG_Type]     NVARCHAR (50)  NULL,
    [Status]       BIT            NULL,
    [Created_By]   NVARCHAR (8)   NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (8)   NULL,
    [Last_Updated] DATETIME       NULL,
    CONSTRAINT [PK_OXO_Efg] PRIMARY KEY CLUSTERED ([Id] ASC)
);

