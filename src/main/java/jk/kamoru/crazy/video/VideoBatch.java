package jk.kamoru.crazy.video;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jk.kamoru.crazy.CrazyProperties;
import jk.kamoru.crazy.video.service.VideoService;

@Component
public class VideoBatch extends CrazyProperties {

	private static final Logger logger = LoggerFactory.getLogger(VideoBatch.class);

	@Autowired VideoService videoService;

	public boolean isMOVE_WATCHED_VIDEO() {
		return MOVE_WATCHED_VIDEO;
	}
	public void setMOVE_WATCHED_VIDEO(boolean setValue) {
		MOVE_WATCHED_VIDEO = setValue;
		showProperties();
	}
	public boolean isDELETE_LOWER_RANK_VIDEO() {
		return DELETE_LOWER_RANK_VIDEO;
	}
	public void setDELETE_LOWER_RANK_VIDEO(boolean setValue) {
		DELETE_LOWER_RANK_VIDEO = setValue;
		showProperties();
	}
	public boolean isDELETE_LOWER_SCORE_VIDEO() {
		return DELETE_LOWER_SCORE_VIDEO;
	}
	public void setDELETE_LOWER_SCORE_VIDEO(boolean setValue) {
		DELETE_LOWER_SCORE_VIDEO = setValue;
		showProperties();
	}

	@PostConstruct
	private void showProperties() {
		logger.info("Batch properties");
		logger.info("  - batch.watched.moveVideo = {}", MOVE_WATCHED_VIDEO);
		logger.info("  - batch.rank.deleteVideo  = {}", DELETE_LOWER_RANK_VIDEO);
		logger.info("  - batch.score.deleteVideo = {}", DELETE_LOWER_SCORE_VIDEO);
	}
	
	@Scheduled(cron="0 */5 * * * *")
	public synchronized void batchVideoSource() {
		
		logger.info("BATCH Video START");
		long startTime = System.currentTimeMillis();

		logger.info("  BATCH : delete lower rank video [{}]", DELETE_LOWER_RANK_VIDEO);
		if (DELETE_LOWER_RANK_VIDEO)
			videoService.removeLowerRankVideo();
		
		logger.info("  BATCH : delete lower score video [{}]", DELETE_LOWER_SCORE_VIDEO);
		if (DELETE_LOWER_SCORE_VIDEO)
			videoService.removeLowerScoreVideo();
		
		logger.info("  BATCH : delete garbage file");
		videoService.deleteGarbageFile();
		
		logger.info("  BATCH : arrange to same folder");
		videoService.arrangeVideo();
		
		logger.info("  BATCH : move watched video [{}]", MOVE_WATCHED_VIDEO);
		if (MOVE_WATCHED_VIDEO)
			videoService.moveWatchedVideo();

		logger.info("  BATCH : reload");
		videoService.reload();
		
		long elapsedTime = System.currentTimeMillis() - startTime;
		logger.info("BATCH Video END. Elapsed time : {} ms", elapsedTime);
	}
	
	@Scheduled(fixedDelay = 1000 * 60)
	public synchronized void moveFile() {
		logger.debug("BATCH File move START {}", Arrays.toString(PATH_MOVE_FILE));

		// 설정이 안됬거나
		if (PATH_MOVE_FILE == null) {
			logger.error("PATH_MOVE_FILE is not set");
			return;
		}
		// 값이 없으면 pass
		if (PATH_MOVE_FILE.length == 0)
			return;
		
		// 3배수가 아니면
		if (PATH_MOVE_FILE.length % 3 != 0) {
			logger.error("PATH length is not 3 multiple", Arrays.toString(PATH_MOVE_FILE));
			return;
		}
		// 2,3번째가 폴더가 아니거나
		for (int i=0; i<PATH_MOVE_FILE.length; i++) {
			if (i % 3 == 0)
				continue;
			else
				if (!new File(PATH_MOVE_FILE[i]).isDirectory()) {
					logger.error("PATH [{}] is not Directory", PATH_MOVE_FILE[i]);
					return;
				}
		}
		for (int i=0; i<PATH_MOVE_FILE.length;) {
			String ext = PATH_MOVE_FILE[i++];
			File from = new File(PATH_MOVE_FILE[i++]);
			File to   = new File(PATH_MOVE_FILE[i++]);
			for (File file : FileUtils.listFiles(from, new String[]{ext.toUpperCase(), ext.toLowerCase()}, false)) {
				try {
					logger.info("Moving... {} to {}", file.getAbsolutePath(), to.getAbsolutePath());
					FileUtils.moveFileToDirectory(file, to, false);
				}
				catch (IOException e) {
					logger.error("File to move", e);
				}
			}
		}
		
		logger.debug("BATCH File move END");
	}
	
	@Scheduled(fixedRate = 1000 * 60 * 60)
	public synchronized void arrangeArchive() {
		logger.info("BATCH - arrange archive video");
		videoService.arrangeArchiveVideo();
	}

	@Scheduled(fixedRate = 1000 * 60 * 13)
	public synchronized void arrangeSubFolder() {
		logger.info("BATCH - arrange sub-folder");
		videoService.arrangeSubFolder();
	}
}
