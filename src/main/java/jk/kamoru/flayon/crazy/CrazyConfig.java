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

import jk.kamoru.flayon.base.MethodExecutionBeanPostProcessor;
import jk.kamoru.flayon.crazy.video.source.FileBaseVideoSource;
import jk.kamoru.flayon.crazy.video.source.VideoSource;
import lombok.Getter;

@Configuration
@EnableAsync
@EnableAspectJAutoProxy
@EnableScheduling
@EnableCaching
@Getter
public class CrazyConfig {

    /* Local properties --------------------------------------------------------------------------- */

	@Value("${path.video.archive}")         String        archivePath;
    @Value("${path.video.storage}")         String        storagePath;
    @Value("${path.video.candidate}")       String[]    candidatePaths;
    @Value("${path.video.stage}")           String[]        stagePaths;
    @Value("${path.video.cover}")           String          coverPath;
    @Value("${path.video.queue}")           String          queuePath;
    @Value("${path.torrent.queue}")         String   torrentQueuePath;
    @Value("${path.torrent.seed}")          String    torrentSeedPath;
    @Value("${path.move.file}")             String[]     moveFilePaths;
    @Value("${path.sora.pictures}")         String[] soraPicturesPaths;
    @Value("${path.image.storage}")         String[]        imagePaths;
    @Value("${path.backup}")                String         backupPath;
    @Value("${path.subtitles}")             String      subtitlesPath;
    @Value("${app.video-player}")           String   player;
    @Value("${app.subtitles-editor}")       String   editor;
	@Value("${path.video.storage},${path.video.stage},${path.video.cover}") String[] instancePaths;
	@Value("${path.video.archive},${path.video.stage},${path.video.cover}") String[] emptyManagedPath;

    /* Common Properties -------------------------------------------------------------------------- */
    
	                                        int baseRank = 0;
    @Value("${rank.minimum}")               int  minRank;
    @Value("${rank.maximum}")               int  maxRank;
    @Value("${size.video.storage}")         int maxEntireVideo;
    @Value("${score.ratio.play}")           int      playRatio;
    @Value("${score.ratio.rank}")           int      rankRatio;
    @Value("${score.ratio.actress}")        int   actressRatio;
    @Value("${score.ratio.subtitles}")      int subtitlesRatio;
    @Value("${parse.to.title.no_opus}")     String   noParseOpusPrefix;
    @Value("${parse.to.title.re_opus}")     String[] replaceOpusInfo;
    @Value("${url.rss}")                    String urlRSS;
    @Value("${url.search.video}")           String urlSearchVideo;
    @Value("${url.search.actress}")         String urlSearchActress;
    @Value("${url.search.torrent}")         String urlSearchTorrent;
    @Value("${batch.watched.moveVideo}")    boolean      moveWatchedVideo;
    @Value("${batch.rank.deleteVideo}")     boolean  deleteLowerRankVideo;
    @Value("${batch.score.deleteVideo}")    boolean deleteLowerScoreVideo;

	@Bean
	public VideoSource instanceVideoSource() {
		return new FileBaseVideoSource(false, torrentQueuePath, instancePaths);
	}
	
	@Bean
	public VideoSource archiveVideoSource() {
		return new FileBaseVideoSource(true, null, archivePath);
	}

	@Bean
	public BeanPostProcessor methodExecutionBeanPostProcessor() {
		Map<String, String> beans = new HashMap<>();
		beans.put("instanceVideoSource", "reload");
		MethodExecutionBeanPostProcessor processor = new MethodExecutionBeanPostProcessor();
		processor.setBeans(beans);
		return processor;
	}

	public boolean setMoveWatchedVideo(boolean moveWatchedVideo) {
		return this.moveWatchedVideo = moveWatchedVideo;
	}
	public boolean setDeleteLowerRankVideo(boolean deleteLowerRankVideo) {
		return this.deleteLowerRankVideo = deleteLowerRankVideo;
	}
	public boolean setDeleteLowerScoreVideo(boolean deleteLowerScoreVideo) {
		return this.deleteLowerScoreVideo = deleteLowerScoreVideo;
	}

}
