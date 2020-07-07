  CREATE TABLE minuta_cairu (
     num_controle      CHAR(06),
     nom_cliente       CHAR(36), 
     end_cliente       CHAR(36),       
     den_bairro        CHAR(20),       
     cid_cliente       CHAR(30),       
     uf_cliente        CHAR(02),       
     num_cgc_cpf       CHAR(20),       
     ins_estadual      CHAR(20),       
     cod_cep           CHAR(10),       
     num_nff           INTEGER,        
     dat_emiss         CHAR(10),       
     num_pedido        INTEGER,        
     end_entrega       CHAR(36),     
     cod_repres        INTEGER,        
     nom_repres        CHAR(30),      
     nom_transp        CHAR(36),       
     tel_transp        CHAR(20),       
     end_transp        CHAR (55),      
     bai_transp        CHAR(20),    
     cid_transp        CHAR(30),       
     val_tot_nff       CHAR(20),       
     pes_bruto         CHAR(20),       
     pes_liquido       CHAR(20),       
     marca             CHAR(10),       
     numero            CHAR(10),
     qtd_embal         CHAR(05),
     especie           CHAR(03),       
     impress           INTEGER,        
     usuario           CHAR(08),       
     cod_empresa       CHAR(02)
  );

CREATE TABLE controle_cairu (
   cod_empresa       CHAR(02),
   num_controle      integer,
   primary key (cod_empresa, num_controle)        
);