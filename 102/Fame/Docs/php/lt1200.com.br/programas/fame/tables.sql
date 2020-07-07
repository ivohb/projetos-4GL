select b.colname,a.tabname from
systables a, syscolumns b
where b.tabid=a.tabid
and b.colname like "%cdrmneg%"
