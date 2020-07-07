unload to ajuste.sql
select  "update lt1200_hist_comis set zona='"||trim(cdfilial)||"' where cod_repres="||cod||" and ano_ref='2006';"
 from vnpfisic
