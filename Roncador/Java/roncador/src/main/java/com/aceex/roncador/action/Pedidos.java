package main.java.com.aceex.roncador.action;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;

import com.google.gson.Gson;

import br.com.soap.MetodosSoap;
import main.java.com.aceex.roncador.dao.ClientesDao;
import main.java.com.aceex.roncador.dao.EmpresaDao;
import main.java.com.aceex.roncador.dao.FabricaDao;
import main.java.com.aceex.roncador.dao.ParametrosDao;
import main.java.com.aceex.roncador.dao.PedComplSicalDao;
import main.java.com.aceex.roncador.dao.PedItemSicalDao;
import main.java.com.aceex.roncador.dao.PedidoErroDao;
import main.java.com.aceex.roncador.dao.PedidoSicalDao;
import main.java.com.aceex.roncador.dao.PedidosDao;
import main.java.com.aceex.roncador.model.CliCanalVenda;
import main.java.com.aceex.roncador.model.Empresa;
import main.java.com.aceex.roncador.model.NatOperSical;
import main.java.com.aceex.roncador.model.Parvdp;
import main.java.com.aceex.roncador.model.PedComplSical;
import main.java.com.aceex.roncador.model.PedItemSical;
import main.java.com.aceex.roncador.model.Pedido;
import main.java.com.aceex.roncador.model.PedidoErro;
import main.java.com.aceex.roncador.model.PedidoSical;
import main.java.com.aceex.roncador.util.Arquivo;
import main.java.com.aceex.roncador.util.Biblioteca;

public class Pedidos {

	private List<PedItemSical> itens;
	private List<PedidoSical> pedidos;
	private List<PedComplSical> pedCompls;

	private PedidoSical pedSical;
	private PedidoErro pe;
	private String codEmpresa;
	private String cnpj;
	private String cnpjEmpressa;
	private String datCorte;
	
	private List<PedidoErro> erros;

	private Pedido pedidoLogix;
	private Parvdp parvdp;
	private CliCanalVenda cliCanal;

	private Biblioteca bib = new Biblioteca();
	private FabricaDao fd = new FabricaDao();
	private PedidoErroDao peDao;
	private ParametrosDao paramDao;	

	private static Logger log = Logger.getLogger(Pedidos.class);
	
	public Pedidos() {}
	
	public void execute() {

		EmpresaDao eDao = fd.getEmpresaDao();
		
		try {
			List<Empresa> empresas = eDao.getEmpresas();
			for (Empresa empresa : empresas) {
				cnpjEmpressa = empresa.getCnpj();
				cnpj = bib.tiraFormato(cnpjEmpressa);
				datCorte = empresa.getDatCorte();				
				
				if (cnpj.length() == 15) {
					cnpj = cnpj.substring(1, 15);
				}
				codEmpresa = empresa.getCodigo();	
				log.info("empresa: "+codEmpresa+" Cnpj: "+cnpj+" Corte: "+datCorte);
				processa();
			}		

		} catch (SQLException e1) {
			log.info(e1.getMessage()+" "+e1.getCause());
			log.info(new RuntimeException(e1));
			e1.printStackTrace();
		}
	}
	
	private void processa() {

		itens = new ArrayList<PedItemSical>();
		pedidos = new ArrayList<PedidoSical>();
		pedCompls = new ArrayList<PedComplSical>();

		try {
			buscaPedidos();
			gravaPedidos();			
			consistir();
			integrar();
		} catch (Exception e) {
			log.info("Erro: Pedidos.processa - "+e.getMessage()+" "+e.getCause());
			log.info(new RuntimeException(e));
			e.printStackTrace();
		}				
		
	}
	
	private void buscaPedidos() throws Exception {		

		PedItemSical[] pedItens = null;
		PedidoSical[] pedsSical = null;		
		Gson gson = new Gson();

		log.info("Leitura do XML");
		List<String> lXML = new MetodosSoap(cnpj,"mds123",false).getPedidos();
		//String xmlBase = new Arquivo().getArquivo();
		//List<String> lXML = new ArrayList<String>();		
		//lXML.add(xmlBase);

		log.info("Leitura do XML concluida");
				

    	for(int i=0;i< lXML.size() ;i++) {
    		
    		JSONObject jDados = XML.toJSONObject(lXML.get(i));    		
    		JSONArray jPedidos = getPedidoJSON(jDados);        		
    		JSONArray jItensPedidos = getItensPedidoJSON(jDados);        		
    		
    		if(jPedidos != null && jPedidos.length() > 0) {
    			        			
    			pedsSical = gson.fromJson(
    					jPedidos.toString(), PedidoSical[].class);
    			
    			for (PedidoSical p : pedsSical) {
    				
    				p.setCnpj_empresa(cnpjEmpressa);
    				p.setCod_empresa(codEmpresa);
    				
    				String cnpjCliente = bib.formataCnpjCpf(p.getCNPJ_CPF_cliente());
    				p.setCNPJ_CPF_cliente(cnpjCliente);

    				String cnpjVend = bib.formataCnpjCpf(p.getCNPJ_CPF_vendedor());
    				p.setCNPJ_CPF_vendedor(cnpjVend);
    				
					pedidos.add(p);
				}
    			
    			for (int j = 0; j < jPedidos.length(); j++) {
    				JSONObject jo = jPedidos.getJSONObject(j);
    				
    				PedComplSical psc = new PedComplSical();
    				psc.setCnpj_empresa(cnpjEmpressa);
    				psc.setNum_pedido(""+jo.getInt("num_pedido"));
    				
    				try {
    					psc.setObs(jo.getString("obs"));
					} catch (Exception e) {
						psc.setObs("");
					}

    				try {
    					psc.setObs_nota_fiscal(jo.getString("obs_nota_fiscal"));
					} catch (Exception e) {
						psc.setObs_nota_fiscal("");
					}
    				
    				pedCompls.add(psc);
				}
    		}
    		
    		if(jItensPedidos != null && jItensPedidos.length() > 0) {
    			
    			pedItens = gson.fromJson(
    					jItensPedidos.toString(), PedItemSical[].class);
    			
    			for (PedItemSical pi : pedItens) {
    				pi.setCnpj_empresa(cnpjEmpressa);
					itens.add(pi);
				}
    		}    		        		
    	}
    	
    	if (pedidos.size() > 0) {
    		
    		log.info("Quantidade de pedidos lidos: "+pedidos.size());
    		
    		try {
    			String nomeArq = cnpj.trim()+" "+bib.dataPesquisa(0);
    			nomeArq = nomeArq.trim()+" "+bib.horaAtual();
    			nomeArq = nomeArq.trim()+".xml";
    			String path = System.getProperty("catalina.home")+"\\xml\\";
    			log.info(path);
    			nomeArq = path+nomeArq;
    			log.info(nomeArq);

    		    FileWriter arq = 
    		    		new FileWriter(nomeArq);
    		    PrintWriter gravarArq = new PrintWriter(arq);
    		 
    		    gravarArq.printf(lXML.toString());
    		 
    		    arq.close();
    			
    		} catch (Exception e) {
    			e.printStackTrace();
    		}

		}
	}

	private JSONArray getPedidoJSON(JSONObject jDados) throws Exception{
		
		JSONArray jPedidos = new JSONArray();
		
		if(jDados.has("diffgr:diffgram")) {
			if(jDados.getJSONObject("diffgr:diffgram").has("NewDataSet")) {
				if(jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").has("pedidos")) {
					
					Object obj = jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").get("pedidos");
										
					if (obj instanceof JSONArray) {
						jPedidos = (JSONArray) obj;
					}else {
						JSONObject jPedido = (JSONObject) obj;
						jPedidos.put(jPedido);
					}
					
				}
			}
		}
		
		return jPedidos;
		
	}

	private JSONArray getItensPedidoJSON(JSONObject jDados) throws Exception{
		
		JSONArray jItensPedidos = new JSONArray();
		
		if(jDados.has("diffgr:diffgram")) {
			if(jDados.getJSONObject("diffgr:diffgram").has("NewDataSet")) {
				if(jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").has("pedidos_i")) {
					
					Object obj = jDados.getJSONObject("diffgr:diffgram").getJSONObject("NewDataSet").get("pedidos_i");
									
					if (obj instanceof JSONArray) {
						jItensPedidos = (JSONArray) obj;
					}else {
						JSONObject jItemPedido = (JSONObject) obj;
						jItensPedidos.put(jItemPedido);
					}
					
				}
			}
		}
		
		return jItensPedidos;
		
	}

	private void gravaPedidos( ) throws Exception {
		
		PedidoSicalDao psDao = fd.getPedidoSicalDao();

		log.info("Gravando pedidos..."+pedidos.size());
		
		for (PedidoSical ps : pedidos) {
						
			Integer numVersao = psDao.getVersao(
					ps.getCnpj_empresa(), ps.getNum_pedido());
			
			if (numVersao > 0) {
				Integer pedLogix = psDao.getPedidoLogix(numVersao,
						ps.getCnpj_empresa(), ps.getNum_pedido());
				psDao.atuVersao(numVersao, ps.getCnpj_empresa(), ps.getNum_pedido());
				ps.setPedido_logix(pedLogix);
			} else {
				ps.setPedido_logix(0);
			}

			numVersao++;
			ps.setNum_versao(numVersao);
			ps.setVersao_atual("S");
			ps.setSituacao("N");
			//ps.setCod_empresa(codEmpresa);
			
			psDao.inserir(ps);
			
			log.info("Pedido gravado: "+ps.getNum_pedido());
		}

		PedComplSicalDao pcsDao = fd.getPedComplSicalDao();

		for (PedComplSical pcs : pedCompls) {	
			
			Integer numVersao = psDao.getVersao(
					 pcs.getCnpj_empresa(), pcs.getNum_pedido());
			pcs.setNum_versao(numVersao);						
			pcsDao.inserir(pcs);
			log.info("Texto gravado: "+pcs.getNum_versao());
		}

		PedItemSicalDao pisDao = fd.getPedItemSicalDao();
		
		for (PedItemSical pis : itens) {
			Integer numVersao = psDao.getVersao(
					pis.getCnpj_empresa(), pis.getNum_pedido());
			pis.setNum_versao(numVersao);
			log.info("Texto gravado: "+pis.getNum_versao());
			
			try {
				if (pisDao.isItem(pis)) {
					pisDao.atualizar(pis);
				} else {
					pisDao.inserir(pis);
				}
				log.info("Produto gravado: "+pis.getCod_produto());
			} catch (Exception e) {
				log.info("Erro gravando pis - "+e.getMessage()+" "+e.getCause());
				log.info(e.getStackTrace().toString());
			}
		}
		
	}

	private void consistir() throws Exception {
		
		PedidoSicalDao psDao = fd.getPedidoSicalDao();		
		pedidos = psDao.listaPedido(datCorte, codEmpresa, cnpjEmpressa);

		log.info("Consistencia dos pedidos da emprsa "+codEmpresa);

		for (PedidoSical ps : pedidos) {
						
			this.pedSical = ps;
			erros = new ArrayList<PedidoErro>();

			consistePedido();

			peDao = fd.getPedidoErroDao();
			
			peDao.excluir(pedSical.getNum_versao(), 
					pedSical.getCnpj_empresa(), ps.getNum_pedido());
			
			String situacao = "I";
			
			if (erros.size() > 0) {				
				for (PedidoErro pe : erros) {
					peDao.inserir(pe);
					log.info("Erro "+pe.getMensagem());
				}
				situacao = "C";
			}
			psDao.atuStatus(
				pedSical.getCnpj_empresa(), situacao, pedSical.getNum_pedido());
		}
	}

	private void consistePedido() {

		log.info("Consistindo pedido "+pedSical.getNum_pedido());

		String msg = null;
		
		if (pedSical.getTipo_pedido() == null || pedSical.getTipo_pedido().isEmpty() ) {
			addError("O campo tipo_pedido está nulo");
		} else {
			if (!("123".contains(pedSical.getTipo_pedido()))) {
				addError("O campo tipo_pedido está diferente de 1, 2 ou 3");
			}
		}

		if (pedSical.getEntrega_futura() == null || pedSical.getEntrega_futura().isEmpty() ) {
			addError("O campo entrega_futura está nulo");
		} else {
			if (!("01".contains(pedSical.getEntrega_futura()))) {
				addError("O campo entrega_futura está diferente de 0 ou 1");
			}
		}

		if (pedSical.getCNPJ_CPF_cliente() == null || pedSical.getCNPJ_CPF_cliente().isEmpty()) {
			addError("O campo cnpj_cpf_cliente está nulo");
		} else {
			ClientesDao cliDao = fd.getClientesDao();
			try {
				String codCliente = cliDao.getCodigo(
						pedSical.getCNPJ_CPF_cliente(), pedSical.getIE_cliente());
				log.info("Cod cliente: "+codCliente);
				
				if (codCliente == null || codCliente.isEmpty()) {
					msg="Cliente "+pedSical.getCNPJ_CPF_cliente()+"/"+pedSical.getIE_cliente()
					+" não existe no logix";
					addError(msg);
				} else {
					/*
					ParametrosDao paramDao = fd.getParametrosDao();
					CliCanalVenda cc = paramDao.getCanal(codCliente);
					log.info("Canal venda: "+cc);
					if (cc == null) {
						msg="Cliente "+pedSical.getCNPJ_CPF_cliente().trim()+" sem canal de vendas";
						addError(msg);						
					} else {
						log.info("Canal venda: "+cc.getCodTipCarteira());
					}*/
				}
			} catch (Exception e) {		
				log.info("Erro: "+e.getMessage()+" "+e.getCause());
				log.info(e.getStackTrace());
				e.printStackTrace();
			}
		}

		/*if (pedSical.getCod_cond_pagto() == null || pedSical.getCod_cond_pagto().isEmpty()) {
			addError("O campo cod_cond_pagto está nulo");
		} else {
			try {
				ParametrosDao paramDao = fd.getParametrosDao();
				Integer codCond = Integer.parseInt(pedSical.getCod_cond_pagto().trim());
				codCond = paramDao.getCndPgto(codEmpresa, codCond);
				if (codCond == null) {
					addError("Cond pgto "+pedSical.getCod_cond_pagto().trim()+
							" não cadastrado no de-para");
				}				
			} catch (Exception e) {		
				log.info("Erro: "+e.getMessage()+" "+e.getCause());
				log.info(e.getStackTrace());
				e.printStackTrace();
			}
		}*/

		if (pedSical.getDt_emissao() == null || pedSical.getDt_emissao().isEmpty()) {
			addError("O campo dt_emissao está nulo");
		} else {
			String data = bib.tiraFormato(pedSical.getDt_emissao());
			if (!(bib.isData(data))) {
				addError("O campo dt_emissao contém uma data inválida");
			}
		}

		if (pedSical.getPedido_logix() > 0) {
			PedidosDao pDao = fd.getPedidosDao();
			try {
				if (pDao.isPedido(pedSical.getCnpj_empresa(), pedSical.getPedido_logix())) {					
				} else {
					addError("Alteração de pedido inexistente ou cancelado");
				}
			} catch (Exception e) {		
				log.info("Erro: "+e.getMessage()+" "+e.getCause());
				log.info(e.getStackTrace());
				e.printStackTrace();
			}
		}
		
		if (pedSical.getNum_pedido() == null || pedSical.getNum_pedido().isEmpty()) {
			addError("O campo num_pedido está nulo");
		}

		if (pedSical.getTipo_frete() == null || pedSical.getTipo_frete().isEmpty() ) {
			//addError("O campo tipo_frete está nulo");
		} else {
			if (!("123456".contains(pedSical.getTipo_frete()))) {
				addError("O campo tipo_frete está diferente de 1,2,3,4,5 ou 6");
			}
		}

		if (pedSical.getPedido_bloqueado() == null || pedSical.getPedido_bloqueado().isEmpty() ) {
			//addError("O campo pedido_bloqueado está nulo");
		} else {
			if (!("01".contains(pedSical.getPedido_bloqueado()))) {
				addError("O campo pedido_bloqueado está diferente de 0 ou 1");
			}
		}

		if (erros.size() == 0) {
			try {
				ParametrosDao paramDao = fd.getParametrosDao();
				NatOperSical nos = paramDao.getNatOper(
						pedSical.getTipo_pedido(), pedSical.getEntrega_futura());
				if (nos == null) {
					msg = "Nat operação não cadastrada no POL1391 para: ";
					msg = msg+pedSical.getTipo_pedido()+"/"+pedSical.getEntrega_futura();
					addError(msg);
					log.info(msg);
				} else {
					log.info(nos.getCod_nat_remessa()+" "+nos.getCod_nat_remessa());
				}
			} catch (Exception e) {		
				log.info("Erro: "+e.getMessage()+" "+e.getCause());
				log.info(e.getStackTrace());
				e.printStackTrace();
			}			
		}
		
		consisteItens();
		
	}
	
	private void consisteItens() {

		PedItemSicalDao pisDao = fd.getPedItemSicalDao();
		
		try {
			itens = pisDao.listaItens(pedSical.getCnpj_empresa(), 
					pedSical.getNum_pedido(), pedSical.getNum_versao());
			if (itens.size() == 0) {
				addError("Pedido sem os itens correspondentes");
				return;
			}
		} catch (SQLException e) {
			addError(e.getMessage()+" - "+e.getCause());
			log.info(e.getStackTrace());
			e.printStackTrace();
			return;
		}
		
		for (PedItemSical pis : itens) {
			consisteItem(pis);
		}		
	}

	private void consisteItem(PedItemSical pis) {

		log.info("Consistindo produto "+pis.getCod_produto());

		if (pis.getPreco_unitario() == null || pis.getPreco_unitario().isEmpty()) {
			addError("O campo preco_unitario está nulo");
		}

		if (pis.getCod_produto() == null || pis.getCod_produto().isEmpty()) {
			addError("O campo cod_produto está nulo");
		} else {
			try {
				PedidosDao pedDao = fd.getPedidosDao();
				String codProduto = pedDao.getProduto(codEmpresa, pis.getCod_produto());
				if (codProduto == null || codProduto.isEmpty()) {
					addError("Pruduto "+pis.getCod_produto().trim()+" não existe no de-para");
				}
			} catch (Exception e) {
				addError(e.getMessage()+" - "+e.getCause());
				e.printStackTrace();
				return;
			}
		}

		if (pis.getQuant() == null || pis.getQuant().isEmpty()) {
			addError("O campo quant está nulo");
		}

		if (pis.getPreco_unitario() == null || pis.getPreco_unitario().isEmpty()) {
			addError("O campo preco_tabela está nulo");
		}					
	}
	
	private void addError(String msg) {
		pe = new PedidoErro();
		pe.setVersao(pedSical.getNum_versao());
		pe.setEmpresa(pedSical.getCnpj_empresa());
		pe.setPedido(pedSical.getNum_pedido());
		pe.setMensagem(msg);
		erros.add(pe);
	}

	private void integrar() throws Exception {
		
		log.info("Integrando na carteira logix");
		
		PedidoSicalDao psDao = fd.getPedidoSicalDao();		
		List<PedidoSical> lstPedidos = 
				psDao.listaPedido(datCorte, codEmpresa, "I", cnpjEmpressa);

		log.info("Qtd pedidos a integrar "+lstPedidos.size());
		
		if (lstPedidos.size() == 0) {
			return;
		}

		PedItemSicalDao pisDao = fd.getPedItemSicalDao();
		List<PedItemSical> itens = new ArrayList<PedItemSical>();
		ClientesDao cliDao = fd.getClientesDao();
		PedidosDao pedDao = fd.getPedidosDao();
		paramDao = fd.getParametrosDao();	
		
		for (PedidoSical ps : lstPedidos) {

			log.info("Integrando pedido: "+ps.getNum_pedido());
			
			String codClient = cliDao.getCodigo(
					ps.getCNPJ_CPF_cliente(), ps.getIE_cliente());
			
			//cliCanal = paramDao.getCanal(codClient);

			itens = pisDao.listaItens(ps.getCnpj_empresa(), 
					ps.getNum_pedido(), ps.getNum_versao());
			
			if (itens.size() > 0) {				
				if (ps.getPedido_logix() == 0) {
					parvdp = paramDao.getProxnum(codEmpresa);
					paramDao.atualizar(codEmpresa, (parvdp.getNumProxPedido() + 1));		
					setPedidoLogix(ps, codClient);
					
					try {
						pedDao.inserir(pedidoLogix, ps, itens);
						log.info("Pedido inserido: "+pedidoLogix.getNumPedido());
					} catch (Exception e) {
						e.printStackTrace();
						pedDao.abortaConec();
						log.info("Erro: "+e.getMessage()+" "+e.getCause());
						log.info(e.getStackTrace());
						break;
					}
					
				} else {
					// pedDao.atualiza(ps, pcs, itens);
				}
			}
		}		
	}
	
	private void setPedidoLogix(PedidoSical ps, String client) throws Exception {
		
		String data = bib.dataExibicao(ps.getDt_emissao(), "MM/dd/yyyy");
		
		Integer codCond = 1;// Integer.parseInt(ps.getCod_cond_pagto().trim());
		//codCond = paramDao.getCndPgto(codEmpresa, codCond);
		
		NatOperSical nos = paramDao.getNatOper(
				ps.getTipo_pedido(), ps.getEntrega_futura());
		
		log.info(nos.getCod_nat_remessa()+" "+nos.getCod_nat_remessa());
		
		pedidoLogix = new Pedido();
		pedidoLogix.setCodCliente(client);		
		pedidoLogix.setCodCndPgto(codCond);		
		pedidoLogix.setCodEmpresa(codEmpresa);
		pedidoLogix.setCodMoeda(parvdp.getCodMoeda());		
		pedidoLogix.setCodNatOper(nos.getCod_nat_venda()); 
		pedidoLogix.setNatOperRemessa(nos.getCod_nat_remessa());
		//pedidoLogix.setCodRepres(cliCanal.getCodNivel1());
		pedidoLogix.setCodRepres(300); //a pedido do rubens
		pedidoLogix.setCodRepresAdic(0);
		//pedidoLogix.setCodTipCarteira(cliCanal.getCodTipCarteira());
		pedidoLogix.setCodTipCarteira("01"); //a pedido do rubens
		pedidoLogix.setCodTipVenda(1); //ver
		pedidoLogix.setDatPedido(data);
		pedidoLogix.setDatAltSit(data);
		pedidoLogix.setDatEmisRepres(data);
		pedidoLogix.setIesAceite("N");
		pedidoLogix.setIesComissao("N"); //ver
		pedidoLogix.setIesEmbalPadrao("3");
		pedidoLogix.setIesFinalidade(1);

		/*
		String tipFrete = ps.getTipo_frete();
		if (tipFrete == null || tipFrete.equalsIgnoreCase("1") || tipFrete.isEmpty()) {
			pedidoLogix.setIesFrete(1);
		} else {
			pedidoLogix.setIesFrete(3);
		}*/
		
		pedidoLogix.setIesFrete(3);
		pedidoLogix.setIesPreco("F");

		String tipPedido = ps.getPedido_bloqueado();
		if (tipPedido == null || tipPedido.equalsIgnoreCase("0") || tipPedido.isEmpty()) {
			pedidoLogix.setIesSitPedido("N");
		} else {
			pedidoLogix.setIesSitPedido("B");
		}
		
		pedidoLogix.setIesTipEntrega(3);
		pedidoLogix.setNumPedido(parvdp.getNumProxPedido());
		pedidoLogix.setNumPedRepres(ps.getNum_pedido());
		pedidoLogix.setNumListPreco(0); //ver
		pedidoLogix.setNumVersaoLista(0);
		pedidoLogix.setPctComissao(Double.parseDouble("0")); //ver
		pedidoLogix.setPctDescAdic(Double.parseDouble("0")); //ver
		pedidoLogix.setPctDescFinanc(Double.parseDouble("0")); //ver
		pedidoLogix.setPctFrete(Double.parseDouble("0")); //ver

		PedComplSicalDao pcsDao = fd.getPedComplSicalDao();

		List<PedComplSical> lista = pcsDao.getLista(ps.getCnpj_empresa(), 
				ps.getNum_pedido(), ps.getNum_versao());
		int contador = 0;
		
		String texto = "";
		String obs = "";
		
		for (PedComplSical pcs : lista) {
			
			texto = pcs.getObs_nota_fiscal();
			if (texto.length() > 76) {
				texto = texto.substring(0, 76);
			}
			
			obs   = pcs.getObs();
			if (obs.length() > 76) {
				obs = obs.substring(0, 76);
			}
			
			if (texto.contains("{")) {
				texto = "";
			}
			if (obs.contains("{")) {
				obs = "";
			}
			contador++;
			
			if (contador == 1) {
				pedidoLogix.setObsNf(texto);
				pedidoLogix.setObsPedido(obs);
			} else if (contador == 2) {
				pedidoLogix.setObs2Nf(texto);
				pedidoLogix.setObs2Pedido(obs);				
			} else if (contador == 3) {
				pedidoLogix.setObs3Nf(texto);
				pedidoLogix.setObs3Pedido(obs);								
			} else if (contador == 4) {
				pedidoLogix.setObs4Nf(texto);
				pedidoLogix.setObs4Pedido(obs);				
			} else if (contador == 5) {
				pedidoLogix.setObs5Nf(texto);
				pedidoLogix.setObs5Pedido(obs);								
			}
		}

		log.info("Pedido logix: "+pedidoLogix.getNumPedido());
	}
}
