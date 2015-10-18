CREATE TABLE [dbo].[OXO_Feature_Ext] (
    [Id]           INT            NOT NULL,
    [Feat_Code]    NVARCHAR (10)  NOT NULL,
    [OA_Code]      NVARCHAR (10)  NULL,
    [Feat_EFG]     NVARCHAR (10)  NULL,
    [OXO_Grp]      INT            NULL,
    [Description]  NVARCHAR (100) NULL,
    [Created_By]   NVARCHAR (8)   NULL,
    [Created_On]   DATETIME       NULL,
    [Updated_By]   NVARCHAR (8)   NULL,
    [Last_Updated] DATETIME       NULL,
    [Long_Desc]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_OXO_Feature_Ext] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Feature_Code]
    ON [dbo].[OXO_Feature_Ext]([Feat_Code] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_Feat_OA_Code]
    ON [dbo].[OXO_Feature_Ext]([Feat_Code] ASC, [OA_Code] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_OXO_Grp]
    ON [dbo].[OXO_Feature_Ext]([OXO_Grp] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_OXO_Feature_Ext_Cover]
    ON [dbo].[OXO_Feature_Ext]([Id] ASC)
    INCLUDE([Feat_Code], [OA_Code], [OXO_Grp], [Description], [Long_Desc]);

