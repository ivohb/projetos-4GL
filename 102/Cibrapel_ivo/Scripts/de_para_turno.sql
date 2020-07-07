USE [logixprd]
GO

/****** Object:  Table [logix].[de_para_turno_885]    Script Date: 10/10/2014 15:06:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [logix].[de_para_turno_885](
	[cod_empresa] [char](2) NOT NULL,
	[turno_simula] [char](3) NOT NULL,
	[turno_logix] [decimal](3, 0) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

