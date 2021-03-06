﻿CREATE TABLE [dbo].[Fdp_FeatureMapping] (
    [FdpFeatureMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]           DATETIME       CONSTRAINT [DF_Fdp_FeatureMapping_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           NVARCHAR (16)  CONSTRAINT [DF_Fdp_FeatureMapping_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ImportFeatureCode]   NVARCHAR (20)  NOT NULL,
    [DocumentId]          INT            NOT NULL,
    [ProgrammeId]         INT            NOT NULL,
    [Gateway]             NVARCHAR (100) NOT NULL,
    [FeatureId]           INT            NULL,
    [FeaturePackId]       INT            NULL,
    [IsActive]            BIT            CONSTRAINT [DF_Fdp_FeatureMapping_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]           DATETIME       NULL,
    [UpdatedBy]           NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_FeatureMapping] PRIMARY KEY CLUSTERED ([FdpFeatureMappingId] ASC),
    CONSTRAINT [FK_Fdp_FeatureMapping_OXO_Feature_Ext] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[OXO_Doc] ([Id]),
    CONSTRAINT [FK_Fdp_FeatureMapping_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_FeatureMapping_OXO_Programme_Pack] FOREIGN KEY ([FeaturePackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_FeatureMapping_ImportFeatureCode]
    ON [dbo].[Fdp_FeatureMapping]([ImportFeatureCode] ASC, [ProgrammeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_FeatureMapping_DocumentId]
    ON [dbo].[Fdp_FeatureMapping]([DocumentId] ASC)
    INCLUDE([IsActive]);

