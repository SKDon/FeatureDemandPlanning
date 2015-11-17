CREATE TABLE [dbo].[Fdp_TakeRateStatus] (
    [FdpTakeRateStatusId] INT            NOT NULL,
    [Status]              NVARCHAR (50)  NOT NULL,
    [Description]         NVARCHAR (MAX) NOT NULL,
    [IsActive]            BIT            DEFAULT ((1)) NOT NULL,
    [WorkflowStepId]      INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateStatus] PRIMARY KEY CLUSTERED ([FdpTakeRateStatusId] ASC)
);

