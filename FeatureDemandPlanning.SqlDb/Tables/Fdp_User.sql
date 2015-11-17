CREATE TABLE [dbo].[Fdp_User] (
    [FdpUserId] INT           IDENTITY (1, 1) NOT NULL,
    [CDSId]     NVARCHAR (16) NOT NULL,
    [FullName]  NVARCHAR (50) NOT NULL,
    [IsActive]  BIT           CONSTRAINT [DF_Fdp_User_IsActive] DEFAULT ((1)) NOT NULL,
    [IsAdmin]   BIT           CONSTRAINT [DF_Fdp_User_IsAdmin] DEFAULT ((0)) NOT NULL,
    [CreatedOn] DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy] NVARCHAR (16) DEFAULT (suser_sname()) NULL,
    [UpdatedOn] DATETIME      NULL,
    [UpdatedBy] NVARCHAR (16) NULL,
    CONSTRAINT [PK_Fdp_User] PRIMARY KEY CLUSTERED ([FdpUserId] ASC)
);

