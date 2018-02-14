package jk.kamoru.flayon.crazy.video.service;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.dao.HistoryDao;
import jk.kamoru.flayon.crazy.video.dao.HistoryRepository;
import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.HistoryData;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.Video;

@Service
@Slf4j
public class HistoryServiceImpl implements HistoryService {

	@Autowired HistoryDao historyDao;
	@Autowired HistoryRepository historyRepository;

	@Override
	public void persist(History history) {
		try {
			historyDao.persist(history);
			historyRepository.save(history);
		} catch (IOException e) {
			throw new CrazyException("history persist error", e);
		}
	}

	@Override
	public List<History> findByOpus(String opus) {
		log.info("find opus {}", opus);
		if (StringUtils.isBlank(opus))
			return dummyList();
		return historyDao.findByOpus(opus);
	}

	@Override
	public List<History> findByVideo(Video video) {
		return historyDao.findByVideo(video);
	}

	@Override
	public List<History> findByStudio(Studio studio) {
		return historyDao.findByVideo(studio.getVideoList());
	}

	@Override
	public List<History> findByActress(Actress actress) {
		return historyDao.findByVideo(actress.getVideoList());
	}

	@Override
	public List<History> findByQuery(String query) {
		if (StringUtils.isBlank(query))
			return dummyList();
		return historyDao.find(query);
	}

	@Override
	public List<History> getAll() {
		return historyDao.getList();
	}

	@Override
	public List<History> findByDate(Date date) {
		return historyDao.findByDate(date);
	}

	@Override
	public List<History> findByAction(Action action) {
		return historyDao.findByAction(action);
	}
	
	@Override
	public boolean contains(String opus) {
		return historyDao.findByOpus(opus).size() > 0;
	}
	
	private List<History> dummyList() {
		return new ArrayList<History>();
	}

	@Override
	public List<History> getDeduplicatedList() {
		Map<String, History> found = new HashMap<>();
		for (History history : historyDao.getList()) {
			if (!found.containsKey(history.getOpus()))
				found.put(history.getOpus(), history);
		}
		return new ArrayList<History>(found.values());
	}

	@Override
	public Collection<HistoryData> getGraphData(String pattern) {
		SimpleDateFormat sdf = null;
		try {
			sdf = new SimpleDateFormat(pattern);
		} catch (Exception onlyShowForm) { // 패턴이 틀릴경우 - view만 보여주는 경우, 빈 리스트 반환
			return new ArrayList<>();
		}
		
		Map<String, HistoryData> data = new TreeMap<>(); 
		for (History history : historyDao.getList()) {
			String month = sdf.format(history.getDate());
			if (data.containsKey(month)) {
				HistoryData historyDate = data.get(month);
				historyDate.add(history);
			}
			else {
				HistoryData historyData = new HistoryData(month);
				historyData.add(history);
				data.put(month, historyData);
			}
		}
		return data.values();
	}

	@Override
	public List<History> findOnDB() {
		return historyRepository.findAll();
	}
	
}
