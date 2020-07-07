
create table folha_permissao_aumento (
  seq_permissao     number(12), --número sequencia, gerado automaticamente
  cod_pessoa        char(20),   --código da pessoa cujo perfil está sendo cadastrado
  ies_solicita      char(01),   --se ela pode ou não solicitar
  ies_aprova        char(01),   --se ela pode ou não aprovar
  ies_confima       char(01),   --se ela pode ou não confirmar
  ies_versao_atual  char(01),   --se é a versão atual do registro
  dt_ini            date,       --data do início de validade do perfil
  dt_fin            date,       --data de encerramento do perfil. é preenchida quando se
                                --cadastra um novo perfil para a mesma pessoa
  cod_usuario       char(50),   --usuário que cadastrou o perfil
  dt_cadastro       date,       --data que o usuário cadastrou o perfil
  primary key (seq_permissao)
);

-- só pederá ter um registro com status_solicit = A,
-- para cada pastor
-- ao inserir um registro nessa tabela, inserir também
-- na tabela folha_detalhe_aumento

create table folha_solicitacao_aumento (
  seq_solicitacao  number(12),     --número sequencial
  cod_pessoa       char(20),       --identificação do pastor
  vlr_atual        number(12,2),   --salário atual do pastor
  vlr_solicitado   number(12,2),   --valor pretendido
  vlr_aprovado     number(12,2),   --valor aprovado, no caso de aceita da solicitação 
  cod_usuario      char(50),       --usuário que fez o cadastro
  dt_cadastro      date,           --data da abertura da solicitação
  motivo           char(300),      --motivo da solicitação do reajuste 
  status_solicit   char(01),       --A=Aberta E=Encerrada C=Cancelada
  status_processo  char(01),       --P=Pendente A=Aprovado R=Rejeitado 
  cod_confirmacao  char(30),       --código para a folha. Atualizá-lo após ação do confirmador.
  primary key (seq_solicitacao)  
);

--quanto o aprovador aprovar/rejeitar, inserir
--registro nessa tabela. Idem para a ação do
--confirmador

create table folha_detalhe_aumento (
  seq_solicitacao  number(12),     --número da solicitação (tabela folha_solicitacao_aumento)
  cod_pesssoa      char(20),       --identificação do pastor
  dt_cadastro      date,           --data da gravação do registro
  cod_usuario      char(50),       --usuário que fez o cadastro
  obs              char(300),      --argumentaçao do usuário
  id_perfil        char(01),       --identificação do perfil do usuário
                                   --(S=Solicitante A=Aprovador C=Confirmador)
  primary key (seq_solicitacao, id_perfil)
);

--na ação do confirmador, se a solicitação foi aprovadoa,
--inserir reistro nessa tabela. Somente o último registro
--incluído para cada pastor poderá ter o campo ies_atual = S.
--os demais registros do pastor devem ser atualizados para ies_atual = N

create table folha_salario_pastor (
  seq_salario    number(12),         
  cod_pessoa     char(20),       --identificação do pastor
  dt_alteracao   date,           --data do aumento de salário
  valor          number(12,2),
  ies_atual      char(01),       --S=Sim N=Não 
  primary key (seq_salario)
);

-----------------------------------


package br.com.folha.reajuste.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.struts.action.ActionForm;
import org.json.JSONException;
import org.json.JSONObject;

import br.com.SGIURD.Interface.IDAO;
import br.com.folha.reajuste.util.ConectaBanco;

public class FolhaPermissaoDao implements IDAO {

	private JSONObject j = new JSONObject();
	private Connection connection;

	public FolhaPermissaoDao(Connection connection){
		this.connection = connection;
	}

	public boolean SetConexao() throws SQLException  {

		if ((this.connection = ConectaBanco.getConexao()) == null) {	
			return false;
		}else
			return true;		
	}

	public int sequencia() {

		int numSeq = 0;
		String sql = "select nvl(max(seq_permissao),0)+1 sequencia from permissao_aumento";
		
		try {
			PreparedStatement stmt = connection.prepareStatement(sql);

			ResultSet rs = stmt.executeQuery();

			if (rs.next()) {
                numSeq = rs.getInt("sequencia");		
			}
			numSeq ++;
			rs.close();
			stmt.close();
			
		} catch (SQLException e) {
			e.printStackTrace();
			numSeq = 1;
		}

		return numSeq;		

	}

	public JSONObject insere(FolhaPermissao permissao) throws JSONException {
		
		String sql =
			"insert into permissao_aumento (seq_permissao,cod_pessoa,ies_solicita,ies_aprova," +
			"ies_confima,ies_versao_atual,dt_ini,dt_fin,cod_usuario,dt_cadastro) " +
			"values (?,?,?,?,?,?,?,?,?,?)";
		
		try {
			PreparedStatement stmt = connection.prepareStatement(sql);

			stmt.setInt(1, permissao.getSeqPermissao());
			stmt.setString(2, permissao.getCodPessoa());
			stmt.setString(3, permissao.getIesSolicita());
			stmt.setString(4, permissao.getIesAprova());
			stmt.setString(5, permissao.getIesConfima());
			stmt.setString(6, permissao.getIesVersao());
			stmt.setDate(7, (Date) permissao.getDtIni());
			stmt.setDate(8, (Date) permissao.getDtFin());
			stmt.setString(9, permissao.getCodUsuario());
			stmt.setDate(10, (Date) permissao.getDtCadastro());
					
			stmt.execute();
			stmt.close();

			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");
		} catch (SQLException e) {
			j.put("errorCode", 302);
			j.put("errorDesc", e.getMessage());
			e.printStackTrace();
		}
		
		return j;
	}
	
	public FolhaPermissao procura(Long id) {
		
		FolhaPermissao contato = new FolhaPermissao();
		String sql = "select * from permissao_aumento where id=?";

		try {
			PreparedStatement stmt = connection.prepareStatement(sql);
			stmt.setLong(1, id);
			ResultSet rs = stmt.executeQuery();

			if (rs.next()) {
				/*
				contato.setId(rs.getLong("id"));
				contato.setNome(rs.getString("nome"));
				contato.setEmail(rs.getString("email"));
				contato.setEndereco(rs.getString("endereco"));
                contato.setDataNascimento(rs.getDate("dataNascimento"));
				return(contato); */
			}
			
			rs.close();
			stmt.close();
			
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}

		return contato;		

	}
	
	public List<FolhaPermissao> getLista() {
		
		String sql = "select * from contatos";
		
		try {
			PreparedStatement stmt = connection.prepareStatement(sql);
			
			ResultSet rs = stmt.executeQuery();
			List<FolhaPermissao> contatos = new ArrayList<FolhaPermissao>();
			
			while (rs.next()) {
				FolhaPermissao contato = new FolhaPermissao();
				/*
				contato.setId(rs.getLong("id"));
				contato.setNome(rs.getString("nome"));
				contato.setEmail(rs.getString("email"));
				contato.setEndereco(rs.getString("endereco"));
                contato.setDataNascimento(rs.getDate("dataNascimento"));
				contatos.add(contato);  */
			}
			
			rs.close();
			stmt.close();
			return contatos;		
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		
		
	}
	
	public void altera(FolhaPermissao contato) {
		
		String sql = 
			"update contatos set nome=?, email=?, endereco=?, dataNascimento=? where id=?";
		
		try {
			PreparedStatement stmt = connection.prepareStatement(sql);
			/*
			stmt.setString(1, contato.getNome());
			stmt.setString(2, contato.getEmail());
			stmt.setString(3, contato.getEndereco());
			stmt.setDate(4, (java.sql.Date) contato.getDataNascimento());	
			stmt.setLong(5, contato.getId());
			stmt.execute();
			stmt.close();       */
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}	
	
	public void remove(FolhaPermissao contato) {
		
		String sql = 
			"delete from contatos where id=?";
		
		try {
			PreparedStatement stmt = connection.prepareStatement(sql);
			//stmt.setLong(1, contato.getId());
			stmt.execute();
			stmt.close();
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public JSONObject altera(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public JSONObject exclui(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public JSONObject filtra(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Integer geraId() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public JSONObject insere(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean isEntidadeExiste(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public JSONObject seleciona(ActionForm arg0) throws JSONException {
		// TODO Auto-generated method stub
		return null;
	}
	
}