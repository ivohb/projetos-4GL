CREATE TABLE vw_igreja
(
cod_pais	      CHAR(3),
den_pais	      VARCHAR2(255),
cod_estado	    CHAR(3),
den_estado	    VARCHAR2(255),
den_uf	        CHAR(2),
cod_area	      NUMBER(5),
den_area	      VARCHAR2(255),
cod_regiao	    NUMBER(5),
den_regiao	    VARCHAR2(255),
cod_tip_regiao	NUMBER(5),
den_tip_regiao	VARCHAR2(255),
cod_igreja	    CHAR(12),
den_igreja	    VARCHAR2(255),
cod_tip_local	  NUMBER(5),
den_tip_local	  VARCHAR2(255),
cod_tip_igreja	NUMBER(5),
nom_tip_igreja	VARCHAR2(255),
den_tip_igreja	VARCHAR2(255),
dt_ini_igreja	  DATE,
dt_fim_igreja	  DATE,
cod_situacao	  NUMBER(5),
hr_sede_regiao	VARCHAR2(4),
hr_sede_estado	VARCHAR2(4),
bloqueada	      CHAR(1),
cod_language	  CHAR(5)
);

CREATE index ix_igreja on vw_igreja
 (cod_pais);
 


CREATE TABLE vw_igreja_historico
(
cod_pais	      CHAR(3),
den_pais	      VARCHAR2(255),
cod_estado	    CHAR(3),
den_estado	    VARCHAR2(255),
den_uf	        CHAR(2),
cod_area	      NUMBER(5),
den_area	      VARCHAR2(255),
cod_regiao	    NUMBER(5),
den_regiao	    VARCHAR2(255),
cod_tip_regiao	NUMBER(5),
den_tip_regiao	VARCHAR2(255),
cod_igreja	    CHAR(12),
den_igreja	    VARCHAR2(255),
cod_tip_local	  NUMBER(5),
den_tip_local	  VARCHAR2(255),
cod_tip_igreja	NUMBER(5),
nom_tip_igreja	VARCHAR2(255),
den_tip_igreja	VARCHAR2(255),
dt_ini_igreja	  DATE,
dt_fim_igreja	  DATE,
cod_situacao	  NUMBER(5),
hr_sede_regiao	VARCHAR2(4),
hr_sede_estado	VARCHAR2(4),
bloqueada	      CHAR(1),
cod_language	  CHAR(5),
dt_ini_hist	    DATE,
dt_fim_hist	    DATE
);

CREATE index ix_igreja_hist on vw_igreja_historico
 (cod_pais);
