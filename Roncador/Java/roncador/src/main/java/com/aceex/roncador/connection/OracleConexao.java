package main.java.com.aceex.roncador.connection;


import java.sql.Connection;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.util.MysqlConecta;
import main.java.com.aceex.roncador.util.SqlConecta;

public class OracleConexao {

	private static Logger log = Logger.getLogger(OracleConexao.class);
	private static Connection conexao;	
	private static Connection erroConexao;	
	
	public static Connection getConexao() {
		return conexao;
	}

	public static void abreConexao() {
		
		try {
			conexao = new LogixConexao().getConexao();
			//conexao = new SqlConecta().getConexao();
			log.info("Abertura da conexão "+conexao);
		} catch (Exception e) {
			log.info(e.getMessage()+" "+e.getCause());
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

	public static Connection getErroConexao() {
		return erroConexao;
	}

	public static void abreErroConexao() {
		
		try {
			erroConexao = new ErroConexao().getConexao();
			//erroConexao = new MysqlConecta().getConexao();
			log.info("Abertura da conexão "+erroConexao);
		} catch (Exception e) {
			log.info(e.getMessage()+" "+e.getCause());
			e.printStackTrace();
		}
	}

	public static void fechaErroConexao() {
		try {
			log.info("Fechamento da conexão "+erroConexao);
			erroConexao.close();
			log.info(erroConexao);
		} catch (Exception e) {
			e.printStackTrace();
		}		
	}

}
