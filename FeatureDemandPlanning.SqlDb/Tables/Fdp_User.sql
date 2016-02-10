CREATE TABLE [dbo].[Fdp_User] (
    [FdpUserId] INT            IDENTITY (1, 1) NOT NULL,
    [CDSId]     NVARCHAR (16)  NOT NULL,
    [FullName]  NVARCHAR (50)  NOT NULL,
    [Mail]      NVARCHAR (100) NULL,
    [IsActive]  BIT            CONSTRAINT [DF_Fdp_User_IsActive] DEFAULT ((1)) NOT NULL,
    [IsAdmin]   BIT            CONSTRAINT [DF_Fdp_User_IsAdmin] DEFAULT ((0)) NOT NULL,
    [CreatedOn] DATETIME       CONSTRAINT [DF__Fdp_User__Create__450A2E92] DEFAULT (getdate()) NOT NULL,
    [CreatedBy] NVARCHAR (16)  CONSTRAINT [DF__Fdp_User__Create__45FE52CB] DEFAULT (suser_sname()) NULL,
    [UpdatedOn] DATETIME       NULL,
    [UpdatedBy] NVARCHAR (16)  NULL,
    CONSTRAINT [PK_Fdp_User] PRIMARY KEY CLUSTERED ([FdpUserId] ASC)
);



