
create table par_omc_509 (
   cod_empresa   char(02) not null,
   cod_parametro char(40) not null,
   den_parametro char(70) not null,
   par_tipo      char(01) not null,
   par_dec       dec(17,5),
   par_int       integer,
   par_dat       date,
   par_txt       char(30)
);

create unique index ix1_par_omc_509 on
 par_omc_509(cod_empresa, cod_parametro);
 
create table nf_mestre_509 (
   cod_empresa	    char(02),
   tip_nf 	        Char(03),  
   num_nf	          decimal(6,0),
   ser_nf	          Char(02),
   cod_cliente	    Char(15),             
   dat_emissao	    datetime,                 
   dat_vencto 	    datetime,                 
   val_bruto_nf 	  decimal(17,2),      
   val_desc_incond	decimal(17,2),    
   val_liq_nf 	    decimal(17,2),    
   val_desc_cenp    decimal(17,2),  
   val_tot_nf 	    decimal(17,2),        
   val_duplicata	  decimal(17,2),      
   num_boleto	      Char(15),               
   ies_situa_nf	    char(1),              
   dat_cancel	      datetime,                   
   txt_nf     	    Char(300),  
   tip_nf_dev	      Char(03),             
   num_nf_dev	      decimal(6,0),           
   ser_nf_dev       Char(02),
   chave_acesso     char(44),
   protocolo        char(15),
   dat_protocolo    datetime,
   hor_protocolo    char(08),
   cod_estatus      char(01), -- A-Aceito R-Rejeitado
   nom_arquivo      char(30),
   id_registro      integer
);

create unique index ix1_nf_mestre_509 on
 nf_mestre_509(cod_empresa, cod_cliente, num_nf, ser_nf);

create unique index ix2_nf_mestre_509 on
 nf_mestre_509(cod_empresa, id_registro);

create table nf_itens_509 (
   cod_empresa     char(02),
   num_nf          decimal(6,0),                       
   ser_nf          Char(02),                   
   cod_cliente     Char(15),                     
   num_seq_nf      Decimal(5,0),                   
   cod_item        Char(15),                         
   den_item	       Char(76),                         
   ncm             Char(15),  
   grupo_item      Char(20),       
   qtd_item        decimal(12,3),                    
   cod_unidade     Char(03),                   
   pre_unit_bruto  decimal(17,6),                    
   pre_unit_liq    decimal(17,6), 
   Val_bruto_item  decimal(17,2),                    
   val_liq_item    decimal(17,2), 
   val_desc_incond decimal(17,2), 
   val_desc_cenp   decimal(17,2),  
   val_item_dupl   decimal(17,2),  
   pct_iss         decimal(5,2),                    
   val_base_iss	   decimal(17,2),            
   val_iss         decimal(17,2),                    
   pct_icms	       decimal(5,2),                     
   val_base_icms   decimal(17,2),          
   val_icms	       decimal(17,2),                
   pct_irpj	       decimal(5,2),                     
   val_base_irpj	 decimal(15,2),              
   val_irpj	       decimal(15,2),                    
   pct_csll	       decimal(5,2),                     
   val_base_csll	 decimal(15,2),              
   val_csll	       decimal(15,2),                    
   pct_cofins	     decimal(5,2),                   
   val_base_cofins decimal(15,2),            
   val_cofins	     decimal(15,2),                  
   pct_pis         decimal(5,2),                     
   val_base_pis    decimal(15,2),                
   val_pis	       decimal(15,2),                    
   ctr_estoque	   Char(1),                  
   txt_item	       Char(300),
   cod_fiscal      decimal(9,0),
   pct_ipi         decimal(5,2),                     
   val_base_ipi    decimal(15,2),                
   val_ipi	       decimal(15,2),  
   seq_nf_dev      integer,
   motivo_dev      decimal(3,0),                  
   nom_arquivo     char(30)   
);

create unique index ix1_nf_itens_509 on nf_itens_509
 (cod_empresa, cod_cliente, num_nf, ser_nf, num_seq_nf);

create table rejeicao_nf_509 (
   cod_empresa     char(02),
   nom_arquivo     char(30),
   id_nf_mestre    integer,
   num_seq         integer,
   motivo          char(70)
);

   
create table clientes_509 (
   cod_cliente	  char(15), 
   num_cnpj_cpf   char(15),  
   tip_cliente	  Char(01), 
   nom_cliente	  Char(35), 
   nom_reduzido   Char(15),  
   end_cliente	  Char(36), 
   den_bairro	    Char(19),   
   cidade         Char(50),  
   cod_cidade     char(10),  
   cod_cep        Char(09),  
   estado         Char(02),  
   num_telefone   char(15),  
   num_fax	      Char(15), 
   insc_municipal Char(15),  
   insc_estadual  Char(15),  
   end_cob        char(36),  
   bairro_cob     Char(19),  
   cidade_cob     Char(50),  
   cod_cid_cob	  char(10), 
   estado_cob     Char(02),  
   cod_cep_cob	  Char(09), 
   contato        Char(15),  
   email1	        Char(50), 
   email2	        Char(50), 
   email3	        Char(50),
   cli_fornec     char(01), -- C-Cliente F-Fornecedor
   cod_estatus    char(01), -- A-Aceito R-Rejeitado
   nom_arquivo    char(30),
   id_registro    integer,
   cod_empresa    char(02)
);

create table rejeicao_cli_509 (
   cod_empresa    char(02),
   nom_arquivo     char(30),
   id_cliente      integer,
   motivo          char(70)
);

create table grupo_item_509 (
   cod_empresa char(02)     not null,
   grupo_item  decimal(2,0) not null,
   cod_item    char(15)     not null
);

create unique index ix1_grupo_item_509 on
 grupo_item_509(cod_empresa, grupo_item);
 
create table cfop_x_natoper_509 (
   cod_fiscal    integer     not null,
   cod_nat_oper  integer     not null,
);

create unique index cfop_x_natoper_509 on
 cfop_x_natoper_509(cod_fiscal);
 

create table titulos_509 (
  cod_empresa      char(02),
  num_nf           decimal(6,0),
  tip_nf           char(03),
  ser_nf           char(02),
  cod_cliente      char(15),
  dat_vencto       char(10),
  dat_pagto        char(10),
  cod_portador     decimal(4,0),
  tip_portador     char(01),
  val_titulo       decimal(12,2),
  val_multa        decimal(12,2),
  val_juros        decimal(12,2),
  val_pago         decimal(12,2),
  tip_pagto        char(01),
  num_docum        char(14),
  tip_docum        char(02),
  id_titulo        integer,
  cod_estatus      char(01), 
  nom_arquivo      char(30),
  primary key (cod_empresa, id_titulo)
);

create index titulos_509_ix1 on titulos_509
 (cod_empresa, num_nf, ser_nf);
 
create table rejeicao_tit_509 (
   cod_empresa     char(02),
   nom_arquivo     char(30),
   id_titulo       integer,
   motivo          char(70)
);
