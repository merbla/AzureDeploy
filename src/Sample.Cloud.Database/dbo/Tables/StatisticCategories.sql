CREATE TABLE [dbo].[StatisticCategories] (
    [Id]            INT              IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX)   NULL,
    [ModelId]       UNIQUEIDENTIFIER NOT NULL,
    [Created]       DATETIME         NOT NULL,
    [LastModified]  DATETIME         NOT NULL,
    [CreatedBy]     NVARCHAR (MAX)   NOT NULL,
    [LastUpdatedBy] NVARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

