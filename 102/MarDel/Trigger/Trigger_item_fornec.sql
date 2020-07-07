CREATE TRIGGER tg_sup0090_5054 ON item_fornec
FOR UPDATE
AS
  BEGIN

    DECLARE @p_cod_empresa      CHAR(02),
            @p_cod_fornecedor   CHAR(15),
            @p_cod_item         CHAR(15),
            @p_qtd_insp_ant     INT,
            @p_qtd_insp_dep     INT

    SELECT @p_qtd_insp_ant = d.qtd_inspecao
      FROM DELETED d

    SELECT @p_cod_empresa    = i.cod_empresa,
           @p_cod_fornecedor = i.cod_fornecedor,
           @p_cod_item       = i.cod_item,
           @p_qtd_insp_dep   = i.qtd_inspecao
      FROM INSERTED i

    IF(@p_qtd_insp_ant <> @p_qtd_insp_dep)
      BEGIN
         EXEC grv_it_for_5054 @p_cod_empresa, @p_cod_fornecedor, @p_cod_item, @p_qtd_insp_ant
      END
  END
GO



CREATE PROCEDURE grv_it_for_5054
   (
      @p_cod_empresa         CHAR(02),
      @p_cod_fornecedor      CHAR(15),
      @p_cod_item            CHAR(15),
      @p_qtd_inspecao        INT
   )

  AS

   DECLARE  @p_cod_grupo char(03)

   SELECT @p_cod_grupo = cod_grupo
     FROM fornec_item_5054
    WHERE cod_empresa = @p_cod_empresa
      AND cod_fornecedor = @p_cod_fornecedor
      AND cod_item = @p_cod_item;

   IF (@p_cod_grupo IS NOT NULL )
      BEGIN
         UPDATE item_fornec SET qtd_inspecao = @p_qtd_inspecao
          WHERE cod_empresa  = @p_cod_empresa
            AND cod_fornecedor = @p_cod_fornecedor
            AND cod_item = @p_cod_item;
      END

GO


 