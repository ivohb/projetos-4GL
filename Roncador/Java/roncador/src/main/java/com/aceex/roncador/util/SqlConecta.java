package main.java.com.aceex.roncador.util;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class SqlConecta {


	private Connection conexao;

	public SqlConecta() {
		
	}
	
	public Connection getConexao() throws SQLException {
		if (this.conexao == null) {
			conecta();
		}
		return this.conexao;
	}

	private void conecta() {
		
		String driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		String url = "jdbc:sqlserver://192.168.1.56;DatabaseName=LOGIXPRD";
		String login = "logix";
		String senha = "logix";
		
		try{
			Class.forName(driver).newInstance();
	        this.conexao = DriverManager.getConnection(url,login,senha);
	        System.out.println("Conectado "+this.conexao);
		}
        catch( Exception e ){
            e.printStackTrace();
        }

	}	
}
