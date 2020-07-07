create table boletim_ond_885 (
 chav_acesso      decimal(14,0),  -- yyyymmddhhmmss
 num_boletim      int,
 num_versao       int,      -- enviar sempre 0 (se a Aline alterar o consumo, eu crio a vers�o 1)
 dat_producao     datetime, -- yyyy-mm-dd
 cod_composicao   char(15), -- KKB345, por exemplo
 num_of           int,  -- n�mero da ordem de fabrica��o
 cod_material     char(15), -- c�digo do papel no logix (MI100, por ex.)
 qtd_consumo      decimal(10,3), -- quantidade consumida pela OF
 cod_operacao     char(01), -- A=Apontar baixa E=Estronar baixa
 status_registro  char(01), -- 0=Enviado pelo Trim 1=Aceito pelo Logix 2=Criticado pelo Logix
 num_sequencia    int identity(1,1),
 cod_baixar       char(15), -- c�digo a baixar informado pelo usu�rio(uso s� do logix)
 qtd_baixar       decimal(10,3), -- quantidade a baixar informada pelo usu�rio(uso s� do logix)
 num_of_chapa     int, -- n�mero da OF da chapa do item do pedido (uso s� do logix)
 primary key(num_sequencia)
);
