package br.com.teste.soap;

import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.XML;

import br.com.soap.MetodosSoap;

public class App {

	public static void main(String[] args) {
		
		String testeXMLPedido = " \r\n" + 
				"            <xs:schema id=\"NewDataSet\" xmlns=\"\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\">\r\n" + 
				"               <xs:element name=\"NewDataSet\" msdata:IsDataSet=\"true\" msdata:UseCurrentLocale=\"true\">\r\n" + 
				"                  <xs:complexType>\r\n" + 
				"                     <xs:choice minOccurs=\"0\" maxOccurs=\"unbounded\">\r\n" + 
				"                        <xs:element name=\"login\">\r\n" + 
				"                           <xs:complexType>\r\n" + 
				"                              <xs:sequence>\r\n" + 
				"                                 <xs:element name=\"retorno\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                              </xs:sequence>\r\n" + 
				"                           </xs:complexType>\r\n" + 
				"                        </xs:element>\r\n" + 
				"                        <xs:element name=\"pedidos\">\r\n" + 
				"                           <xs:complexType>\r\n" + 
				"                              <xs:sequence>\r\n" + 
				"                                 <xs:element name=\"num_pedido\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"tipo_pedido\" type=\"xs:unsignedByte\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"dt_emissao\" type=\"xs:dateTime\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"CNPJ_CPF_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"IE_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"nome_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"nome_fantasia_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"endereco_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"num_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"comp_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"bairro_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_mun_cliente\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"desc_mun_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"UF_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"CEP_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"IS_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cliente_cons_final\" type=\"xs:unsignedByte\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fone_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fax_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"contato_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fone_contato_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"email_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"endereco_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"num_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"comp_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"bairro_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_mun_cobranca_cliente\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"desc_mun_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"UF_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"CEP_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fone_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fax_cobranca_cliente\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"CNPJ_CPF_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"nome_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"endereco_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"bairro_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_mun_vendedor\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"desc_mun_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"UF_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"CEP_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fone_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"fax_vendedor\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_cond_pagto\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"desc_cond_pagto\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_portador\" type=\"xs:short\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"desc_portador\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"total_pedido\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"obs\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"obs_nota_fiscal\" type=\"xs:string\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"entrega_futura\" type=\"xs:unsignedByte\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"dt_cancelada\" type=\"xs:dateTime\" minOccurs=\"0\"/>\r\n" + 
				"                              </xs:sequence>\r\n" + 
				"                           </xs:complexType>\r\n" + 
				"                        </xs:element>\r\n" + 
				"                        <xs:element name=\"pedidos_i\">\r\n" + 
				"                           <xs:complexType>\r\n" + 
				"                              <xs:sequence>\r\n" + 
				"                                 <xs:element name=\"num_pedido\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"cod_produto\" type=\"xs:int\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"quant\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"quant_cancelada\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"preco_tabela\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"perc_desc\" type=\"xs:decimal\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"preco_unitario\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"total_bruto\" type=\"xs:decimal\" minOccurs=\"0\"/>\r\n" + 
				"                                 <xs:element name=\"total_liquido\" type=\"xs:double\" minOccurs=\"0\"/>\r\n" + 
				"                              </xs:sequence>\r\n" + 
				"                           </xs:complexType>\r\n" + 
				"                        </xs:element>\r\n" + 
				"                     </xs:choice>\r\n" + 
				"                  </xs:complexType>\r\n" + 
				"               </xs:element>\r\n" + 
				"            </xs:schema>\r\n" + 
				"            <diffgr:diffgram xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\" xmlns:diffgr=\"urn:schemas-microsoft-com:xml-diffgram-v1\">\r\n" + 
				"               <NewDataSet xmlns=\"\">\r\n" + 
				"                  <login diffgr:id=\"login1\" msdata:rowOrder=\"0\" diffgr:hasChanges=\"modified\">\r\n" + 
				"                     <retorno>Acesso liberado.</retorno>\r\n" + 
				"                  </login>\r\n" + 
				"                  <pedidos diffgr:id=\"pedidos1\" msdata:rowOrder=\"0\">\r\n" + 
				"                     <num_pedido>12910</num_pedido>\r\n" + 
				"                     <tipo_pedido>1</tipo_pedido>\r\n" + 
				"                     <dt_emissao>2020-03-20T00:00:00-03:00</dt_emissao>\r\n" + 
				"                     <CNPJ_CPF_cliente>03144060000176</CNPJ_CPF_cliente>\r\n" + 
				"                     <IE_cliente>132836696</IE_cliente>\r\n" + 
				"                     <nome_cliente>AGROPECUARIA RONCADOR S.A.</nome_cliente>\r\n" + 
				"                     <nome_fantasia_cliente>FAZENDA RONCADOR</nome_fantasia_cliente>\r\n" + 
				"                     <endereco_cliente>FAZENDA RONCADOR S/Nº</endereco_cliente>\r\n" + 
				"                     <num_cliente/>\r\n" + 
				"                     <comp_cliente/>\r\n" + 
				"                     <bairro_cliente>ZONA RURAL</bairro_cliente>\r\n" + 
				"                     <cod_mun_cliente>2398</cod_mun_cliente>\r\n" + 
				"                     <desc_mun_cliente>QUERENCIA</desc_mun_cliente>\r\n" + 
				"                     <UF_cliente>MT</UF_cliente>\r\n" + 
				"                     <CEP_cliente>78643000</CEP_cliente>\r\n" + 
				"                     <IS_cliente/>\r\n" + 
				"                     <cliente_cons_final>1</cliente_cons_final>\r\n" + 
				"                     <fone_cliente>6635291197</fone_cliente>\r\n" + 
				"                     <fax_cliente/>\r\n" + 
				"                     <contato_cliente>DANILO</contato_cliente>\r\n" + 
				"                     <fone_contato_cliente/>\r\n" + 
				"                     <email_cliente>matheus.gonzales@gruporoncador.com.br</email_cliente>\r\n" + 
				"                     <endereco_cobranca_cliente>CAIXA POSTAL</endereco_cobranca_cliente>\r\n" + 
				"                     <num_cobranca_cliente>97</num_cobranca_cliente>\r\n" + 
				"                     <comp_cobranca_cliente/>\r\n" + 
				"                     <bairro_cobranca_cliente>CX. POSTAL  - CORREIOS</bairro_cobranca_cliente>\r\n" + 
				"                     <cod_mun_cobranca_cliente>2398</cod_mun_cobranca_cliente>\r\n" + 
				"                     <desc_mun_cobranca_cliente>QUERENCIA</desc_mun_cobranca_cliente>\r\n" + 
				"                     <UF_cobranca_cliente>MT</UF_cobranca_cliente>\r\n" + 
				"                     <CEP_cobranca_cliente>78643000</CEP_cobranca_cliente>\r\n" + 
				"                     <fone_cobranca_cliente>6635291197</fone_cobranca_cliente>\r\n" + 
				"                     <fax_cobranca_cliente/>\r\n" + 
				"                     <CNPJ_CPF_vendedor>12678803000189</CNPJ_CPF_vendedor>\r\n" + 
				"                     <nome_vendedor>SRCAL MATRIZ</nome_vendedor>\r\n" + 
				"                     <endereco_vendedor>RUA 03</endereco_vendedor>\r\n" + 
				"                     <bairro_vendedor>CENTRO</bairro_vendedor>\r\n" + 
				"                     <cod_mun_vendedor>5100201</cod_mun_vendedor>\r\n" + 
				"                     <desc_mun_vendedor>AGUA BOA</desc_mun_vendedor>\r\n" + 
				"                     <UF_vendedor>MT</UF_vendedor>\r\n" + 
				"                     <CEP_vendedor>78635000</CEP_vendedor>\r\n" + 
				"                     <fone_vendedor>6634683912</fone_vendedor>\r\n" + 
				"                     <fax_vendedor>6634683912</fax_vendedor>\r\n" + 
				"                     <cod_cond_pagto>2</cod_cond_pagto>\r\n" + 
				"                     <desc_cond_pagto>DEPOSITO A VISTA</desc_cond_pagto>\r\n" + 
				"                     <cod_portador>0</cod_portador>\r\n" + 
				"                     <desc_portador xml:space=\"preserve\"></desc_portador>\r\n" + 
				"                     <total_pedido>494370</total_pedido>\r\n" + 
				"                     <obs>VENDA RONCADOR - DOLOMITICO (FECHAMNETO FINANCEIRO ] EM SP)</obs>\r\n" + 
				"                     <obs_nota_fiscal>PECUÁRIA EXPANSÃO Nº  ORDEM 041198</obs_nota_fiscal>\r\n" + 
				"                     <entrega_futura>0</entrega_futura>\r\n" + 
				"                  </pedidos>\r\n" + 
				"                  <pedidos diffgr:id=\"pedidos2\" msdata:rowOrder=\"1\">\r\n" + 
				"                     <num_pedido>12911</num_pedido>\r\n" + 
				"                     <tipo_pedido>1</tipo_pedido>\r\n" + 
				"                     <dt_emissao>2020-03-20T00:00:00-03:00</dt_emissao>\r\n" + 
				"                     <CNPJ_CPF_cliente>03144060000176</CNPJ_CPF_cliente>\r\n" + 
				"                     <IE_cliente>132836696</IE_cliente>\r\n" + 
				"                     <nome_cliente>AGROPECUARIA RONCADOR S.A.</nome_cliente>\r\n" + 
				"                     <nome_fantasia_cliente>FAZENDA RONCADOR</nome_fantasia_cliente>\r\n" + 
				"                     <endereco_cliente>FAZENDA RONCADOR S/Nº</endereco_cliente>\r\n" + 
				"                     <num_cliente/>\r\n" + 
				"                     <comp_cliente/>\r\n" + 
				"                     <bairro_cliente>ZONA RURAL</bairro_cliente>\r\n" + 
				"                     <cod_mun_cliente>2398</cod_mun_cliente>\r\n" + 
				"                     <desc_mun_cliente>QUERENCIA</desc_mun_cliente>\r\n" + 
				"                     <UF_cliente>MT</UF_cliente>\r\n" + 
				"                     <CEP_cliente>78643000</CEP_cliente>\r\n" + 
				"                     <IS_cliente/>\r\n" + 
				"                     <cliente_cons_final>1</cliente_cons_final>\r\n" + 
				"                     <fone_cliente>6635291197</fone_cliente>\r\n" + 
				"                     <fax_cliente/>\r\n" + 
				"                     <contato_cliente>DANILO</contato_cliente>\r\n" + 
				"                     <fone_contato_cliente/>\r\n" + 
				"                     <email_cliente>matheus.gonzales@gruporoncador.com.br</email_cliente>\r\n" + 
				"                     <endereco_cobranca_cliente>CAIXA POSTAL</endereco_cobranca_cliente>\r\n" + 
				"                     <num_cobranca_cliente>97</num_cobranca_cliente>\r\n" + 
				"                     <comp_cobranca_cliente/>\r\n" + 
				"                     <bairro_cobranca_cliente>CX. POSTAL  - CORREIOS</bairro_cobranca_cliente>\r\n" + 
				"                     <cod_mun_cobranca_cliente>2398</cod_mun_cobranca_cliente>\r\n" + 
				"                     <desc_mun_cobranca_cliente>QUERENCIA</desc_mun_cobranca_cliente>\r\n" + 
				"                     <UF_cobranca_cliente>MT</UF_cobranca_cliente>\r\n" + 
				"                     <CEP_cobranca_cliente>78643000</CEP_cobranca_cliente>\r\n" + 
				"                     <fone_cobranca_cliente>6635291197</fone_cobranca_cliente>\r\n" + 
				"                     <fax_cobranca_cliente/>\r\n" + 
				"                     <CNPJ_CPF_vendedor>12678803000189</CNPJ_CPF_vendedor>\r\n" + 
				"                     <nome_vendedor>SRCAL MATRIZ</nome_vendedor>\r\n" + 
				"                     <endereco_vendedor>RUA 03</endereco_vendedor>\r\n" + 
				"                     <bairro_vendedor>CENTRO</bairro_vendedor>\r\n" + 
				"                     <cod_mun_vendedor>5100201</cod_mun_vendedor>\r\n" + 
				"                     <desc_mun_vendedor>AGUA BOA</desc_mun_vendedor>\r\n" + 
				"                     <UF_vendedor>MT</UF_vendedor>\r\n" + 
				"                     <CEP_vendedor>78635000</CEP_vendedor>\r\n" + 
				"                     <fone_vendedor>6634683912</fone_vendedor>\r\n" + 
				"                     <fax_vendedor>6634683912</fax_vendedor>\r\n" + 
				"                     <cod_cond_pagto>2</cod_cond_pagto>\r\n" + 
				"                     <desc_cond_pagto>DEPOSITO A VISTA</desc_cond_pagto>\r\n" + 
				"                     <cod_portador>0</cod_portador>\r\n" + 
				"                     <desc_portador xml:space=\"preserve\"></desc_portador>\r\n" + 
				"                     <total_pedido>164790</total_pedido>\r\n" + 
				"                     <obs>VENDA RONCADOR - DOLOMITICO(FECHAMENTO FINANCEIRO EM SP)</obs>\r\n" + 
				"                     <obs_nota_fiscal>PECUÁRIA EXPANSÃO Nº ORDEM 041198</obs_nota_fiscal>\r\n" + 
				"                     <entrega_futura>0</entrega_futura>\r\n" + 
				"                  </pedidos>\r\n" + 
				"                  <pedidos diffgr:id=\"pedidos3\" msdata:rowOrder=\"2\">\r\n" + 
				"                     <num_pedido>13355</num_pedido>\r\n" + 
				"                     <tipo_pedido>1</tipo_pedido>\r\n" + 
				"                     <dt_emissao>2020-04-22T14:16:34-03:00</dt_emissao>\r\n" + 
				"                     <CNPJ_CPF_cliente>07859554020</CNPJ_CPF_cliente>\r\n" + 
				"                     <IE_cliente>132626543</IE_cliente>\r\n" + 
				"                     <nome_cliente>CELIO FRIES</nome_cliente>\r\n" + 
				"                     <nome_fantasia_cliente>FAZENDA AGUA BOA I</nome_fantasia_cliente>\r\n" + 
				"                     <endereco_cliente>MARG. DIREITA DA MT 240 18 KM DA SEDE</endereco_cliente>\r\n" + 
				"                     <num_cliente>SN</num_cliente>\r\n" + 
				"                     <comp_cliente/>\r\n" + 
				"                     <bairro_cliente>ZONA RURAL</bairro_cliente>\r\n" + 
				"                     <cod_mun_cliente>5100201</cod_mun_cliente>\r\n" + 
				"                     <desc_mun_cliente>AGUA BOA</desc_mun_cliente>\r\n" + 
				"                     <UF_cliente>MT</UF_cliente>\r\n" + 
				"                     <CEP_cliente>78635000</CEP_cliente>\r\n" + 
				"                     <IS_cliente/>\r\n" + 
				"                     <cliente_cons_final>1</cliente_cons_final>\r\n" + 
				"                     <fone_cliente>6699712461</fone_cliente>\r\n" + 
				"                     <fax_cliente>6634681254</fax_cliente>\r\n" + 
				"                     <contato_cliente/>\r\n" + 
				"                     <fone_contato_cliente/>\r\n" + 
				"                     <email_cliente>NAO TEM</email_cliente>\r\n" + 
				"                     <endereco_cobranca_cliente>AV: ARAGUAIA ESQ. 14</endereco_cobranca_cliente>\r\n" + 
				"                     <num_cobranca_cliente>787</num_cobranca_cliente>\r\n" + 
				"                     <comp_cobranca_cliente/>\r\n" + 
				"                     <bairro_cobranca_cliente>CENTRO</bairro_cobranca_cliente>\r\n" + 
				"                     <cod_mun_cobranca_cliente>5100201</cod_mun_cobranca_cliente>\r\n" + 
				"                     <desc_mun_cobranca_cliente>AGUA BOA</desc_mun_cobranca_cliente>\r\n" + 
				"                     <UF_cobranca_cliente>MT</UF_cobranca_cliente>\r\n" + 
				"                     <CEP_cobranca_cliente>78635000</CEP_cobranca_cliente>\r\n" + 
				"                     <fone_cobranca_cliente/>\r\n" + 
				"                     <fax_cobranca_cliente/>\r\n" + 
				"                     <CNPJ_CPF_vendedor>98151886153</CNPJ_CPF_vendedor>\r\n" + 
				"                     <nome_vendedor>ANDREA MARTINS DE SOUZA</nome_vendedor>\r\n" + 
				"                     <endereco_vendedor/>\r\n" + 
				"                     <bairro_vendedor/>\r\n" + 
				"                     <cod_mun_vendedor>5100201</cod_mun_vendedor>\r\n" + 
				"                     <desc_mun_vendedor>AGUA BOA</desc_mun_vendedor>\r\n" + 
				"                     <UF_vendedor>MT</UF_vendedor>\r\n" + 
				"                     <CEP_vendedor>78635000</CEP_vendedor>\r\n" + 
				"                     <fone_vendedor/>\r\n" + 
				"                     <fax_vendedor/>\r\n" + 
				"                     <cod_cond_pagto>6</cod_cond_pagto>\r\n" + 
				"                     <desc_cond_pagto>CHEQUE A VISTA</desc_cond_pagto>\r\n" + 
				"                     <cod_portador>0</cod_portador>\r\n" + 
				"                     <desc_portador xml:space=\"preserve\"></desc_portador>\r\n" + 
				"                     <total_pedido>7489.38</total_pedido>\r\n" + 
				"                     <obs>CHEQUE A VISTA</obs>\r\n" + 
				"                     <obs_nota_fiscal xml:space=\"preserve\"></obs_nota_fiscal>\r\n" + 
				"                     <entrega_futura>0</entrega_futura>\r\n" + 
				"                  </pedidos>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i1\" msdata:rowOrder=\"0\" diffgr:hasChanges=\"modified\">\r\n" + 
				"                     <num_pedido>12910</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>9000</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>56.5</preco_tabela>\r\n" + 
				"                     <perc_desc>2.7787611</perc_desc>\r\n" + 
				"                     <preco_unitario>54.93</preco_unitario>\r\n" + 
				"                     <total_bruto>508500</total_bruto>\r\n" + 
				"                     <total_liquido>494370</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i2\" msdata:rowOrder=\"1\" diffgr:hasChanges=\"modified\">\r\n" + 
				"                     <num_pedido>12911</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>3000</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>56.5</preco_tabela>\r\n" + 
				"                     <perc_desc>2.7787611</perc_desc>\r\n" + 
				"                     <preco_unitario>54.93</preco_unitario>\r\n" + 
				"                     <total_bruto>169500</total_bruto>\r\n" + 
				"                     <total_liquido>164790</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i3\" msdata:rowOrder=\"2\" diffgr:hasChanges=\"modified\">\r\n" + 
				"                     <num_pedido>13355</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>119.83</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>62.5</preco_tabela>\r\n" + 
				"                     <perc_desc>0.0000000</perc_desc>\r\n" + 
				"                     <preco_unitario>62.5</preco_unitario>\r\n" + 
				"                     <total_bruto>7489.375</total_bruto>\r\n" + 
				"                     <total_liquido>7489.38</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"               </NewDataSet>\r\n" + 
				"               <diffgr:before>\r\n" + 
				"                  <login diffgr:id=\"login1\" msdata:rowOrder=\"0\" xmlns=\"\">\r\n" + 
				"                     <retorno>Acesso liberado.</retorno>\r\n" + 
				"                  </login>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i1\" msdata:rowOrder=\"0\" xmlns=\"\">\r\n" + 
				"                     <num_pedido>12910</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>9000</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>56.5</preco_tabela>\r\n" + 
				"                     <perc_desc>0.0000000</perc_desc>\r\n" + 
				"                     <preco_unitario>54.93</preco_unitario>\r\n" + 
				"                     <total_bruto>0.00</total_bruto>\r\n" + 
				"                     <total_liquido>494370</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i2\" msdata:rowOrder=\"1\" xmlns=\"\">\r\n" + 
				"                     <num_pedido>12911</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>3000</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>56.5</preco_tabela>\r\n" + 
				"                     <perc_desc>0.0000000</perc_desc>\r\n" + 
				"                     <preco_unitario>54.93</preco_unitario>\r\n" + 
				"                     <total_bruto>0.00</total_bruto>\r\n" + 
				"                     <total_liquido>164790</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"                  <pedidos_i diffgr:id=\"pedidos_i3\" msdata:rowOrder=\"2\" xmlns=\"\">\r\n" + 
				"                     <num_pedido>13355</num_pedido>\r\n" + 
				"                     <cod_produto>46</cod_produto>\r\n" + 
				"                     <quant>119.83</quant>\r\n" + 
				"                     <quant_cancelada>0</quant_cancelada>\r\n" + 
				"                     <preco_tabela>62.5</preco_tabela>\r\n" + 
				"                     <perc_desc>0.0000000</perc_desc>\r\n" + 
				"                     <preco_unitario>62.5</preco_unitario>\r\n" + 
				"                     <total_bruto>0.00</total_bruto>\r\n" + 
				"                     <total_liquido>7489.38</total_liquido>\r\n" + 
				"                  </pedidos_i>\r\n" + 
				"               </diffgr:before>\r\n" + 
				"            </diffgr:diffgram>\r\n" + 
				"  ";
		
		
		/*
		 * Guarda os blocos Json convertidos , o XML vem fragmentado
		 *   por isso a necessidade de guardar em uma lista
		 */
		List<JSONObject> lDados= new ArrayList<JSONObject>();
		
		/*
		 * Json que receberá os dados tratados
		 */
		JSONObject JsonDadosPedidos = new JSONObject(); 
		
		try {
			/*
			 * Chama o metodo da lib do projeto clientSoapRoncador
			 *   que permite fazer o download dos pedidos
			 *   o retorno é uma lista com os blocos de XML  
			 */
			
			//List<String> lXML = new MetodosSoap("05872541000123", "mds123",false).getPedidos();
			
			/*
			 * usar essa parte para testes caso esteja usando 
			 *   a string com os valores fixos do pedido
			 */
			List<String> lXML = new ArrayList<String>();
			lXML.add(testeXMLPedido);
			
			/*
			 * Percorre a lista com os XMLs 
			 *   e faz a conversão para JSON
			 */
        	for(int i=0;i< lXML.size() ;i++) {
        		
        		/*
        		 * Realiza a conversão de String XML para JSON
        		 *   no bloco da lista
        		 */
        		JSONObject jDados = XML.toJSONObject(lXML.get(i));
        		//System.out.println(jDados.toString());
        		
        		/*
        		 *  Guarda o Json Convertido em uma lista
        		 */
        		lDados.add(jDados);
        		
        		JSONArray jPedidos = new App().getPedidoJSON(jDados);
        		
        		JSONArray jItensPedidos = new App().getItensPedidoJSON(jDados);
        		
        		if(jPedidos !=null) {
        			JsonDadosPedidos.put("pedidos", jPedidos);
        		}
        		
        		if(jItensPedidos !=null) {
        			JsonDadosPedidos.put("itens", jItensPedidos);
        		}
        		
        		/*
        		 * imprime no console os dados tratados 
        		 */
        		System.out.println(JsonDadosPedidos.toString());
        		
        	}
        	
        	
        	
		} catch (Exception e) {
			System.out.println("Erro no acesso :"+e.getMessage());
		}
	}
	
	public JSONArray getPedidoJSON(JSONObject jDados) throws JSONException{
	
		 /*
		  * busca o nó de pedidos dentro da estrutura 
		  *   verificando se os nós existem	  
		  */
		JSONArray jPedidos = new JSONArray();
		
		if(jDados.has("diffgr:diffgram")) {
			if(jDados.getJSONObject("diffgr:diffgram").has("NewDataSet")) {
				if(jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").has("pedidos")) {
					
					/*
					 * Valida se os pedidos são Obj ou Array
					 */
					Object obj = jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").get("pedidos");
										
					if (obj instanceof JSONArray) {
						jPedidos = (JSONArray) obj;
					}else {
						JSONObject jPedido = (JSONObject) obj;
						jPedidos.put(jPedido);
					}
					
					//System.out.println(jPedidos.toString());
				}
			}
		}
		
		return jPedidos;
		
	}

	public JSONArray getItensPedidoJSON(JSONObject jDados) throws JSONException{
		
		 /*
		  * busca o nó de itens dos pedidos dentro da estrutura 
		  *   verificando se os nós existem	  
		  */
		JSONArray jItensPedidos = new JSONArray();
		
		if(jDados.has("diffgr:diffgram")) {
			if(jDados.getJSONObject("diffgr:diffgram").has("NewDataSet")) {
				if(jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").has("pedidos_i")) {
					
					/*
					 * Valida se os itens dos pedidos são Obj ou Array
					 */
					Object obj = jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").get("pedidos_i");
										
					if (obj instanceof JSONArray) {
						jItensPedidos = (JSONArray) obj;
					}else {
						JSONObject jItemPedido = (JSONObject) obj;
						jItensPedidos.put(jItemPedido);
					}
					
					//System.out.println(jItensPedidos.toString());
				}
			}
		}
		
		return jItensPedidos;
		
	}

	
}
