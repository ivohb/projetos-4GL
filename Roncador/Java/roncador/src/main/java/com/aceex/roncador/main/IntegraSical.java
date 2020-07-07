package main.java.com.aceex.roncador.main;

//import java.time.LocalDate;
import java.util.Timer;
import java.util.TimerTask;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import org.apache.log4j.Logger;

import main.java.com.aceex.roncador.action.Erros;
import main.java.com.aceex.roncador.action.Notas;
import main.java.com.aceex.roncador.action.Pedidos;
import main.java.com.aceex.roncador.connection.OracleConexao;
import main.java.com.aceex.roncador.util.Propriedade;

@WebListener
public class IntegraSical implements ServletContextListener {
	
	private static Logger log = Logger.getLogger(IntegraSical.class);
	
	public void contextInitialized(ServletContextEvent event) {
 
		log.info("Integraçao Logix x Sical V 1.035");
		Propriedade prop = new Propriedade();		
		int tempo_minuto = prop.getTempo();
		
		if (tempo_minuto < 10) {
			tempo_minuto = 10;
		}
		
		final long TEMPO = ((1000 * tempo_minuto ) * 60);
	
		Timer timer = new Timer();
		TimerTask timerTask = new TimerTask() {
			@Override
			public void run() { 

				//System.out.println("Processo executado em  " + LocalDate.now());
				log.info("Processo executado as  " + new java.util.Date());
				
				OracleConexao.abreConexao();
				log.info("Importação de pedidos  ");
				new Pedidos().execute();
				log.info("Exportação de notas  ");
				new Notas().execute();
				
				OracleConexao.abreErroConexao();
				new Erros().processa();
				OracleConexao.fechaErroConexao();

				OracleConexao.fechaConexao();
			}
		};
		
		timer.scheduleAtFixedRate(timerTask, TEMPO, TEMPO);
 
	}
		
	public void contextDestroyed(ServletContextEvent event) {	}


}
