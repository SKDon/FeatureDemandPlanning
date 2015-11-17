CREATE TABLE [dbo].[Fdp_Feature] (
    [FdpFeatureId]       INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]          DATETIME       CONSTRAINT [DF_Fdp_Feature_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (16)  CONSTRAINT [DF_Fdp_Feature_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ProgrammeId]        INT            NOT NULL,
    [Gateway]            NVARCHAR (100) NOT NULL,
    [FeatureCode]        NVARCHAR (20)  NOT NULL,
    [FeatureGroupId]     INT            NOT NULL,
    [FeatureDescription] NVARCHAR (255) NOT NULL,
    [IsActive]           BIT            CONSTRAINT [DF_Fdp_Feature_IsActive] DEFAULT ((1)) NULL,
    [UpdatedOn]          DATETIME       NULL,
    [UpdatedBy]          NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_Feature] PRIMARY KEY CLUSTERED ([FdpFeatureId] ASC),
    CONSTRAINT [FK_Fdp_Feature_OXO_Feature_Group] FOREIGN KEY ([FeatureGroupId]) REFERENCES [dbo].[OXO_Feature_Group] ([Id]),
    CONSTRAINT [FK_Fdp_Feature_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Feature_FeatureCode]
    ON [dbo].[Fdp_Feature]([FeatureCode] ASC, [ProgrammeId] ASC);

