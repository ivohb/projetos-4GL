package main.java.com.aceex.roncador.dao;

import java.sql.Connection;

public abstract class Dao {
	
	private final Connection conexao;

	
	public Dao(Connection conexao) {
		this.conexao = conexao;
	}

	protected Connection getConexao() {
		return conexao;
	}
	
			

}
