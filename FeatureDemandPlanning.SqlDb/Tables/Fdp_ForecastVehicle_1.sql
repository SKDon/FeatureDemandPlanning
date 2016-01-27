CREATE TABLE [dbo].[Fdp_ForecastVehicle] (
    [ForecastVehicleId] INT IDENTITY (1, 1) NOT NULL,
    [ProgrammeId]       INT NULL,
    [VehicleId]         INT NULL,
    [GatewayId]         INT NULL,
    CONSTRAINT [PK_Fdp_ForecastVehicle] PRIMARY KEY CLUSTERED ([ForecastVehicleId] ASC),
    CONSTRAINT [FK_Fdp_ForecastVehicle_OXO_Gateway] FOREIGN KEY ([GatewayId]) REFERENCES [dbo].[OXO_Gateway] ([Id]),
    CONSTRAINT [FK_Fdp_ForecastVehicle_OXO_Programme] FOREIGN KEY ([ProgrammeId]) REFERENCES [dbo].[OXO_Programme] ([Id]),
    CONSTRAINT [FK_Fdp_ForecastVehicle_OXO_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[OXO_Vehicle] ([Id])
);



