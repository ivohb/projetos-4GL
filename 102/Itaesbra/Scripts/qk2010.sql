
create table qk2010 
  (
    qk2_filial varchar(2) 
        default '' not null ,
    qk2_peca varchar(40) 
        default '' not null ,
    qk2_rev varchar(2) 
        default '' not null ,
    qk2_revinv varchar(2) 
        default '',
    qk2_item varchar(4) 
        default '',
    qk2_codcar varchar(8) 
        default '' not null ,
    qk2_desc varchar(50) 
        default '',
    qk2_espe varchar(50) 
        default '',
    qk2_tpcar varchar(1) 
        default '',
    qk2_prodpr varchar(1) 
        default '',
    qk2_planoc varchar(1) 
        default '',
    qk2_tol varchar(13) 
        default '',
    qk2_lie varchar(13) 
        default '',
    qk2_lse varchar(13) 
        default '',
    qk2_esp varchar(1) 
        default '',
    qk2_simb varchar(2) 
        default '',
    qk2_um varchar(2) 
        default '',
    r_e_c_d_e_l_ float 
        default 0.0000000000000000 not null ,
    d_e_l_e_t_ varchar(1) 
        default '',
    r_e_c_n_o_ integer 
        default 0 not null ,
    primary key (r_e_c_n_o_) 
  );


create index qk20101 on qk2010 (qk2_filial,qk2_peca,
    qk2_rev,qk2_item,r_e_c_n_o_,d_e_l_e_t_);
    
create index qk20102 on qk2010 (qk2_filial,qk2_peca,
    qk2_rev,qk2_codcar,r_e_c_n_o_,d_e_l_e_t_);
    
create index qk20103 on qk2010 (qk2_filial,qk2_peca,
    qk2_revinv,qk2_item,r_e_c_n_o_,d_e_l_e_t_);
    
create unique index qk2010_unq on qk2010 (qk2_filial,
    qk2_peca,qk2_rev,qk2_codcar,r_e_c_d_e_l_);


