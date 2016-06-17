CREATE TABLE [dbo].[Fdp_Publish] (
    [FdpPublishId]      INT            IDENTITY (1, 1) NOT NULL,
    [PublishOn]         DATETIME       CONSTRAINT [DF_Fdp_Publish_PublishOn] DEFAULT (getdate()) NOT NULL,
    [PublishBy]         NVARCHAR (16)  CONSTRAINT [DF_Fdp_Publish_PublishBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId] INT            NOT NULL,
    [MarketId]          INT            NOT NULL,
    [IsPublished]       BIT            CONSTRAINT [DF_Fdp_Publish_IsPublished] DEFAULT ((1)) NOT NULL,
    [Comment]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Fdp_Publish] PRIMARY KEY CLUSTERED ([FdpPublishId] ASC),
    CONSTRAINT [FK_Fdp_Publish_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_Publish_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [Ix_NC_Fdp_Publish_Cover]
    ON [dbo].[Fdp_Publish]([FdpVolumeHeaderId] ASC, [MarketId] ASC)
    INCLUDE([PublishOn], [PublishBy], [IsPublished], [Comment]);

