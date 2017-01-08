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
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import jk.kamoru.flayon.crazy.video.util.ZipUtils;

@Component
public class VideoBatch extends CrazyProperties {

	private static final Logger logger = LoggerFactory.getLogger(VideoBatch.class);

	@Autowired VideoService videoService;
	@Autowired HistoryService historyService;

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
	
	// cron every 1h
	@Scheduled(cron="0 0 */1 * * *")
	public synchronized void batchInstanceVideoSource() {
		logger.info("BATCH Instance VideoSource START");
		StopWatch stopWatch = new StopWatch("Instance VideoSource Batch");

		logger.info(" - delete lower rank video [{}]", DELETE_LOWER_RANK_VIDEO);
		if (DELETE_LOWER_RANK_VIDEO) {
			stopWatch.start("delete lower rank");
			videoService.removeLowerRankVideo();
			stopWatch.stop();
		}
		
		logger.info(" - delete lower score video [{}]", DELETE_LOWER_SCORE_VIDEO);
		if (DELETE_LOWER_SCORE_VIDEO) {
			stopWatch.start("delete lower score");
			videoService.removeLowerScoreVideo();
			stopWatch.stop();
		}
		
		logger.info(" - delete garbage file");
		stopWatch.start("delete garbage file");
		videoService.deleteGarbageFile();
		stopWatch.stop();
		
		logger.info(" - arrange to same folder");
		stopWatch.start("arrange to same folder");
		videoService.arrangeVideo();
		stopWatch.stop();
		
		logger.info(" - move watched video [{}]", MOVE_WATCHED_VIDEO);
		if (MOVE_WATCHED_VIDEO) {
			stopWatch.start("move watched video");
			videoService.moveWatchedVideo();
			stopWatch.stop();
		}
		
		videoService.reload(stopWatch);

		logger.info("BATCH Instance VideoSource END\n\n{}", stopWatch.prettyPrint());
	}

	// cron every 2h 13m
	@Scheduled(cron="0 13 */2 * * *")
	public synchronized void batchArchiveVideoSource() {
		logger.info("BATCH Archive VideoSource START");
		
		logger.info(" - arrange to DateFormat folder");
		videoService.arrangeArchiveVideo();
		
		videoService.reloadArchive();

		logger.info("BATCH Archive VideoSource END");
	}

	// fixedDelay per 1 min
	@Scheduled(fixedDelay = 1000 * 60) 
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
	
	// fixedRate per 13 min
	@Scheduled(fixedRate = 1000 * 60 * 13) 
	public synchronized void deletEmptyFolder() {
		logger.info("BATCH - delete empty folder");
		videoService.deletEmptyFolder();
	}
	
	// fixedRate per day
	@Scheduled(fixedRate = 1000 * 60 * 60 * 24) 
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
		List<Video> videoList = videoService.getVideoList(null, false, true, false);
		List<Video> archiveVideoList = videoService.getVideoList(null, false, false, true);
		List<History> historyList = historyService.getDeduplicatedList();

		final String csvHeader = "Studio, Opus, Title, Actress, Released, Rank, Fullname";
		final String csvFormat = "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%s,\"%s\"";
		// instance
		List<String> rowList = new ArrayList<>();
		rowList.add(csvHeader);
		for (Video video : videoList) {
			rowList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), video.getRank(), video.getFullname()));
		}
		try {
			FileUtils.writeLines(new File(backupPath, VIDEO.BACKUP_INSTANCE_FILENAME), "EUC-KR", rowList, false); 
		} catch (IOException e) {
			logger.error("BATCH - backup instance fail", e);
		}
		// archive
		rowList.clear();
		rowList.add(csvHeader);
		for (Video video : archiveVideoList) {
			rowList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), "", video.getFullname()));
		}
		for (History history : historyList) {
			String opus = history.getOpus();
			boolean foundInArchive = false;
			for (Video video : archiveVideoList) {
				if (video.getOpus().equals(opus)) {
					foundInArchive = true;
					break;
				}
			}
			if (!foundInArchive)
				rowList.add(String.format(csvFormat, "", history.getOpus(), "", "", "", "", history.getDesc()));
		}
		try {
			FileUtils.writeLines(new File(backupPath, VIDEO.BACKUP_ARCHIVE_FILENAME), "EUC-KR", rowList, false); 
		} catch (IOException e) {
			logger.error("BATCH - backup archive fail", e);
		}
		
		// _info folder backup to zip
		File src = new File(STORAGE_PATH, "_info");
		ZipUtils zipUtils = new ZipUtils();
		try {
			zipUtils.zip(src, backupPath, VIDEO.ENCODING, true);
		} catch (IOException e) {
			logger.error("BATCH - info zip backup fail", e);
		}

		// history backup
		File historyFile = new File(STORAGE_PATH, VIDEO.HISTORY_LOG_FILENAME);
		try {
			FileUtils.copyFileToDirectory(historyFile, backupPath);
		} catch (IOException e) {
			logger.error("BATCH - history file backup fail", e);
		}
		
		// tag data backup
		File tagFile = new File(STORAGE_PATH, VIDEO.TAG_DATA_FILENAME);
		try {
			FileUtils.copyFileToDirectory(tagFile, backupPath);
		} catch (IOException e) {
			logger.error("BATCH - tag file backup fail", e);
		}
		
	}
}
