
create table ordem_erro_912 (
    empresa   char(2) ,
    ordem_mps char(30) ,
    item      char(15),
    erro      char(80)
)

create index ordem_erro_912 on ordem_erro_912 
    (empresa, ordem_mps);
    
    