package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableAsync;

import jk.kamoru.flayon.boot.scheduling.SimpleWatchDirectory;
import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;
import lombok.extern.slf4j.Slf4j;

@Configuration
@EnableAsync
@EnableAspectJAutoProxy
@Slf4j
public class CrazyConfig {

	@Value("${path.video.storage},${path.video.stage},${path.video.cover}") String[] instancePaths;
	@Value("${path.video.archive}") String archivePath;

	@Bean
	public FileBaseVideoSource instanceVideoSource() {
		FileBaseVideoSource videoSouece = new FileBaseVideoSource();
		videoSouece.setPaths(instancePaths);
		return videoSouece;
	}
	
	@Bean
	public FileBaseVideoSource archiveVideoSource() {
		FileBaseVideoSource videoSouece = new FileBaseVideoSource();
		videoSouece.setPaths(archivePath);
		videoSouece.setArchive(true);
		return videoSouece;
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
				log.debug("WatchDirectory init");
				return instancePaths[0] + "/_info";
			}
        	
        };
    }

}
