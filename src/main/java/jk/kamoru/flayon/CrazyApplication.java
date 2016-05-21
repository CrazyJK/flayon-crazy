package jk.kamoru.flayon;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;

@SpringBootApplication
public class CrazyApplication {

	public static void main(String[] args) {
		SpringApplication.run(CrazyApplication.class, args);
	}

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
	
}
