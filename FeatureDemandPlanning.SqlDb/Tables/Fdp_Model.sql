CREATE TABLE [dbo].[Fdp_Model] (
    [FdpModelId]         INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]          DATETIME       CONSTRAINT [DF_FdpModel_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (16)  CONSTRAINT [DF_FdpModel_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ProgrammeId]        INT            NOT NULL,
    [Gateway]            NVARCHAR (100) NOT NULL,
    [DerivativeCode]     NVARCHAR (20)  NULL,
    [FdpDerivativeId]    INT            NULL,
    [TrimId]             INT            NULL,
    [FdpTrimId]          INT            NULL,
    [IsActive]           BIT            CONSTRAINT [DF_FdpModel_IsActive] DEFAULT ((1)) NOT NULL,
    [UpdatedOn]          DATETIME       NULL,
    [UpdatedBy]          NVARCHAR (16)  NULL,
    [OriginalFdpModelId] INT            NULL,
    CONSTRAINT [PK_FdpModel] PRIMARY KEY CLUSTERED ([FdpModelId] ASC),
    CONSTRAINT [FK_FdpModel_Fdp_Derivative] FOREIGN KEY ([FdpDerivativeId]) REFERENCES [dbo].[Fdp_Derivative] ([FdpDerivativeId]),
    CONSTRAINT [FK_FdpModel_Fdp_Trim] FOREIGN KEY ([FdpTrimId]) REFERENCES [dbo].[Fdp_Trim] ([FdpTrimId])
);








GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Model_OriginalFdpModelId]
    ON [dbo].[Fdp_Model]([OriginalFdpModelId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_Model_Cover]
    ON [dbo].[Fdp_Model]([ProgrammeId] ASC, [Gateway] ASC, [FdpModelId] ASC, [FdpTrimId] ASC, [TrimId] ASC);

