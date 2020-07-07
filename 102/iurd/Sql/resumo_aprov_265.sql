--Armazena um resumo do processamento,
--quando o usuário aprova um documento

drop table resumo_aprov_265 ;
create table resumo_aprov_265 (
 cod_empresa char(02),
 num_docum   char(10),
 tip_docum   char(10),
 mensagem    char(500),
 nivel_aprov char(02),
 user_aprov  char(08),
 dat_aprov   date,
 hor_aprov   char(08)
);

create index resu1_aprov_265 on
 resumo_aprov_265(user_aprov, nivel_aprov);
 