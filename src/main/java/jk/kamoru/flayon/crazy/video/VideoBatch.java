package jk.kamoru.flayon.crazy.video;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import jk.kamoru.flayon.crazy.video.util.ZipUtils;

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
		
		logger.info("BATCH Video END");
	}
	
	@Scheduled(fixedDelay = 1000 * 60) // per 1 min
	public synchronized void moveFile() {
		logger.trace("BATCH File move START {}", Arrays.toString(MOVE_FILE_PATHS));

		// 설정이 안됬거나
		if (MOVE_FILE_PATHS == null) {
			logger.error("PATH_MOVE_FILE is not set");
			return;
		}
		// 값이 없으면 pass
		if (MOVE_FILE_PATHS.length == 0)
			return;
		
		// 3배수가 아니면
		if (MOVE_FILE_PATHS.length % 3 != 0) {
			logger.error("PATH length is not 3 multiple", Arrays.toString(MOVE_FILE_PATHS));
			return;
		}
		// 2,3번째가 폴더가 아니거나
		for (int i=0; i<MOVE_FILE_PATHS.length; i++) {
			if (i % 3 == 0)
				continue;
			else
				if (!new File(MOVE_FILE_PATHS[i]).isDirectory()) {
					logger.error("PATH [{}] is not Directory", MOVE_FILE_PATHS[i]);
					return;
				}
		}
		for (int i=0; i<MOVE_FILE_PATHS.length;) {
			String ext = MOVE_FILE_PATHS[i++];
			File from = new File(MOVE_FILE_PATHS[i++]);
			File to   = new File(MOVE_FILE_PATHS[i++]);
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
		
		logger.trace("BATCH File move END");
	}
	
	@Scheduled(fixedRate = 1000 * 60 * 60) // per 1 hr
	public synchronized void arrangeArchive() {
		logger.info("BATCH - arrange archive video");
		videoService.arrangeArchiveVideo();
	}

	@Scheduled(fixedRate = 1000 * 60 * 13) // per 13 min
	public synchronized void arrangeSubFolder() {
		logger.info("BATCH - arrange sub-folder");
		videoService.arrangeSubFolder();
	}
	
	@Scheduled(fixedRate = 1000 * 60 * 60 * 24) // per day
	public synchronized void backup() {
		
		if (StringUtils.isBlank(BACKUP_PATH)) {
			logger.info("BATCH - backup path not set");
			return;
		}
		logger.info("BATCH - backup to {}", BACKUP_PATH);
		
		File backupPath = new File(BACKUP_PATH);
		if (!backupPath.exists())
			backupPath.mkdirs();

		// video list backup to csv
		List<Video> videoList = videoService.getVideoList();
		List<Video> archiveVideoList = videoService.getArchiveVideoList();
		List<String> rowList = new ArrayList<>();
		String csvHeader = "Type, Studio, Opus, Title, Actress, Released, Rank, Fullname";
		rowList.add(csvHeader);
		String csvFormat = "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%s,\"%s\"";
		for (Video video : videoList) {
			rowList.add(String.format(csvFormat, "INSTANCE", video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), video.getRank(), video.getFullname()));
		}
		for (Video video : archiveVideoList) {
			rowList.add(String.format(csvFormat, "ARCHIVE", video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), "", video.getFullname()));
		}
		try {
			FileUtils.writeLines(new File(backupPath, VIDEO.BACKUP_FILENAME), "EUC-KR", rowList, false); 
		} catch (IOException e) {
			logger.error("BATCH - csv list backup fail", e);
		}
		
		// _info folder backup to zip
		File src = new File(STORAGE_PATHS[0], "_info");
		ZipUtils zipUtils = new ZipUtils();
		try {
			zipUtils.zip(src, backupPath, VIDEO.ENCODING, true);
		} catch (IOException e) {
			logger.error("BATCH - info zip backup fail", e);
		}

		// history backup
		File historyFile = new File(STORAGE_PATHS[0], VIDEO.HISTORY_LOG_FILENAME);
		try {
			FileUtils.copyFileToDirectory(historyFile, backupPath);
		} catch (IOException e) {
			logger.error("BATCH - history file backup fail", e);
		}
		
		// tag data backup
		File tagFile = new File(STORAGE_PATHS[0], VIDEO.TAG_DATA_FILENAME);
		try {
			FileUtils.copyFileToDirectory(tagFile, backupPath);
		} catch (IOException e) {
			logger.error("BATCH - tag file backup fail", e);
		}
		
	}
}
