CREATE TABLE [dbo].[Games] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [StartDateTime] DATETIME         NOT NULL,
    [EndDateTime]   DATETIME         NOT NULL,
    [Location]      NVARCHAR (MAX)   NULL,
    [Latitude]      REAL             NOT NULL,
    [Longitude]     REAL             NOT NULL,
    [Round]         INT              NOT NULL,
    [GameState]     INT              NOT NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    [HomeTeam_Id]   INT              NULL,
    [AwayTeam_Id]   INT              NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [Game_AwayTeam] FOREIGN KEY ([AwayTeam_Id]) REFERENCES [dbo].[Teams] ([Id]),
    CONSTRAINT [Game_HomeTeam] FOREIGN KEY ([HomeTeam_Id]) REFERENCES [dbo].[Teams] ([Id])
);

