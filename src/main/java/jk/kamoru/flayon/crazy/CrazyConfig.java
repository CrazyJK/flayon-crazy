package jk.kamoru.flayon.crazy;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
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

	@Value("${path.video.storage},${path.video.stage},${path.video.cover}") String[] instancePaths;
	@Value("${path.video.archive}") String archivePath;
	@Value("${path.video.torrent}") String torrentPath;

	@Bean
	public VideoSource instanceVideoSource() {
		return new FileBaseVideoSource(false, torrentPath, instancePaths);
	}
	
	@Bean
	public VideoSource archiveVideoSource() {
		return new FileBaseVideoSource(true, null, archivePath);
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
				return instancePaths[0] + "/_info";
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
