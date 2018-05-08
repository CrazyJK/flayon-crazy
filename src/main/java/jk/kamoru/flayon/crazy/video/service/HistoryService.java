package jk.kamoru.flayon.crazy.video.service;

import java.util.Collection;
import java.util.Date;
import java.util.List;

import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.HistoryData;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.Video;

public interface HistoryService {

	/** History 저장 */
	void persist(History history);
	
	/** 검색어로 찾기 */
	List<History> find(String query);
	
	/** Video로 찾기 */
	List<History> find(Video video);

	/** Studio로 찾기 */
	List<History> find(Studio studio);

	/** Actress로 찾기 */
	List<History> find(Actress actress);

	/** 날짜로 찾기 */
	List<History> find(Date date);

	/** Action로 찾기 */
	List<History> find(Action action);
	
	/** 모든 History */
	List<History> getAll();

	/** opus가 있었는지 */
	boolean contains(String opus);
	
	/** 중복 제거한 비디오 히스토리 */
	List<History> getDeduplicatedList();

	Collection<HistoryData> getGraphData(String pattern);

	List<History> findOnDB();
	
}
