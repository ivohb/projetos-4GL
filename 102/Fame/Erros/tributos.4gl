
			//VERIFICA SE A NAT_OPER / ITEM POSSUEM PARAMETROS FISCAIS

			//IPI
			$rs_ipi=$db->Execute("SELECT aliquota
	                            FROM OBF_CONFIG_FISCAL
	                            WHERE empresa='".$pedido_dados['cod_empresa']."'
	                            AND tributo_benef='IPI'
	                            AND nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
	                            AND (grp_fiscal_cliente IN (SELECT grp_fiscal_cliente FROM OBF_GRP_FISC_CLI WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND cliente='".$pedido_dados['cod_cliente']."') OR grp_fiscal_cliente IS NULL)
	                            AND (cliente ='".$pedido_dados['cod_cliente']."' OR cliente IS NULL)
	                            AND (grupo_fiscal_item IN (SELECT grupo_fiscal_item FROM OBF_GRP_FISC_ITEM WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND item='".$rs->fields['cod_item']."') OR grupo_fiscal_item IS NULL)
	                            AND (item = '".$rs->fields['cod_item']."' OR item IS NULL)
	                            AND (linha_produto = ".round($rs->fields['cod_lin_prod'])." OR linha_produto IS null)
	                            AND (linha_receita = ".round($rs->fields['cod_lin_recei'])." OR linha_receita IS null)
	                            AND (segmto_mercado = ".round($rs->fields['cod_seg_merc'])." OR segmto_mercado IS null)
	                            AND (classe_uso = ".round($rs->fields['cod_cla_uso'])." OR classe_uso IS null)
	                            AND (grp_fiscal_classif IN (SELECT grupo_classif_fisc FROM obf_grp_cl_fisc WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef  AND classif_fisc='".$rs->fields['cod_cla_fisc']."') OR grp_fiscal_classif IS NULL)
	                            AND (classif_fisc = '".$rs->fields['cod_cla_fisc']."' OR classif_fisc IS NULL)
	                            ORDER BY item desc, grupo_fiscal_item desc,linha_produto desc,linha_receita desc,segmto_mercado desc,classe_uso desc, classif_fisc desc, grp_fiscal_classif desc,cliente desc, grp_fiscal_cliente desc   ");
			if(!$rs_ipi->EOF)
			{
				$valor_total_ipi = $valor_total_ipi + ($rs->fields['pre_item']*($rs_ipi->fields['aliquota']/100));
			}
			else
			{   	
				$qry = "select * from obf_oper_fiscal  where
							empresa='".$_SESSION['cod_empresa']."'
							and origem='S'
							and nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
							and tributo_benef = 'IPI' ";
				$resImposto = $db->Execute($qry);
				
				if(!$resImposto->EOF){
				
					$erroImpostos = true;
					$motivo="ITEM ".trim($rs->fields['cod_item'])."(".round($rs->fields['num_sequencia']).") NAO POSSUI PARAMETRO FISCAL DE IPI";
					$insert="insert into pedido_msg
                         (cod_empresa, num_pedido, ies_tip_consist, txt_mensagem, nom_usuario)
                         values
                         ('".$pedido_dados['cod_empresa']."', ".$pedido_dados['num_pedido'].", 'C', '".$motivo."', '".$_SESSION['cod_usuario']."')";
					$db->Execute($insert);
					$ctr_aprova++;
					$txt_motivos.="<br>".$motivo;
				}
			}
			 
			// ICMS
			$rs_icm=$db->Execute("    SELECT aliquota
                                FROM OBF_CONFIG_FISCAL
                                WHERE empresa='".$pedido_dados['cod_empresa']."'
                                AND tributo_benef='ICMS'
                                AND nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
                                AND (grp_fiscal_regiao IN (SELECT regiao_fiscal FROM OBF_REGIAO_FISCAL WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND estado='".$cliente_dados['cod_uni_feder']."') OR grp_fiscal_regiao IS NULL)
								                
								                AND (municipio='".$cliente_dados['cod_cidade']."' OR municipio IS NULL)
                                AND (estado = '".$cliente_dados['cod_uni_feder']."' OR estado IS null)
                                AND (finalidade=".round($pedido_dados['ies_finalidade'],0)." or finalidade IS NULL)
                                AND (familia_item = '".$rs->fields['cod_familia']."' OR familia_item IS NULL)
                                AND (grp_fiscal_cliente IN (SELECT grp_fiscal_cliente FROM OBF_GRP_FISC_CLI WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND cliente='".$pedido_dados['cod_cliente']."') OR grp_fiscal_cliente IS NULL)
                                AND (cliente ='".$pedido_dados['cod_cliente']."' OR cliente IS NULL)
                                AND (grupo_fiscal_item IN (SELECT grupo_fiscal_item FROM OBF_GRP_FISC_ITEM WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND item='".$rs->fields['cod_item']."') OR grupo_fiscal_item IS NULL)
                                AND (item = '".$rs->fields['cod_item']."' OR item IS NULL)
                                AND (linha_produto = ".round($rs->fields['cod_lin_prod'])." OR linha_produto IS null)
                                AND (linha_receita = ".round($rs->fields['cod_lin_recei'])." OR linha_receita IS null)
                                AND (segmto_mercado = ".round($rs->fields['cod_seg_merc'])." OR segmto_mercado IS null)
                                AND (classe_uso = ".round($rs->fields['cod_cla_uso'])." OR classe_uso IS null)
                                AND (grp_fiscal_classif IN (SELECT grupo_classif_fisc FROM obf_grp_cl_fisc WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef  AND classif_fisc='".$rs->fields['cod_cla_fisc']."') OR grp_fiscal_classif IS NULL)
                                AND (classif_fisc = '".$rs->fields['cod_cla_fisc']."' OR classif_fisc IS NULL)
                                ORDER BY item desc,familia_item desc,grupo_fiscal_item desc,classif_fisc desc,grp_fiscal_classif desc,cliente desc,grp_fiscal_cliente desc,municipio desc,estado desc, grp_fiscal_regiao desc,finalidade desc;   ");
			if($rs_icm->EOF)
			{
				$qry = "select * from obf_oper_fiscal  where
							empresa='".$_SESSION['cod_empresa']."'
							and origem='S'
							and nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
							and tributo_benef = 'ICMS' ";
				$resImposto = $db->Execute($qry);
				
				if(!$resImposto->EOF){
				
					$erroImpostos = true;
					$motivo="ITEM ".trim($rs->fields['cod_item'])."(".round($rs->fields['num_sequencia']).") NAO POSSUI PARAMETRO FISCAL DE ICMS";
					$insert="insert into pedido_msg
                         (cod_empresa, num_pedido, ies_tip_consist, txt_mensagem, nom_usuario)
                         values
                         ('".$pedido_dados['cod_empresa']."', ".$pedido_dados['num_pedido'].", 'C', '".$motivo."', '".$_SESSION['cod_usuario']."')";
					$db->Execute($insert);
					$ctr_aprova++;
					$txt_motivos.="<br>".$motivo;
				}
			}
		
			// PIS
			$rs_pis=$db->Execute("SELECT aliquota
                                FROM OBF_CONFIG_FISCAL
                                WHERE empresa='".$pedido_dados['cod_empresa']."'
                                AND tributo_benef='PIS_REC'
                                AND nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
                                AND (grp_fiscal_regiao IN (SELECT regiao_fiscal FROM OBF_REGIAO_FISCAL WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND estado='".$cliente_dados['cod_uni_feder']."') OR grp_fiscal_regiao IS NULL)
                                AND (estado = '".$cliente_dados['cod_uni_feder']."' OR estado IS null)
                                AND (finalidade=".round($pedido_dados['ies_finalidade'],0)." or finalidade IS NULL)
                                AND (familia_item = '".$rs->fields['cod_familia']."' OR familia_item IS NULL)
                                AND (grp_fiscal_cliente IN (SELECT grp_fiscal_cliente FROM OBF_GRP_FISC_CLI WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND cliente='".$pedido_dados['cod_cliente']."') OR grp_fiscal_cliente IS NULL)
                                AND (cliente ='".$pedido_dados['cod_cliente']."' OR cliente IS NULL)
                                AND (grupo_fiscal_item IN (SELECT grupo_fiscal_item FROM OBF_GRP_FISC_ITEM WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND item='".$rs->fields['cod_item']."') OR grupo_fiscal_item IS NULL)
                                AND (item = '".$rs->fields['cod_item']."' OR item IS NULL)
                                AND (linha_produto = ".round($rs->fields['cod_lin_prod'])." OR linha_produto IS null)
                                AND (linha_receita = ".round($rs->fields['cod_lin_recei'])." OR linha_receita IS null)
                                AND (segmto_mercado = ".round($rs->fields['cod_seg_merc'])." OR segmto_mercado IS null)
                                AND (classe_uso = ".round($rs->fields['cod_cla_uso'])." OR classe_uso IS null)
                                AND (grp_fiscal_classif IN (SELECT grupo_classif_fisc FROM obf_grp_cl_fisc WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef  AND classif_fisc='".$rs->fields['cod_cla_fisc']."') OR grp_fiscal_classif IS NULL)
                                AND (classif_fisc = '".$rs->fields['cod_cla_fisc']."' OR classif_fisc IS NULL)
                                ORDER BY item desc,familia_item desc,grupo_fiscal_item desc,classif_fisc desc,grp_fiscal_classif desc,cliente desc,grp_fiscal_cliente desc,estado desc, grp_fiscal_regiao desc,finalidade desc;   ");
			if($rs_pis->EOF)
			{
				
				$qry = "select * from obf_oper_fiscal  where
							empresa='".$_SESSION['cod_empresa']."'
							and origem='S'
							and nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
							and tributo_benef = 'PIS_REC' ";
				$resImposto = $db->Execute($qry);
				
				if(!$resImposto->EOF){
				
					$erroImpostos = true;
					$motivo="ITEM ".trim($rs->fields['cod_item'])."(".round($rs->fields['num_sequencia']).") NAO POSSUI PARAMETRO FISCAL DE PIS";
					$insert="insert into pedido_msg
                         (cod_empresa, num_pedido, ies_tip_consist, txt_mensagem, nom_usuario)
                         values
                         ('".$pedido_dados['cod_empresa']."', ".$pedido_dados['num_pedido'].", 'C', '".$motivo."', '".$_SESSION['cod_usuario']."')";
					$db->Execute($insert);
					$ctr_aprova++;
					$txt_motivos.="<br>".$motivo;
				}
			}
		
			// COFINS
			$rs_cof=$db->Execute("SELECT aliquota
                                FROM OBF_CONFIG_FISCAL
                                WHERE empresa='".$pedido_dados['cod_empresa']."'
                                AND tributo_benef='COFINS_REC'
                                AND nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
                                AND (grp_fiscal_regiao IN (SELECT regiao_fiscal FROM OBF_REGIAO_FISCAL WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND estado='".$cliente_dados['cod_uni_feder']."') OR grp_fiscal_regiao IS NULL)
                                AND (estado = '".$cliente_dados['cod_uni_feder']."' OR estado IS null)
                                AND (finalidade=".round($pedido_dados['ies_finalidade'],0)." or finalidade IS NULL)
                                AND (familia_item = '".$rs->fields['cod_familia']."' OR familia_item IS NULL)
                                AND (grp_fiscal_cliente IN (SELECT grp_fiscal_cliente FROM OBF_GRP_FISC_CLI WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND cliente='".$pedido_dados['cod_cliente']."') OR grp_fiscal_cliente IS NULL)
                                AND (cliente ='".$pedido_dados['cod_cliente']."' OR cliente IS NULL)
                                AND (grupo_fiscal_item IN (SELECT grupo_fiscal_item FROM OBF_GRP_FISC_ITEM WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef AND item='".$rs->fields['cod_item']."') OR grupo_fiscal_item IS NULL)
                                AND (item = '".$rs->fields['cod_item']."' OR item IS NULL)
                                AND (linha_produto = ".round($rs->fields['cod_lin_prod'])." OR linha_produto IS null)
                                AND (linha_receita = ".round($rs->fields['cod_lin_recei'])." OR linha_receita IS null)
                                AND (segmto_mercado = ".round($rs->fields['cod_seg_merc'])." OR segmto_mercado IS null)
                                AND (classe_uso = ".round($rs->fields['cod_cla_uso'])." OR classe_uso IS null)
                                AND (grp_fiscal_classif IN (SELECT grupo_classif_fisc FROM obf_grp_cl_fisc WHERE empresa=OBF_CONFIG_FISCAL.empresa AND tributo_benef=OBF_CONFIG_FISCAL.tributo_benef  AND classif_fisc='".$rs->fields['cod_cla_fisc']."') OR grp_fiscal_classif IS NULL)
                                AND (classif_fisc = '".$rs->fields['cod_cla_fisc']."' OR classif_fisc IS NULL)
                                ORDER BY item desc,familia_item desc,grupo_fiscal_item desc,classif_fisc desc,grp_fiscal_classif desc,cliente desc,grp_fiscal_cliente desc,estado desc, grp_fiscal_regiao desc,finalidade desc;   ");
			if($rs_cof->EOF)
			{
				
				$qry = "select * from obf_oper_fiscal  where
							empresa='".$_SESSION['cod_empresa']."'
							and origem='S'
							and nat_oper_grp_desp=".$pedido_dados['cod_nat_oper']."
							and tributo_benef = 'COFINS_REC' ";
				$resImposto = $db->Execute($qry);
				
				if(!$resImposto->EOF){
				
					$erroImpostos = true;
					$motivo="ITEM ".trim($rs->fields['cod_item'])."(".round($rs->fields['num_sequencia']).") NAO POSSUI PARAMETRO FISCAL DE COFINS";
					$insert="insert into pedido_msg
                         (cod_empresa, num_pedido, ies_tip_consist, txt_mensagem, nom_usuario)
                         values
                         ('".$pedido_dados['cod_empresa']."', ".$pedido_dados['num_pedido'].", 'C', '".$motivo."', '".$_SESSION['cod_usuario']."')";
					$db->Execute($insert);
					$ctr_aprova++;
					$txt_motivos.="<br>".$motivo;
				}
			}
						
			$rs->MoveNext();
		