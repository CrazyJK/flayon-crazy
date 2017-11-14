package jk.kamoru.flayon.crazy.video;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
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
import jk.kamoru.flayon.crazy.error.VideoException;
import jk.kamoru.flayon.crazy.util.ZipUtils;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;

@Component
public class VideoBatch extends CrazyProperties {

	private static final Logger logger = LoggerFactory.getLogger(VideoBatch.class);

	public static enum Option {
		/** MOVE_WATCHED_VIDEO */ W, /** DELETE_LOWER_RANK_VIDEO */ R, /** DELETE_LOWER_SCORE_VIDEO */ S;
	}
	
	public static enum Type {
		/** InstanceVideoSource */ I, /** ArchiveVideoSource */ A, /** Backup */ B,
		/** MOVE_WATCHED_VIDEO */ W, /** DELETE_LOWER_RANK_VIDEO */ R, /** DELETE_LOWER_SCORE_VIDEO */ S;
	}
	
	@Autowired   VideoService   videoService;
	@Autowired HistoryService historyService;

	public Boolean setBatchOption(Option option, boolean setValue) {
		try {
			switch (option) {
			case R:
				return DELETE_LOWER_RANK_VIDEO = setValue;
			case S:
				return DELETE_LOWER_SCORE_VIDEO = setValue;
			case W:
				return MOVE_WATCHED_VIDEO = setValue;
			default:
				throw new VideoException("batch option key is invalid. k=" + option);
			}
		} finally {
			showProperties();
		}
	}

	public Boolean getBatchOption(Option option) {
		switch (option) {
		case R:
			return DELETE_LOWER_RANK_VIDEO;
		case S:
			return DELETE_LOWER_SCORE_VIDEO;
		case W:
			return MOVE_WATCHED_VIDEO;
		default:
			throw new VideoException("batch option key is invalid. k=" + option);
		}
	}

	public void startBatch(Type type) {
		switch(type) {
		case I:
			batchInstanceVideoSource(); 
			break;
		case A:
			batchArchiveVideoSource(); 
			break;
		case B:
			try {
				backup();
				 break;
			} catch (IOException e) {
				throw new VideoException("batch.backup error", e);
			}
		case R:
			videoService.removeLowerRankVideo();
			break;
		case S:
			videoService.removeLowerScoreVideo();
			break;
		case W:
			videoService.moveWatchedVideo();
			break;
		default:
			throw new VideoException("unknown videobatch type : " + type);
		}
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
		
		logger.info(" - delete empty folder");
		videoService.deletEmptyFolder();

		videoService.reload(stopWatch);

		logger.info("BATCH Instance VideoSource END\n\n{}", stopWatch.prettyPrint());
		
		NotiQueue.pushNoti("Instance VideoBatch end");
	}

	// cron every 2h 13m
	@Scheduled(cron="0 13 */2 * * *")
	public synchronized void batchArchiveVideoSource() {
		logger.info("BATCH Archive VideoSource START");
		
		logger.info(" - arrange to DateFormat folder");
		videoService.arrangeArchiveVideo();
		
		videoService.reloadArchive();

		logger.info("BATCH Archive VideoSource END");

		NotiQueue.pushNoti("Archive VideoBatch end");
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

		NotiQueue.pushNoti("Delete empty folder end");
	}
	
//	@Scheduled(fixedDelay = 1000 * 60 * 60 * 24) // fixedDelay per day 
//	@PreDestroy
	// cron every 2h 13m
	@Scheduled(cron="0 0 0 * * *")
	public synchronized void backup() throws IOException {
		
		if (StringUtils.isBlank(BACKUP_PATH)) {
			logger.warn("BATCH - backup path not set");
			return;
		}
		logger.info("BATCH - backup to {}", BACKUP_PATH);
		
		File backupPath = new File(BACKUP_PATH);
		if (!backupPath.exists())
			backupPath.mkdirs();

		final String csvHeader = "Studio, Opus, Title, Actress, Released, Rank, Fullname";
		final String csvFormat = "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%s,\"%s\"";

		// video list backup to csv
		List<Video>        videoList =   videoService.getVideoList(true, false);
		List<Video> archiveVideoList =   videoService.getVideoList(false, true);
		List<History>    historyList = historyService.getDeduplicatedList();
		List<String>    instanceList = new ArrayList<>();
		List<String>     archiveList = new ArrayList<>();

		// instance
		instanceList.add(csvHeader);
		for (Video video : videoList)
			instanceList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), video.getRank(), video.getFullname()));
		// archive
		archiveList.add(csvHeader);
		for (Video video : archiveVideoList)
			archiveList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), "", video.getFullname()));
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
				archiveList.add(String.format(csvFormat, "", history.getOpus(), "", "", "", "", history.getDesc()));
		}
		FileUtils.writeLines(new File(backupPath, VIDEO.BACKUP_INSTANCE_FILENAME), "EUC-KR", instanceList, false); 
		FileUtils.writeLines(new File(backupPath, VIDEO.BACKUP_ARCHIVE_FILENAME),  "EUC-KR", archiveList,  false); 
		
		// history backup
		FileUtils.copyFileToDirectory(new File(STORAGE_PATH, VIDEO.HISTORY_LOG_FILENAME), backupPath);
		
		// tag data backup
		FileUtils.copyFileToDirectory(new File(STORAGE_PATH, VIDEO.TAG_DATA_FILENAME), backupPath);
		
		// zip to cover, info, subtitles file on instance
		//File backupTemp = new File(QUEUE_PATH, "backuptemp"); 
		//Files.createTempDirectory(VIDEO.BACKUP_FILE_FILENAME).toFile();
		File backupTemp = Files.createDirectory(Paths.get(QUEUE_PATH, "backuptemp")).toFile();
		for (Video video : videoList)
			for (File file : video.getFileWithoutVideo())
				if (file != null && file.exists())
					FileUtils.copyFileToDirectory(file, backupTemp, false);
		ZipUtils.zip(backupTemp, backupPath, VIDEO.BACKUP_FILE_FILENAME, VIDEO.ENCODING, true);
		FileUtils.deleteDirectory(backupTemp);
		
		// _info folder backup to zip
		ZipUtils.zip(new File(STORAGE_PATH, "_info"), backupPath, VIDEO.BACKUP_INFO_FILENAME, VIDEO.ENCODING, true);

		NotiQueue.pushNoti("Backup completed");
	}
}
