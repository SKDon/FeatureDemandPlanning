CREATE TABLE [dbo].[ImportQueue] (
    [ImportQueueId]  INT            IDENTITY (1, 1) NOT NULL,
    [CreatedOn]      DATETIME       CONSTRAINT [DF_Fdp_ImportQueue_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      NVARCHAR (16)  CONSTRAINT [DF_Fdp_ImportQueue_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ImportTypeId]   INT            NOT NULL,
    [ImportStatusId] INT            NOT NULL,
    [FilePath]       NVARCHAR (MAX) NOT NULL,
    [UpdatedOn]      DATETIME       NULL,
    CONSTRAINT [PK_Fdp_ImportQueue] PRIMARY KEY CLUSTERED ([ImportQueueId] ASC),
    CONSTRAINT [FK_ImportQueue_ImportStatus] FOREIGN KEY ([ImportStatusId]) REFERENCES [dbo].[ImportStatus] ([ImportStatusId]),
    CONSTRAINT [FK_ImportQueue_ImportType] FOREIGN KEY ([ImportTypeId]) REFERENCES [dbo].[ImportType] ([ImportTypeId])
);

