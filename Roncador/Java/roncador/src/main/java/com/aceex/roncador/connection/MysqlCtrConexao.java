package main.java.com.aceex.roncador.connection;


import java.sql.Connection;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.main.IntegraSical;

public class MysqlCtrConexao {

	private static Logger log = Logger.getLogger(MysqlCtrConexao.class);
	private static Connection conexao;	
	
	public static Connection getConexao() {
		return conexao;
	}

	public static void abreConexao() {
		
		try {
			conexao = new MysqlConexao().getConexao();
			log.info("Abertura da conexão "+conexao);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void fechaConexao() {
		try {
			log.info("Fechamento da conexão "+conexao);
			conexao.close();
			log.info(conexao);
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

}
