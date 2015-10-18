CREATE TABLE [dbo].[OXO_Feature_Group] (
    [Id]             INT            NOT NULL,
    [Group_Name]     NVARCHAR (100) NULL,
    [Sub_Group_Name] NVARCHAR (100) NULL,
    [Status]         BIT            NULL,
    [Display_Order]  INT            NULL,
    [Created_By]     NVARCHAR (8)   NULL,
    [Created_On]     DATETIME       NULL,
    [Updated_By]     NVARCHAR (8)   NULL,
    [Last_Updated]   DATETIME       NULL,
    CONSTRAINT [PK_Feature_Group] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Feature_Group_Display_Order]
    ON [dbo].[OXO_Feature_Group]([Display_Order] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Feature_Group_Group_Name]
    ON [dbo].[OXO_Feature_Group]([Group_Name] ASC);




GO


