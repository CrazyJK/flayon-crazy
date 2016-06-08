package jk.kamoru.flayon.crazy.video.domain;

import java.io.Serializable;

import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.Data;

@Data
public class HistoryData implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	String date;
	int play;
	int overview;
	int cover;
	int subtitles;
	int remove;
	int delete;
	int rank;

	public HistoryData(String date) {
		this.date = date;
	}

	public void add(History history) {
		switch (history.getAction()) {
			case PLAY: 		play++; 		break;
			case OVERVIEW: 	overview++; 	break;
			case COVER: 	cover++; 		break;
			case SUBTITLES: subtitles++; 	break;
			case REMOVE: 	
			case DELETE: 	remove++; 		break;
			case RANK: 		rank++; 		break;
		}
		
	}
	
}

