package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.action.Pedidos;
import main.java.com.aceex.roncador.model.CliCanalVenda;
import main.java.com.aceex.roncador.model.NatOperSical;
import main.java.com.aceex.roncador.model.Parvdp;

public class ParametrosDao extends Dao {

	private static Logger log = Logger.getLogger(ParametrosDao.class);
	
	private PreparedStatement stmt;
	private ResultSet rs;

	public ParametrosDao(Connection conexao) {
		super(conexao);
	}

	
	public Parvdp getProxnum(String codEmpresa) throws SQLException {

		Parvdp param = null;
		String query = "";
		
		query += "select cod_moeda, num_prx_pedido, par_vdp_txt, ";
		query += "qtd_dias_atr_dupl, qtd_dias_atr_med from par_vdp";
		query += " where trim(cod_empresa) =  ? ";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, codEmpresa.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			param = new Parvdp();
			param.setCodMoeda(rs.getInt(1));
			param.setNumProxPedido(rs.getInt(2));
			param.setParVdpTxt(rs.getString(3));
			param.setQtdDiasAtrDupl(rs.getInt(4));
			param.setQtdDiasAtrMed(rs.getInt(5));
		}

		rs.close();
		stmt.close();

		return param;
	}

	public void atualizar(String codEmpresa, 
			Integer proxNumPedido) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE par_vdp SET num_prx_pedido = ? ";
		query += " WHERE cod_empresa = ?";

		stmt = con.prepareStatement(query);
		stmt.setInt(1, proxNumPedido);
		stmt.setString(2, codEmpresa);
		
	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public CliCanalVenda getCanal(String codCliente) throws SQLException {

		CliCanalVenda canal = null;
		String query = "";
		 
		query += "select cod_nivel_1, cod_nivel_2, cod_nivel_3, ";
		query += "ies_nivel, cod_tip_carteira from cli_canal_venda";
		query += " where trim(cod_cliente) =  ? ";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, codCliente.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			canal = new CliCanalVenda();
			canal.setCodNivel1(rs.getInt(1));
			canal.setCodNivel2(rs.getInt(2));
			canal.setCodNivel3(rs.getInt(3));
			canal.setIesNivel(rs.getString(4));
			canal.setCodTipCarteira(rs.getString(5));
		}

		rs.close();
		stmt.close();

		return canal;
	}

	public String getProduto(String codEmpresa, String codSical) throws SQLException {

		String codLogix = null;
		String query = "";
		 
		query += "select cod_logix from de_para_produto ";
		query += " where trim(cod_empresa) =  ? and trim(cod_sical) = ?";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, codEmpresa.trim());
		stmt.setString(2, codSical.trim());

		rs = stmt.executeQuery();

		if (rs.next()) {
			codLogix = rs.getString("cod_logix");
		}

		rs.close();
		stmt.close();

		return codLogix;
	}

	public Integer getCndPgto(String codEmpresa, Integer codSical) throws SQLException {

		Integer codLogix = null;
		String query = "";
		 
		query += "select cod_logix from de_para_cond_pgto ";
		query += " where cod_empresa =  ? and cod_sical = ?";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, codEmpresa);
		stmt.setInt(2, codSical);

		rs = stmt.executeQuery();

		if (rs.next()) {
			codLogix = rs.getInt("cod_logix");
		}

		rs.close();
		stmt.close();

		return codLogix;
	}

	public NatOperSical getNatOper(String tipPedido, 
			String entregaFurura) throws SQLException {

		log.info("Tipo "+tipPedido+" Entrega "+entregaFurura);
		
		NatOperSical nos = null;
		String query = "";
		 
		query += "select cod_nat_venda, cod_nat_remessa from nat_oper_sical ";
		query += " where trim(tip_pedido) = ? ";
		query += " and trim(entrega_furura) = ? ";

		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, tipPedido);
		stmt.setString(2, entregaFurura);

		rs = stmt.executeQuery();

		if (rs.next()) {
			nos = new NatOperSical();
			nos.setTip_pedido(tipPedido);
			nos.setEntrega_furura(entregaFurura);
			nos.setCod_nat_venda(rs.getInt("cod_nat_venda"));
			nos.setCod_nat_remessa(rs.getInt("cod_nat_remessa"));
			log.info("Venda "+nos.getCod_nat_venda());
			log.info("Remessa "+nos.getCod_nat_remessa());
		}

		rs.close();
		stmt.close();

		return nos;
	}

}
