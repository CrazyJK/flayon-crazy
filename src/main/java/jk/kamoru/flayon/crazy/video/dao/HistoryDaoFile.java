package jk.kamoru.flayon.crazy.video.dao;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

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
	
	/** whether or not history changed */
	private static boolean isHistoryChanged = true;

	@Autowired VideoDao videoDao;
	
//	@PostConstruct
//	public void init() {
//		if (!getHistoryFile().exists())
//			try {
//				getHistoryFile().createNewFile();
//				log.warn("history file created {}", getHistoryFile().getAbsolutePath());
//			} catch (IOException e) {
//				log.error("history cannot create", e);
//			}
//	}
	
	/**get history file
	 * @return {@link #historyFile}
	 */
	private File getHistoryFile() {
		if(historyFile == null)
			historyFile = new File(STORAGE_PATHS[0], "history.log");
		log.debug("history file is {}", historyFile.getAbsolutePath());
		return historyFile;
	}

	private synchronized void loadHistory() throws IOException, ParseException {
		historyList = new ArrayList<History>();

		List<String> lines = FileUtils.readLines(getHistoryFile(), VIDEO.FILE_ENCODING);
		log.debug("read history.log size={}", historyList.size());

		for (String line : lines) {
			if (line.trim().length() > 0) {
				String[] parts = StringUtils.split(line, ",", 4);
				History history = new History();
				try {
					if (parts.length > 0)
						history.setDate(new SimpleDateFormat(VIDEO.DATE_TIME_PATTERN).parse(parts[0].trim()));
					if (parts.length > 1)
						history.setOpus(parts[1].trim());
					if (parts.length > 2)
						history.setAction(Action.valueOf(parts[2].toUpperCase().trim()));
					if (parts.length > 3)
						history.setDesc(parts[3].trim());
					history.setVideo(videoDao.getVideo(parts[1].trim()));
				}
				catch (VideoNotFoundException e) {
					log.trace("{}", e.getMessage());
				}
//				catch (Exception e) {
//					log.warn("{} - {}", e.getMessage(), line);
//				}
				historyList.add(history);
			}
		}
		log.debug("historyList.size = {}", historyList.size());
		isHistoryChanged = false;
	}
	
	private void saveHistory(History history) throws IOException {
		FileUtils.writeStringToFile(getHistoryFile(), history.toFileSaveString(), VIDEO.FILE_ENCODING, true);
		isHistoryChanged = true;
	}

	private List<History> historyList() {
		if (isHistoryChanged)
			try {
				loadHistory();
			} catch (Exception e) {
				throw new CrazyException("history load error", e);
			}
		return historyList;
	}
		
	@Override
	public void persist(History history) throws IOException {
		historyList().add(history);
		saveHistory(history);
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
