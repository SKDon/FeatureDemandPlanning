CREATE TABLE [dbo].[Fdp_Forecast] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [ForecastVehicleId] INT           NOT NULL,
    [CreatedOn]         DATETIME      CONSTRAINT [DF_Fdp_Forecast_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (16) CONSTRAINT [DF_Fdp_Forecast_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [UpdatedOn]         DATETIME      NULL,
    [UpdatedBy]         NVARCHAR (16) NULL,
    [IsActive]          BIT           CONSTRAINT [DF_Fdp_Forecast_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Fdp_Forecast] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Fdp_Forecast_Fdp_ForecastVehicle] FOREIGN KEY ([ForecastVehicleId]) REFERENCES [dbo].[Fdp_ForecastVehicle] ([ForecastVehicleId])
);

