package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

import jk.kamoru.flayon.boot.scheduling.SimpleWatchDirectory;
import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;
import lombok.extern.slf4j.Slf4j;

@Configuration
@EnableAsync
@Slf4j
public class CrazyConfig {

	@Value("${path.video.storage},${path.video.stage}") String[] paths;
	@Value("${path.video.archive}") String archive;

	@Bean
	public FileBaseVideoSource instanceVideoSource() {
		FileBaseVideoSource videoSouece = new FileBaseVideoSource();
		videoSouece.setPaths(paths);
		return videoSouece;
	}
	
	@Bean
	public FileBaseVideoSource archiveVideoSource() {
		FileBaseVideoSource videoSouece = new FileBaseVideoSource();
		videoSouece.setPaths(archive);
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
				return paths[0] + "/_info";
			}
        	
        };
    }

}
