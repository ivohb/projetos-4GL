--- ESTA TRIGGER NÃO PERMITE QUE O USUÁRIO INCLUA UM REGISTRO SEM INFORMAR O
--- CÓDIGO DO CLIENTE NA TABELA 'desc_preco_item' E NÃO DEIXA A TABELA DE PREÇO
--- TER UM CÓDIGO DIFERENTE DO CÓDIGO DO CLIENTE.

drop trigger     tr_tab_preco;
drop procedure   pr_tab_preco;

create procedure pr_tab_preco

(
n_cod_empresa          char(2),
n_num_list_preco       decimal(4,0),
n_cod_uni_feder        char(2),
n_cod_cliente          char(15),
n_cod_item             char(15)
)

define erro       char(15);
define list_preco char(15);

let list_preco = n_num_list_preco;

if list_preco <> n_cod_cliente then
   select cod_cliente 
     into erro
     from cliente_difer_tabpreco;
end if

---if n_cod_uni_feder is null then
---   select cod_cliente 
---     into erro
---     from uni_feder_incorreta;
---end if
  
if n_cod_cliente is null then
   select cod_cliente 
     into erro
     from cliente_incorreto;
end if

if n_cod_cliente = '               ' then
   select cod_cliente 
     into erro
     from cliente_incorreto;
end if

if n_cod_item is null then
   select cod_cliente 
     into erro
     from item_incorreto;
end if

if n_cod_item = '               ' then
   select cod_cliente 
     into erro
     from item_incorreto;
end if

end procedure;

create trigger tr_tab_preco insert on desc_preco_item

referencing new as new_rec for each row 
(
execute procedure pr_tab_preco(new_rec.cod_empresa,
                               new_rec.num_list_preco,
                               new_rec.cod_uni_feder,
                               new_rec.cod_cliente,
                               new_rec.cod_item)
)
