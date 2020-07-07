<?php
/* #############################################################################
   Programa: Plugin Logix Web
   Versуo: PW_VERSION
   Arquivo: class_ad_pw.php
   Data: 04/09/2008
   Desenvolvedor: Marcelo Gonчalves Peres
   Comentсrio: Classe para manutenчуo de AD's.
   ############################################################################# */
class Ad{
	protected $db, $cod_empresa, $num_ad, $cod_tip_despesa, $ser_nf, $ssr_nf, $num_nf, 
			  $dat_emis_nf, $dat_rec_nf, $cod_empresa_estab, $mes_ano_compet, $num_ord_forn,
			  $cnd_pgto, $dat_venc, $cod_fornecedor, $cod_portador, $val_tot_nf, $val_saldo_ad,
			  $cod_moeda, $set_aplicacao, $cod_lote_pgto, $observ, $cod_tip_ad, $ies_ap_autom,
			  $ies_sup_cap, $ies_fatura, $ies_ad_cont, $num_lote_transf, $ies_dep_cred, $num_lote_pat,
			  $cod_empresa_orig;
	
	public function Ad($db, $cod_empresa, $num_ad)
		{
		$this->db=$db;
		$rs=$this->db->Execute("select a.cod_empresa, a.num_ad, a.cod_tip_despesa, a.ser_nf, a.ssr_nf, a.num_nf, 
									   a.dat_emis_nf, a.dat_rec_nf, a.cod_empresa_estab, a.mes_ano_compet, a.num_ord_forn,
									   a.cnd_pgto, a.dat_venc, a.cod_fornecedor, a.cod_portador, a.val_tot_nf, a.val_saldo_ad,
									   a.cod_moeda, a.set_aplicacao, a.cod_lote_pgto, a.observ, a.cod_tip_ad, a.ies_ap_autom,
									   a.ies_sup_cap, a.ies_fatura, a.ies_ad_cont, a.num_lote_transf, a.ies_dep_cred, a.num_lote_pat,
									   a.cod_empresa_orig
				  				from ad_mestre a
				  				where a.cod_empresa='".$cod_empresa."'
				  					  and a.num_ad=".$num_ad);
		
		$rs->fields=array_map("trim", $rs->fields);
		foreach($rs->fields as $chave=>$valor)
			{
			$this->$chave=$valor;
			}
		}
	
	public function Get_dados()
		{
		if(is_null($this->num_ad))
			{
			return false;
			}
		$dados=array();
		foreach($this as $chave=>$valor)
			{
			$dados[$chave]=$valor; 
			}
		array_shift($dados);
		$dados['dat_emis_nf']=$this->db->UserDate($dados['dat_emis_nf'], DATE);
		$dados['dat_rec_nf']=$this->db->UserDate($dados['dat_rec_nf'], DATE);
		$dados['dat_venc']=$this->db->UserDate($dados['dat_venc'], DATE);
		return $dados;
		}
		
	public function Get_inss()
		{
		$rs=$this->db->Execute("select dat_venc_inss,num_ad_pg_inss,val_base_calc_inss,val_reten_inss
								from reten_inss
								where cod_empresa='".$this->cod_empresa."'
									  and cod_fornecedor='".$this->cod_fornecedor."'
								      and num_ad_nf_orig in (".$this->num_ad.",".$this->num_nf.")
								      and ser_nf = '".$this->ser_nf."'
								      and ssr_nf = ".$this->ssr_nf);
		if($rs && !$rs->EOF)
			{
			return $rs->fields;
			}
		else
			{
			return null;
			}
		}
		
	public function Get_inss_auton()
		{
		$rs=$this->db->Execute("select ad_pagto_inss,dat_vencto_inss,val_bas_calc,val_inss
								from cap_ret_inss_auton
								where empresa='".$this->cod_empresa."'
									  and fornecedor='".$this->cod_fornecedor."'
								      and ad_nf_origem in (".$this->num_ad.",".$this->num_nf.")
								      and serie_nota_fiscal = '".$this->ser_nf."'
								      and subserie_nf = ".$this->ssr_nf);
		if($rs && !$rs->EOF)
			{
			return $rs->fields;
			}
		else
			{
			return null;
			}
		}
		
	public function Get_irrf()
		{
		$rs=$this->db->Execute("select num_nf,ies_especie_nf,val_base_calc,val_irrf
								from reten_irrf_pg
								where cod_empresa='".$this->cod_empresa."'
									  and cod_fornecedor='".$this->cod_fornecedor."'
								      and num_ad = ".$this->num_ad."
								      and num_nf = ".$this->num_nf."
								      and ser_nf = '".$this->ser_nf."'
								      and ssr_nf = ".$this->ssr_nf);
		if($rs && !$rs->EOF)
			{
			return $rs->fields;
			}
		else
			{
			return null;
			}
		}
		
	public function Get_iss()
		{
		$rs=$this->db->Execute("select dat_venc_iss,num_ad_pg_iss,val_base_calc_iss,val_reten_iss,ies_especie_nf
								from reten_iss
								where cod_empresa='".$this->cod_empresa."'
									  and cod_fornecedor='".$this->cod_fornecedor."'
								      and num_ad_nf_orig in (".$this->num_ad.",".$this->num_nf.")
								      and ser_nf = '".$this->ser_nf."'
								      and ssr_nf = ".$this->ssr_nf);
		if($rs && !$rs->EOF)
			{
			return $rs->fields;
			}
		else
			{
			return null;
			}
		}
		
	public function Aprova($cod_nivel_autor=null)
		{
		$rs=$this->db->Execute("select count(*) as existe
								from aprov_necessaria
								where cod_empresa='".$this->cod_empresa."'
									  and num_ad=".$this->num_ad."
									  and ies_aprovado='N'
									  and cod_nivel_autor='".$cod_nivel_autor."'");
		if($rs && !$rs->EOF && $rs->fields['existe']==1)
			{
			$this->db->BeginTrans();
			
			$ok=$this->db->Execute("update aprov_necessaria set
									ies_aprovado='S',
									cod_usuario_aprov='".$_SESSION['cod_usuario']."',
									dat_aprovacao='".date(DATE)."',
									hor_aprovacao='".date("H:i:s")."',
									observ_aprovacao='POLW001'
									where cod_empresa='".$this->cod_empresa."'
										  and num_ad=".$this->num_ad."
										  and cod_nivel_autor='".$cod_nivel_autor."'");
			/*
			$ok=$ok&&$this->db->Execute("update ad_mestre set
										 dat_rec_nf='".date(DATE)."'
										 where cod_empresa='".$this->cod_empresa."'
									  		   and num_ad=".$this->num_ad);
			*/
			
			
			$rs=$this->db->Execute("select count(*) as falta from aprov_necessaria where cod_empresa='".$this->cod_empresa."' and num_ad=".$this->num_ad." and ies_aprovado='N'");
			
			if($rs && !$rs->EOF && $rs->fields['falta']==0)
				{
				$ok=$ok&&$this->db->Execute("update ap set
											ies_lib_pgto_cap='N'
											where cod_empresa='".$this->cod_empresa."'
											      and ies_versao_atual='S'
											      and num_ap in (select num_ap 
											      				 from ad_ap 
											      				 where cod_empresa='".$this->cod_empresa."'
											      				 	   and num_ad=".$this->num_ad.")");
				// Solicitaчуo Manuel a partir do chamado TDWRLC
				if(substr(trim($this->observ),0,3) == 'SG=' && substr(trim($this->observ),3,1) !== false)
					{
					$ok=$ok&&$this->db->Execute("update ad_mestre set
												 ies_sup_cap='".substr(trim($this->observ),3,1)."'
												 where cod_empresa ='".$this->cod_empresa."'
												 	   and num_ad=".$this->num_ad);		
					}
				else 
					{
					$ok=$ok&&$this->db->Execute("update ad_mestre set
												 ies_sup_cap='C'
												 where cod_empresa ='".$this->cod_empresa."'
												 	   and num_ad=".$this->num_ad);		
					}
				/*
				if($this->ies_sup_cap=='B' || $this->ies_sup_cap=='Q')
					{
					$ok=$ok&&$this->db->Execute("update ad_mestre set
												 ies_sup_cap='".(($this->ies_sup_cap=='B')?'S':'C')."'
												 where cod_empresa ='".$this->cod_empresa."'
												 	   and num_ad=".$this->num_ad);	
					}
				*/	
				$rs=$this->db->Execute("SELECT ies_quando_contab FROM tipo_despesa WHERE cod_empresa='".$this->cod_empresa."' AND cod_tip_despesa=".$this->cod_tip_despesa);
				
				if($rs && !$rs->EOF && trim($rs->fields['ies_quando_contab'])=='C')
					{
					$ok=$ok&&$this->db->Execute("UPDATE lanc_cont_cap SET ies_liberad_contab='S'
												 WHERE cod_empresa='".$this->cod_empresa."'
												 AND ies_ad_ap='1'
												 AND num_ad_ap=".$this->num_ad);
					}
				}
			
			$this->db->CommitTrans($ok);
				
			return $ok;
			}
		else
			{
			return null;
			}
		}
		
	public function Get_item()
		{
		$rs_item=$this->db->Execute("select a.cod_empresa_estab,a.num_nf,b.qtd_recebida,b.pre_unit_nf,b.val_contabil_item,
									        b.num_pedido, b.num_oc, b.cod_item, b.den_item, c.num_conta_deb_desp
									 from nf_sup a
									      inner join aviso_rec b on b.cod_empresa=a.cod_empresa
									     			    		 and b.num_aviso_rec=a.num_aviso_rec
									      inner join dest_aviso_rec4 c on c.cod_empresa=b.cod_empresa
									     				 			   and c.num_aviso_rec=b.num_aviso_rec
									                                   and c.num_seq=b.num_seq
									 where a.cod_empresa='".$this->cod_empresa."'
									       and a.num_nf=".$this->num_nf."
									       and a.ser_nf = '".((trim($this->ser_nf)=='' or is_null($this->ser_nf))? "" : $this->ser_nf)."'
								      	   and a.ssr_nf = ".((trim($this->ssr_nf)=='' or is_null($this->ssr_nf))? "0" : $this->ssr_nf)."
									       and a.cod_fornecedor='".$this->cod_fornecedor."'");
		if(!$rs_item || $rs_item->EOF)
			{
			return null;
			}
		else
			{
			return $rs_item->GetArray();
			}
		
		}
		
	public function GetPisCofinsCsl()
		{
		$par_ies = array();
		$rs=$this->db->Execute("select pis.parametro_booleano as ies_contrib_pis,
								       cofins.parametro_booleano as ies_contrib_cofins,
								       csl.parametro_booleano as ies_contrib_csl
								from sup_par_fornecedor pis,
								     sup_par_fornecedor cofins,
								     sup_par_fornecedor csl
								where pis.fornecedor='".$this->cod_fornecedor."'
								      and pis.parametro='ies_contrib_pis'
								      and cofins.fornecedor='".$this->cod_fornecedor."'
								      and cofins.parametro='ies_contrib_cofins'
								      and csl.fornecedor='".$this->cod_fornecedor."'
								      and csl.parametro='ies_contrib_csl'");
		if(!$rs || $rs->EOF)
			{
			$par_ies['ies_contrib_pis']='N';
			$par_ies['ies_contrib_cofins']='N';
			$par_ies['ies_contrib_csl']='N';
			}
		else
			{
			$par_ies['ies_contrib_pis']=$rs->fields['ies_contrib_pis'];
			$par_ies['ies_contrib_cofins']=$rs->fields['ies_contrib_cofins'];
			$par_ies['ies_contrib_csl']=$rs->fields['ies_contrib_csl'];	
			}
			
		$rs=$this->db->Execute("select autoriz_pagto,dat_vencto,
							           ad_pagto_pis,val_bas_calc_pis,val_retencao_pis,
							           ad_pagto_cofins,val_bc_cofins,val_ret_cofins,
							           ad_pagto_csl,val_bas_calc_csl,val_retencao_csl
							    from cap_pis_cofins_csl
							    where empresa='".$this->cod_empresa."'
							   		  and autoriz_pagto in (select num_ap from ad_ap where num_ad=".$this->num_ad.")");
		if(!$rs || $rs->EOF)
			{
			$pis_cofins_csl = array("autoriz_pagto"=>"","dat_vencto"=>"",
								     "ad_pagto_pis"=>"","val_bas_calc_pis"=>"","val_retencao_pis"=>"",
								     "ad_pagto_cofins"=>"","val_bc_cofins"=>"","val_ret_cofins"=>"",
								     "ad_pagto_csl"=>"","val_bas_calc_csl"=>"","val_retencao_csl"=>"");
			}
		else
			{
			$pis_cofins_csl = $rs->FetchRow();
			}
		
		return array_merge($par_ies,$pis_cofins_csl);
			
		}
	
}
?>