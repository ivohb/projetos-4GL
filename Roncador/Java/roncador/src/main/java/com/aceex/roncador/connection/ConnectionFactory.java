package main.java.com.aceex.roncador.connection;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.log4j.Logger;
 
public class ConnectionFactory {	
	private static String url;
	private static String driver;
	private static String user;
	private static String password;
	private static int initialSize;
	private static int minIdle;
	private static int maxTotal;
	private static int minEvictableIdleTimeMillis;
	
	private static Properties properties = null;

	private static BasicDataSource dataSource;
	
	private static Logger log = Logger.getLogger(ConnectionFactory.class);
	
	public ConnectionFactory(){
		this.carregarConfiguracoesBd();
		this.configurarDataSourceRAC();
	}
		
	public synchronized void carregarConfiguracoesBd(){  
	      if (properties == null) {  
	    	  readProperties();
	    	  System.out.println("Objeto properties criado. Lendo arquivo.");
	      }  
	   }  	
	
    /**
     * M�todo que carrega os dados de acesso ao banco a partir de um
     * arquivo properties
     */
	private static void readProperties(){
		
		try {		
			FileInputStream		connectionConfPath	= null;
			connectionConfPath = new FileInputStream(
				new File(new File(
					new File(System.getProperty(
							"catalina.home")),"/conf"),"oracle.props"));

			int fatorConversao = 600000;
			int initialSizeDefault = 10;
			int minIdleDefault = 10;
			int maxTotalDefault = 500;
			int minIdleTimeDefault = 10;
			
			properties = new Properties();
			properties.load(connectionConfPath);

			log.debug("Conectando Base:" + properties.getProperty("type").toString());			
			
			if (properties.getProperty("user") != null) {
				url 		= properties.getProperty("url").toString();
				driver 		= properties.getProperty("driver").toString();
				user 		= properties.getProperty("user").toString();
				password 	= properties.getProperty("password").toString();
				
				if (properties.getProperty("initialSize") != null && !properties.getProperty("initialSize").equals("")
																	&& !properties.getProperty("initialSize").equals("0")){

					initialSize 	= Integer.parseInt(properties.getProperty("initialSize"));
				} else {
					initialSize	= initialSizeDefault;
				}
				
				if (properties.getProperty("minIdle") != null && !properties.getProperty("minIdle").equals("")
																&& !properties.getProperty("minIdle").equals("0")){
				
					minIdle 	= Integer.parseInt(properties.getProperty("minIdle"));
				} else {
					minIdle	= minIdleDefault;
				}
				
				if (properties.getProperty("maxTotal") != null && !properties.getProperty("maxTotal").equals("")
																&& !properties.getProperty("maxTotal").equals("0")){
					
					maxTotal 	= Integer.parseInt(properties.getProperty("maxTotal"));
				} else {
					maxTotal	= maxTotalDefault;
				}
				
				if (properties.getProperty("minIdleTime") != null && !properties.getProperty("minIdleTime").equals("")
																	&& !properties.getProperty("minIdleTime").equals("0")){
					
					minEvictableIdleTimeMillis = fatorConversao * Integer.parseInt(properties.getProperty("minIdleTime"));
				} else {
					minEvictableIdleTimeMillis = fatorConversao * minIdleTimeDefault;
				}	
			}
			connectionConfPath.close();
		} catch (IOException e) {
			log.fatal("ConnectionFactory.ArquivoConf(). Arquivo de configuracao nao encontrado");
		} catch (Exception e) {			
			log.fatal("ConnectionFactory.ArquivoConf(). Erro de Criptografia [Exception]");
		}
	}
	
	   /**
     * M�todo que configura o BaseDataSource
     */
    private void configurarDataSourceRAC(){
    	if(dataSource==null){
	        ConnectionFactory.dataSource = new BasicDataSource();
	        ConnectionFactory.dataSource.setDriverClassName(driver);
	        ConnectionFactory.dataSource.setUsername(user);
	        ConnectionFactory.dataSource.setPassword(password);
	        ConnectionFactory.dataSource.setUrl(url);
	        ConnectionFactory.dataSource.setInitialSize(initialSize);//Seta o pool para apenas uma conex�o ativa
	        ConnectionFactory.dataSource.setMinIdle(minIdle);//Obriga o pool a ter pelo menos uma conex�o sempre ativa
	        ConnectionFactory.dataSource.setMaxActive(maxTotal);
	        ConnectionFactory.dataSource.setMinEvictableIdleTimeMillis(minEvictableIdleTimeMillis);
	        ConnectionFactory.dataSource.setTestOnReturn(true);//Habilita o teste da conex�o antes de retorn�-la
	        ConnectionFactory.dataSource.setRemoveAbandoned(true); // remove conexoes abondonadas
	        ConnectionFactory.dataSource.setRemoveAbandonedTimeout(30);// remove as conexoes abondonadas depois de determinado tempo 
	        //ConnectionFactory.dataSource.setValidationQuery("SELECT sysdate FROM dual");//Query que serve para atestar conectividade (para oracle)
    	}
    }

    /**
     * M�todo que retorna uma conex�o do BasicDataSource.
     * Nesse caso ele verifica se existe uma conex�o pronta, sen�o existir verifica
     * se o n�mero de conex�es est� abaixo do que foi estabelecido, se estiver cria
     * a conex�o e devolve.
     * @return Uma conex�o do pool
     */
    public Connection getConexaoRAC(){
        try{
             return ConnectionFactory.dataSource.getConnection();
             
        }catch (SQLException sqle){
        	log.fatal("Erro ao conectar no Banco de Dados (SQLException). " + sqle.getMessage());
        }catch (Exception e){
        	log.fatal("Erro ao conectar no Banco de Dados (Exception). " + e.getMessage());
        }

        return null;

    }

    /**
     * Mostra informa��es do DataSource
     */
    public void showStatusDataSource(){
    	System.out.println("Conexoes ativas: " + ConnectionFactory.dataSource.getNumActive());
    	System.out.println("Conexoes inativas: " + ConnectionFactory.dataSource.getNumIdle());
        //log.debug("Conexoes ativas: " + ConnectionFactory.dataSource.getNumActive());
        //log.debug("Conexoes inativas: " + ConnectionFactory.dataSource.getNumIdle());
    }

    /**
     * Fecha tudo o que foi usado pelos DAO's incluindo a conex�o.
     * Nesse caso a conex�o n�o � fechada de fato como no JDCB puro, e sim devolvida
     * ao pool de conex�o (BasicDataSource)
     * @param rs ResultSet
     * @param ps PreparedStatement
     * @param conn Connection (oriunda do BasicDataSource, mas pode ser a do JDBC tamb�m)
     */
    public static void liberarRecursosBD(ResultSet rs, PreparedStatement ps, Connection conn){
        try{
            if (ps != null)
            	ps.close();
            if (rs != null)
                rs.close();
            if (conn != null)
                conn.close();
        }catch (SQLException sqle){
        	log.fatal("Erro ao liberar recurso do Banco de Dados (SQLException). " + sqle.getMessage());
        }catch (Exception e){
        	log.fatal("Erro ao liberar recurso do Banco de Dados (SQLException). " + e.getMessage());            
        }

    }	
}
