CREATE TABLE [dbo].[Fdp_ImportData] (
    [FdpImportDataId]                            INT            IDENTITY (1, 1) NOT NULL,
    [FdpImportId]                                INT            NOT NULL,
    [LineNumber]                                 INT            NULL,
    [NSC or Importer Description (Vista Market)] NVARCHAR (100) NULL,
    [Country Description]                        NVARCHAR (100) NULL,
    [Derivative Code]                            NVARCHAR (10)  NULL,
    [Trim Pack Description]                      NVARCHAR (100) NULL,
    [Bff Feature Code]                           NVARCHAR (10)  NULL,
    [Feature Description]                        NVARCHAR (255) NULL,
    [Count of Specific Order No]                 NVARCHAR (10)  NULL,
    CONSTRAINT [PK_Fdp_ImportData] PRIMARY KEY CLUSTERED ([FdpImportDataId] ASC),
    CONSTRAINT [FK_Fdp_ImportData_Fdp_Import] FOREIGN KEY ([FdpImportId]) REFERENCES [dbo].[Fdp_Import] ([FdpImportId])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Import_DerivativeAndTrim]
    ON [dbo].[Fdp_ImportData]([Derivative Code] ASC, [Trim Pack Description] ASC)
    INCLUDE([FdpImportId], [Country Description], [Bff Feature Code], [Count of Specific Order No]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Import_FeatureCode]
    ON [dbo].[Fdp_ImportData]([Bff Feature Code] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportData_Derivative Code]
    ON [dbo].[Fdp_ImportData]([Derivative Code] ASC)
    INCLUDE([FdpImportId], [NSC or Importer Description (Vista Market)], [Trim Pack Description], [Bff Feature Code], [Count of Specific Order No]);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_ImportData_Market]
    ON [dbo].[Fdp_ImportData]([NSC or Importer Description (Vista Market)] ASC, [Country Description] ASC);

