package jk.kamoru.crazy.video.dao;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import jk.kamoru.crazy.video.domain.Action;
import jk.kamoru.crazy.video.domain.History;
import jk.kamoru.crazy.video.domain.Video;

public interface HistoryDao {

	void persist(History history) throws IOException;
	
	List<History> getList();

	List<History> find(String query);

	List<History> findByOpus(String opus);
	
	List<History> findByDate(Date date);
	
	List<History> findByAction(Action action);
	
	List<History> findByVideo(Video video);

	List<History> findByVideo(List<Video> videoList);

}
