--armazena informações dos documentos processados
--os quais serão enviados por email, para o usuá-
--rio solicitante ou para o próximo aprovador
 
   CREATE  TABLE email_env_265(
      id_registro    SERIAL,
	    num_docum      CHAR(10),
	    num_versao     CHAR(02),
	    tip_docum      CHAR(02),
	    cod_empresa    CHAR(02),
	    cod_usuario    CHAR(10),
	    email_usuario  CHAR(50),
	    nom_usuario    CHAR(50),
	    cod_emitente   CHAR(10),
	    email_emitente CHAR(50),
	    nom_emitente   CHAR(50)
	 );

create unique index email_env_265_ix1 on
email_env_265(id_registro);
 
create index email_env_265_ix2 on
email_env_265(cod_usuario);
