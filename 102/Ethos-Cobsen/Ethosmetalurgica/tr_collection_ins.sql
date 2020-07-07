
CREATE trigger tr_ins_coll_ethosm on collection
for insert
as
     DECLARE @id                integer,
             @ptrprod           integer

     select  @id            = id,
             @ptrprod       = ptrprod
        from inserted


     begin        

           insert
             into ethosm_collec_incl
           select '01' as cod_empresa,
                  id,
                  ptrprod
             from collection
            where id = @id
              and not exists(
           select *
             from ethosm_collec_incl
            where ethosm_collec_incl.cod_empresa = '01'
              and ethosm_collec_incl.id_collection = collection.id)

     end
