package main.java.com.aceex.roncador.dao;

import java.sql.Connection;

import main.java.com.aceex.roncador.connection.OracleConexao;

public class FabricaDao {

	private final Connection conexao;
	
	public FabricaDao() {
		this.conexao = OracleConexao.getConexao();
		
		//this.conexao = new SqlConecta().getConexaoRAC();		
	}
	
	public PedidosDao getPedidosDao() {
		return new PedidosDao(this.conexao);		
	}

	public PedidoSicalDao getPedidoSicalDao() {
		return new PedidoSicalDao(this.conexao);		
	}

	public PedItemSicalDao getPedItemSicalDao() {
		return new PedItemSicalDao(this.conexao);		
	}

	public EmpresaDao getEmpresaDao() {
		return new EmpresaDao(this.conexao);		
	}

	public ClientesDao getClientesDao() {
		return new ClientesDao(this.conexao);		
	}

	public CondPgtoDao getCondpgtoDao() {
		return new CondPgtoDao(this.conexao);		
	}

	public PedidoErroDao getPedidoErroDao() {
		return new PedidoErroDao(this.conexao);		
	}

	public PedComplSicalDao getPedComplSicalDao() {
		return new PedComplSicalDao(this.conexao);		
	}

	public ItemDao getItemDao() {
		return new ItemDao(this.conexao);		
	}

	public ParametrosDao getParametrosDao() {
		return new ParametrosDao(this.conexao);		
	}

	public NotaDao getNotaDao() {
		return new NotaDao(this.conexao);		
	}
	

}
