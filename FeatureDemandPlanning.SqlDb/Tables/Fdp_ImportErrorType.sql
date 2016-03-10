CREATE TABLE [dbo].[Fdp_ImportErrorType] (
    [FdpImportErrorTypeId] INT            NOT NULL,
    [Type]                 NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (MAX) NOT NULL,
    [WorkflowOrder]        INT            CONSTRAINT [DF__Fdp_Impor__Workf__1EE485AA] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Fdp_ImportErrorType] PRIMARY KEY CLUSTERED ([FdpImportErrorTypeId] ASC)
);





