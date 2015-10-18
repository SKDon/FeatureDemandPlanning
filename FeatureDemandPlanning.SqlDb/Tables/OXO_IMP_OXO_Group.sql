CREATE TABLE [dbo].[OXO_IMP_OXO_Group] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Group_Name]     NVARCHAR (100) NULL,
    [Sub_Group_Name] NVARCHAR (100) NULL,
    [Status]         BIT            NULL,
    [Display_Order]  INT            NULL,
    [Created_By]     NVARCHAR (8)   NULL,
    [Created_On]     DATETIME       NULL,
    [Updated_By]     NVARCHAR (8)   NULL,
    [Last_Updated]   DATETIME       NULL,
    CONSTRAINT [PK_OXO_IMP_OXO_Grp] PRIMARY KEY CLUSTERED ([Id] ASC)
);



