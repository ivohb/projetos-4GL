
drop  procedure grava_fornec_5054;

create procedure grava_fornec_5054
   (
      @p_cod_empresa char(02),
      @p_num_ar      int,
      @p_cod_item    char(15)

   )

  AS

   DECLARE  @p_cod_fornecedor char(15)
   DECLARE  @p_qtd_entr_sem_insp decimal(10,3)
   DECLARE  @p_cod_grupo char(03)

   SELECT @p_cod_fornecedor = cod_fornecedor
     from nf_sup
    where cod_empresa = @p_cod_empresa
      and num_aviso_rec = @p_num_ar;

   SELECT @p_qtd_entr_sem_insp = qtd_entr_sem_insp
     from item_fornec
    where cod_empresa = @p_cod_empresa
      and cod_fornecedor = @p_cod_fornecedor
      and cod_item = @p_cod_item;

   SELECT @p_cod_grupo = cod_grupo
     from fornec_item_5054
    where cod_fornecedor = @p_cod_fornecedor
      and cod_item = @p_cod_item;

   IF (@p_cod_grupo IS NOT NULL )
      BEGIN
       update item_fornec set qtd_entr_sem_insp = @p_qtd_entr_sem_insp
       where cod_empresa    = @p_cod_empresa
         and cod_fornecedor = @p_cod_fornecedor
         and cod_item in
             (select cod_item from fornec_item_5054
               where cod_fornecedor = @p_cod_fornecedor
                 and cod_grupo = @p_cod_grupo);
      END

GO


CREATE TRIGGER skip_lot_5054 ON aviso_rec
FOR UPDATE
AS
  BEGIN

    DECLARE @p_cod_empresa CHAR(02),
            @p_num_ar      int,
            @p_cod_item    CHAR(15),
            @p_ies_cont_dep char(01)

    SELECT @p_cod_empresa  = i.cod_empresa,
           @p_num_ar       = i.num_aviso_rec,
           @p_cod_item     = i.cod_item,
           @p_ies_cont_dep = i.ies_liberacao_cont
    FROM INSERTED i

    EXEC grava_fornec_5054 @p_cod_empresa, @p_num_ar, @p_cod_item

  END
GO
