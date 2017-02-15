package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

import jk.kamoru.flayon.base.watch.SimpleWatchDirectory;
import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;

@Configuration
@EnableAsync
@EnableAspectJAutoProxy
@EnableScheduling
public class CrazyConfig {

	@Value("${path.video.storage},${path.video.stage},${path.video.cover}") String[] instancePaths;
	@Value("${path.video.archive}") String archivePath;
	@Value("${path.video.torrent}") String torrentPath;

	@Bean
	public FileBaseVideoSource instanceVideoSource() {
		return new FileBaseVideoSource(false, torrentPath, instancePaths);
	}
	
	@Bean
	public FileBaseVideoSource archiveVideoSource() {
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

}
