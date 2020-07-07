<?php

$bd = ifx_connect('logix','informix','informix');
$result= ifx_query('select distinct dat_hor_emissao from fat_nf_mestre',$bd);
print_r(ifx_fetch_row($result));

phpinfo();
?>