
SELECT (TO_CHAR(a.dat_hor_proces, 'dd/mm/yyyy')),a.nom_usuario, count(a.num_aviso_rec)
FROM audit_ar a
WHERE  TO_CHAR(a.dat_hor_proces, 'dd/mm/yyyy')='05/06/2013'
AND a.num_seq = 0
AND a.ies_tipo_auditoria = '1'
AND a.num_prog='SUP3760'
AND a.num_aviso_rec NOT IN (SELECT b.num_aviso_rec FROM audit_ar b
                            WHERE a.cod_empresa=b.cod_empresa
                            AND a.num_aviso_rec=b.num_aviso_rec
                            AND b.num_seq = 0
                            AND b.ies_tipo_auditoria = '5'
                            AND b.num_prog='SUP3760')
GROUP BY (TO_CHAR(a.dat_hor_proces, 'dd/mm/yyyy')),a.nom_usuario