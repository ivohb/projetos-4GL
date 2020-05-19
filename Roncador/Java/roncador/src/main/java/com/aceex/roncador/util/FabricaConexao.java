package main.java.com.aceex.roncador.util;
import java.sql.Connection;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.main.IntegraSical;
import main.java.com.aceex.roncador.util.MysqlConecta;
import main.java.com.aceex.roncador.util.SqlConecta;

public class FabricaConexao {

	private static Logger log = Logger.getLogger(IntegraSical.class);
	private static Connection conexao;	
	
	/*
	static {
		try {
			conexao = new MysqlConecta().getConexao();
			if (conexao == null || conexao.isClosed()) {
				log.info("Conexão não foi criada");
			} else {
				log.info("Conectado em "+conexao);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}*/

	public static Connection getConexao() {
		return conexao;
	}

	public  void abreConexao() {
		log.info("Abrindo conexão");
		try {
			conexao = new SqlConecta().getConexao();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public  void fechaConexao() {
		log.info("Fechando conexão");
		try {
			if (conexao != null) {
				conexao.close();
			}			
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

}
