CREATE TABLE [dbo].[OXO_Feature_Brand_Desc] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [Feat_Code]  NVARCHAR (10)   NULL,
    [Brand]      NVARCHAR (10)   NULL,
    [Brand_Desc] NVARCHAR (1000) NULL,
    CONSTRAINT [PK_OXO_Feature_Brand_Desc] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_FEAT_BRAND_DESC]
    ON [dbo].[OXO_Feature_Brand_Desc]([Feat_Code] ASC, [Brand] ASC);

