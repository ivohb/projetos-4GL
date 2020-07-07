
create table vw_igreja (         
   cod_pais           char(05),  
   den_pais           char(30),  
   cod_estado         char(02),  
   den_estado         char(20),  
   den_uf             char(15),  
   cod_area           char(05),  
   den_area           char(30),  
   cod_regiao         char(05),  
   den_regiao         char(30),  
   cod_tip_regiao     char(05),  
   den_tip_regiao     char(30),  
   cod_igreja         char(12),  
   den_igreja         char(30),  
   cod_tip_local      char(03),  
   den_tip_local      char(30),  
   cod_tip_igreja     char(03),  
   nom_tip_igreja     char(30),  
   den_tip_igreja     char(30),  
   dt_ini_igreja      date,      
   dt_fim_igreja      date,      
   cod_situacao       char(01),  
   hr_sede_regiao     char(05),  
   hr_sede_estado     char(05),  
   bloqueada          char(01),  
   cod_language       char(05)   
) 

create index ix_igreja on vw_igreja (cod_pais);


create table vw_igreja_historico (         
   cod_pais           char(05),  
   den_pais           char(30),  
   cod_estado         char(02),  
   den_estado         char(20),  
   den_uf             char(15),  
   cod_area           char(05),  
   den_area           char(30),  
   cod_regiao         char(05),  
   den_regiao         char(30),  
   cod_tip_regiao     char(05),  
   den_tip_regiao     char(30),  
   cod_igreja         char(12),  
   den_igreja         char(30),  
   cod_tip_local      char(03),  
   den_tip_local      char(30),  
   cod_tip_igreja     char(03),  
   nom_tip_igreja     char(30),  
   den_tip_igreja     char(30),  
   dt_ini_igreja      date,      
   dt_fim_igreja      date,      
   cod_situacao       char(01),  
   hr_sede_regiao     char(05),  
   hr_sede_estado     char(05),  
   bloqueada          char(01),  
   cod_language       char(05),
   dt_ini_hist        date,
   dt_fim_hist        date
) 

create index ix_hist on vw_igreja_historico (cod_pais);


