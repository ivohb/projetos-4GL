select * from fat_nf_mestre where empresa = '21'
select * from fat_nf_item where empresa = '21' and trans_nota_fiscal in (
 select trans_nota_fiscal from fat_nf_mestre where empresa = '21')

 select * from minuta_cairu
  select * from controle_cairu

