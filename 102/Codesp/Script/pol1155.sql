 select * from periodos where cod_empresa = '01'
 select * from lanc_temp


	    SELECT UNIQUE a.den_sistema_ger, a.per_contabil,	a.cod_seg_periodo,a.num_lote, a.dat_movto,
			  a.ies_tip_lanc, a.num_conta,a.num_lanc, a.val_lanc, b.num_relacionto
			FROM lancamentos a, ctb_lanc_ctbl_ctb b
			WHERE a.cod_empresa = '01'
				AND a.dat_movto BETWEEN '01/11/2010' AND '10/11/2010'
				AND b.empresa = a.cod_empresa
				AND b.sistema_gerador = a.den_sistema_ger
				AND b.periodo_contab = a.per_contabil
				AND b.segmto_periodo = a.cod_seg_periodo
				AND b.lote_contab = a.num_lote
				AND b.num_lancto = a.num_lanc
				ORDER BY a.dat_movto, b.num_relacionto , a.num_lanc

select * from ctb_lanc_ctbl_ctb

	  SELECT UNIQUE num_seq_linha, tex_hist
              FROM hist_compl --, ctb_lanc_ctbl_ctb
		 WHERE hist_compl.cod_empresa		  =	'01'
			 AND hist_compl.den_sistema_ger	=	'CON'
			 AND hist_compl.per_contabil	=	'2010'
			 AND hist_compl.cod_seg_periodo	=	11
			 AND hist_compl.num_lote	=	758
                          and hist_compl.num_lanc        in     ( 3751629, 3751630)
			 AND num_relacionto 		=       1
			 AND empresa                    = hist_compl.cod_empresa
			 AND sistema_gerador            = hist_compl.den_sistema_ger
			 AND periodo_contab             = hist_compl.per_contabil
			 AND segmto_periodo             = hist_compl.cod_seg_periodo
			 AND lote_contab                = hist_compl.num_lote
			 AND num_lancto                 = hist_compl.num_lanc
		 ORDER BY hist_compl.num_seq_linha

 select * from lanc_temp order by dat_movto

 select * from lanc_temp where dat_movto = '03/11/2010'


