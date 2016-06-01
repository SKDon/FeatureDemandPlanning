CREATE TABLE [dbo].[Fdp_RawModel] (
    [ModelId]         INT NOT NULL,
    [IsFdpModel]      BIT CONSTRAINT [DF_Fdp_RawModel_IsFdpModel] DEFAULT ((0)) NOT NULL,
    [ModelIdentifier] AS  ('O'+CONVERT([nvarchar](10),[ModelId],(0))) PERSISTED,
    CONSTRAINT [PK_Fdp_RawModel] PRIMARY KEY CLUSTERED ([ModelId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_RawModel]
    ON [dbo].[Fdp_RawModel]([ModelId] ASC, [ModelIdentifier] ASC);

