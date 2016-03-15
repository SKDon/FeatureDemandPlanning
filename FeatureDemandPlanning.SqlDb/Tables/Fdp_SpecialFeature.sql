CREATE TABLE [dbo].[Fdp_SpecialFeature] (
    [FdpSpecialFeatureId]     INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Fdp_SpecialFeature_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_SpecialFeature_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [DocumentId]              INT            NOT NULL,
    [ProgrammeId]             INT            NOT NULL,
    [Gateway]                 NVARCHAR (100) NOT NULL,
    [FeatureCode]             NVARCHAR (20)  NOT NULL,
    [FdpSpecialFeatureTypeId] INT            NOT NULL,
    [IsActive]                BIT            CONSTRAINT [DF_Fdp_SpecialFeature_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_SpecialFeature] PRIMARY KEY CLUSTERED ([FdpSpecialFeatureId] ASC),
    CONSTRAINT [FK_Fdp_SpecialFeature_OXO_Doc] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_SpecialFeature_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_SpecialFeature_DocumentId]
    ON [dbo].[Fdp_SpecialFeature]([DocumentId] ASC)
    INCLUDE([IsActive]);

