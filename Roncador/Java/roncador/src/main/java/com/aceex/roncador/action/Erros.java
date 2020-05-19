package main.java.com.aceex.roncador.action;

import java.sql.SQLException;
import java.util.List;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.dao.ErrosDao;
import main.java.com.aceex.roncador.dao.FabricaDao;
import main.java.com.aceex.roncador.dao.PedidoErroDao;
import main.java.com.aceex.roncador.model.PedidoErro;

public class Erros {

	private static Logger log = Logger.getLogger(Erros.class);
	private FabricaDao fd = new FabricaDao();
	private List<PedidoErro> erros;
	
	public Erros() {}
	
	public void processa() {
		
		try {
			leErros();
		} catch (Exception e) {
			log.info("Erro: NotasBean.processa ");
			e.printStackTrace();
		}
	}
	
	private void leErros() throws SQLException {
		
		PedidoErroDao erroDao = fd.getPedidoErroDao();
		erros = erroDao.lstErros();
		
		if (erros.size() > 0) {
			exportaErros();
		}
		
	}
	
	private void exportaErros() throws SQLException {
		
		ErrosDao erroDao = new ErrosDao();
		
		for (PedidoErro erro : erros) {
			erroDao.insereErro(erro);			
		}
	}
}
