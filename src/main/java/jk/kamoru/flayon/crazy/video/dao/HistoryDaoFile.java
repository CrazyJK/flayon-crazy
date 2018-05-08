package jk.kamoru.flayon.crazy.video.dao;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.base.util.StopWatch;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.error.VideoNotFoundException;
import lombok.extern.slf4j.Slf4j;

/**
 * 
 * @author kamoru
 *
 */
@Component
@Slf4j
public class HistoryDaoFile implements HistoryDao {

	private static boolean isHistoryLoaded = false;
	
	@Autowired CrazyConfig config;
	@Autowired VideoDao videoDao;

	/** history file */
	private File historyFile;
	
	/** history list */
	private List<History> historyList = new ArrayList<>();

	/**
	 * return video history File<br>
	 * storagePath + {@link VIDEO#HISTORY_LOG_FILENAME}
	 * @return historyFile
	 */
	private File getHistoryFile() {
		if (historyFile == null) {
			historyFile = new File(config.getStoragePath(), VIDEO.HISTORY_LOG_FILENAME);
		}
		return historyFile;
	}

	private synchronized void loadHistory() throws IOException, ParseException {
		StopWatch stopWatch = new StopWatch("Load history");
		
		stopWatch.start();
		List<String> lines = FileUtils.readLines(getHistoryFile(), VIDEO.ENCODING);
		stopWatch.stop("read file. line " + lines.size());

		stopWatch.start();
		historyList.clear();
		for (String line : lines) {
			if (line.trim().length() == 0) {
				continue;
			}
			
			String[] split = StringUtils.split(line, ",", 4);
			History history = new History();
			if (split.length > 0)
				history.setDate(VIDEO.DateTimeFormat.parse(split[0].trim()));
			if (split.length > 1)
				history.setOpus(split[1].toUpperCase().trim());
			if (split.length > 2)
				history.setAction(Action.valueOf(split[2].toUpperCase().trim()));
			if (split.length > 3)
				history.setDesc(StringUtils.substringBetween(split[3], "[", "]"));
			try {
				history.setVideo(videoDao.getVideo(split[1].trim()));
			} catch (VideoNotFoundException ignore) {}
			historyList.add(history);
		}
		stopWatch.stop("parsed " + historyList.size());
		
		stopWatch.start("list reverse");
		Collections.reverse(historyList);
		stopWatch.stop();
		
		isHistoryLoaded = true;
		log.info("Load history\n\n{}", stopWatch.prettyPrint());
	}

	private List<History> historyList() {
		if (!isHistoryLoaded)
			try {
				loadHistory();
			} catch (Exception e) {
				throw new CrazyException("history load error", e);
			}
		return historyList;
	}
		
	@Override
	public void persist(History history) {
		historyList().add(history);
		try {
			FileUtils.writeStringToFile(getHistoryFile(), history.toFileSaveString(), VIDEO.ENCODING, true);
		} catch (IOException e) {
			throw new CrazyException("Fail to history save", e);
		}
	}

	@Override
	public List<History> getList() {
		return historyList();
	}

	@Override
	public List<History> find(String query) {
		return filter(history -> StringUtils.containsIgnoreCase(history.getDesc(), query));
	}

	@Override
	public List<History> find(Date date) {
		return filter(history -> DateUtils.isSameDay(history.getDate(), date));
	}

	@Override
	public List<History> find(Action action) {
		return filter(history -> history.getAction() == action);
	}

	@Override
	public List<History> find(Video video) {
		return filter(history -> history.getVideo() != null && history.getVideo().getOpus().equals(video.getOpus()));
	}

	@Override
	public List<History> find(Collection<Video> videoList) {
		List<History> found = new ArrayList<History>();
		for (Video video : videoList)
			found.addAll(filter(history -> history.getVideo().getOpus().equals(video.getOpus())));
		return found;
	}

	private List<History> filter(Predicate<? super History> predicate) {
		return historyList().stream().filter(predicate).collect(Collectors.toList());
	}

}
