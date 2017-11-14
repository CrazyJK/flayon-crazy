package jk.kamoru.flayon.crazy;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import jk.kamoru.flayon.base.beans.MethodExecutionBeanPostProcessor;
import jk.kamoru.flayon.base.watch.SimpleWatchDirectory;
import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;
import jk.kamoru.flayon.crazy.video.source.VideoSource;

@Configuration
@EnableAsync
@EnableAspectJAutoProxy
@EnableScheduling
@EnableCaching
public class CrazyConfig {

	@Bean
	public CrazyProperties crazyProperties() {
		return new CrazyProperties();
	}
	
	@Bean
	public VideoSource instanceVideoSource() {
		return new FileBaseVideoSource(false, crazyProperties().TORRENT_PATH, crazyProperties().INSTANCE_PATHS);
	}
	
	@Bean
	public VideoSource archiveVideoSource() {
		return new FileBaseVideoSource(true, null, crazyProperties().ARCHIVE_PATH);
	}

    @Bean
    public SimpleWatchDirectory infoWatch() {
        return new SimpleWatchDirectory() {
        	/*
        	 * about Exception, user limit of inotify watches reached
        	 * Case Ubuntu
        	 * 1. Add the following line to a new file under /etc/sysctl.d/ directory: 
        	 *   fs.inotify.max_user_watches = 524288
        	 * 2. read README in /etc/sysctl.d/
        	 *   sudo service procps start
        	 */
			@Override
			protected String getPath() {
				return crazyProperties().STORAGE_PATH + "/_info";
			}
        	
        };
    }

	@Bean
	public BeanPostProcessor methodExecutionBeanPostProcessor() {
		Map<String, String> beans = new HashMap<>();
		beans.put("infoWatch", "start");		
		MethodExecutionBeanPostProcessor processor = new MethodExecutionBeanPostProcessor();
		processor.setBeans(beans);
		return processor;
	}

}
