CREATE TABLE [dbo].[Fdp_MarketReview] (
    [FdpMarketReviewId]       INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]               DATETIME       CONSTRAINT [DF_Table_1_CreatedBy] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]               NVARCHAR (16)  CONSTRAINT [DF_Fdp_MarketReview_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [FdpVolumeHeaderId]       INT            NOT NULL,
    [MarketId]                INT            NOT NULL,
    [FdpMarketReviewStatusId] INT            NOT NULL,
    [IsActive]                BIT            CONSTRAINT [DF_Fdp_MarketReview_IsActive] DEFAULT ((1)) NOT NULL,
    [Comment]                 NVARCHAR (MAX) NULL,
    [UpdatedOn]               DATETIME       NULL,
    [UpdatedBy]               NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_MarketReview] PRIMARY KEY CLUSTERED ([FdpMarketReviewId] ASC),
    CONSTRAINT [FK_Fdp_MarketReview_Fdp_MarketReviewStatus] FOREIGN KEY ([FdpMarketReviewStatusId]) REFERENCES [dbo].[Fdp_MarketReviewStatus] ([FdpMarketReviewStatusId]),
    CONSTRAINT [FK_Fdp_MarketReview_Fdp_VolumeHeader] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_MarketReview_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id])
);






GO
CREATE TRIGGER [dbo].[tr_Fdp_MarketReview_Audit] ON [dbo].[Fdp_MarketReview] FOR UPDATE
AS
	DECLARE @Type AS CHAR(1);
	
	-- Put the old "deleted" values into the audit as the primary table contains the new record values

	INSERT INTO Fdp_MarketReviewAudit
	(
		  AuditOn
		, AuditBy
		, FdpMarketReviewId
		, FdpMarketReviewStatusId
		, Comment
	)
	SELECT 
		  ISNULL(D.UpdatedOn, D.CreatedOn)
		, ISNULL(D.UpdatedBy, D.CreatedBy)
		, D.FdpMarketReviewId
		, D.FdpMarketReviewStatusId
		, D.Comment
		
	FROM deleted	AS D
	JOIN inserted	AS I ON D.FdpMarketReviewId = I.FdpMarketReviewId