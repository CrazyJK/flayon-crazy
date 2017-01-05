package jk.kamoru.flayon.crazy.video.dao;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;

@Component
@Slf4j
public class HistoryDaoFile extends CrazyProperties implements HistoryDao {

	/** history file */
	private File historyFile;
	/** history list */
	private List<History> historyList;
	
	private static boolean isHistoryLoaded = false;

	@Autowired VideoDao videoDao;

/*	히스토리 파일이 없으면 안되므로, 생성하지 않는다
	@PostConstruct
	public void init() {
		if (!getHistoryFile().exists())
			try {
				getHistoryFile().createNewFile();
				log.warn("history file created {}", getHistoryFile().getAbsolutePath());
			} catch (IOException e) {
				log.error("history cannot create", e);
			}
	}
*/
	
	private File getHistoryFile() {
		if(historyFile == null)
			historyFile = new File(STORAGE_PATH, VIDEO.HISTORY_LOG_FILENAME);
		return historyFile;
	}

	private synchronized void loadHistory() throws IOException, ParseException {
		historyList = new ArrayList<>();
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(VIDEO.DATE_TIME_PATTERN);
		StopWatch stopWatch = new StopWatch("Load history");

		stopWatch.start("read line");
		List<String> lines = FileUtils.readLines(getHistoryFile(), VIDEO.ENCODING);
		stopWatch.stop();

		stopWatch.start("parse history " + lines.size() + " lines");
		for (String line : lines) {
			if (line.trim().length() > 0) {
				String[] split = StringUtils.split(line, ",", 4);
				History history = new History();
				if (split.length > 0)
					history.setDate(simpleDateFormat.parse(split[0].trim()));
				if (split.length > 1)
					history.setOpus(split[1].trim());
				if (split.length > 2)
					history.setAction(Action.valueOf(split[2].toUpperCase().trim()));
				if (split.length > 3)
					history.setDesc(trimDesc(split[3]));
				try {
					history.setVideo(videoDao.getVideo(split[1].trim()));
				}
				catch (VideoNotFoundException ignore) {}
				historyList.add(history);
			}
		}
		stopWatch.stop();
		
		stopWatch.start("list reverse");
		Collections.reverse(historyList);
		stopWatch.stop();
		
		log.info("Load history\n\n{}", stopWatch.prettyPrint());
	}
	
	private String trimDesc(String desc) {
		if (desc == null) 
			return "";
		int startIdx = StringUtils.indexOf(desc, "[");
		int lastIdx  = StringUtils.lastIndexOf(desc, "]");
		return StringUtils.substring(desc, startIdx, lastIdx + 1);
	}

	private List<History> historyList() {
		if (!isHistoryLoaded)
			try {
				loadHistory();
				isHistoryLoaded = true;
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
		List<History> found = new ArrayList<History>();
		for (History history : historyList()) {
			if (StringUtils.containsIgnoreCase(history.getDesc(), query))
				found.add(history);
		}
		return found;
	}

	@Override
	public List<History> findByOpus(String opus) {
		List<History> found = new ArrayList<History>();
		for (History history : historyList()) {
			if (StringUtils.equalsIgnoreCase(history.getOpus(), opus))
				found.add(history);
		}
		return found;
	}

	@Override
	public List<History> findByDate(Date date) {
		List<History> found = new ArrayList<History>();
		for (History history : historyList()) {
			if (DateUtils.isSameDay(history.getDate(), date))
				found.add(history);
		}
		return found;
	}

	@Override
	public List<History> findByAction(Action action) {
		List<History> found = new ArrayList<History>();
		for (History history : historyList()) {
			if (history.getAction() == action)
				found.add(history);
		}
		return found;
	}

	@Override
	public List<History> findByVideo(Video video) {
		List<History> found = new ArrayList<History>();
		for (History history : historyList()) {
			if (history.getVideo() != null && history.getVideo().getOpus().equals(video.getOpus()))
				found.add(history);
		}
		return found;
	}

	@Override
	public List<History> findByVideo(List<Video> videoList) {
		List<History> found = new ArrayList<History>();
		for (Video video : videoList)
			for (History history : historyList()) {
				if (history.getVideo().getOpus().equals(video.getOpus()))
					found.add(history);
			}
		return found;
	}


}
