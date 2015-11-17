CREATE TABLE [dbo].[Fdp_News] (
    [FdpNewsId] INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn] DATETIME       CONSTRAINT [DF_Fdp_News_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy] NVARCHAR (16)  NOT NULL,
    [Headline]  NVARCHAR (200) NOT NULL,
    [Body]      NVARCHAR (MAX) NOT NULL,
    [IsActive]  BIT            CONSTRAINT [DF_Fdp_News_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_News] PRIMARY KEY CLUSTERED ([FdpNewsId] ASC)
);

