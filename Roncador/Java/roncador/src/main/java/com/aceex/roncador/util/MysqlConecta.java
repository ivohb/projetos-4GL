package main.java.com.aceex.roncador.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MysqlConecta {

	private Connection conexao;
	
	public MysqlConecta() {}
	
	public Connection getConexao() throws SQLException {
		if (this.conexao == null) {
			conecta();
		}
		return this.conexao;
	}

	private void conecta() {
		
		String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://localhost/logix";
		String login = "root";
		String senha = "Mongo@1965";
		
		try{
			Class.forName(driver).newInstance();
	        this.conexao = DriverManager.getConnection(url,login,senha);
	        System.out.println("Conectado com banco mySql");
		}
        catch( Exception e ){
            e.printStackTrace();
        }

	}

}
