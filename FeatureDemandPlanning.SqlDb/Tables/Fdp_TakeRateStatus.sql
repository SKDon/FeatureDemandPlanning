CREATE TABLE [dbo].[Fdp_TakeRateStatus] (
    [FdpTakeRateStatusId] INT            NOT NULL,
    [Status]              NVARCHAR (50)  NOT NULL,
    [Description]         NVARCHAR (MAX) NOT NULL,
    [IsActive]            BIT            CONSTRAINT [DF__Fdp_TakeR__IsAct__35C7EB02] DEFAULT ((1)) NOT NULL,
    [WorkflowStepId]      INT            CONSTRAINT [DF__Fdp_TakeR__Workf__36BC0F3B] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_TakeRateStatus] PRIMARY KEY CLUSTERED ([FdpTakeRateStatusId] ASC)
);



