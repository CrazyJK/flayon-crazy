package jk.kamoru.flayon.crazy.video.dao;

import java.util.Collection;
import java.util.Date;
import java.util.List;

import jk.kamoru.flayon.crazy.video.domain.Action;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;

public interface HistoryDao {

	void persist(History history);

	List<History> getList();

	List<History> find(String query);

	List<History> find(Date date);

	List<History> find(Action action);

	List<History> find(Video video);

	List<History> find(Collection<Video> videos);
}
