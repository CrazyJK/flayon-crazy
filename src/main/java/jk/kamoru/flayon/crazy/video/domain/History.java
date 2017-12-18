package jk.kamoru.flayon.crazy.video.domain;

import java.io.Serializable;
import java.text.MessageFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Transient;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.Data;

@Entity
@Data
public class History implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;

	private Date date;
	private String opus;
	private Action action;
	private String desc;
	
	@Transient
	private Video video;
	
	public History() {}
	
	public History(Video video, Action action) {
		this.video = video;
		this.action = action;
		this.opus = video.getOpus();
		this.date = new Date();
	}
	
	public String toFileSaveString() {
		String desc = null; 
		switch(action) {
			case PLAY :
			case OVERVIEW :
			case COVER :
			case SUBTITLES :
			case REMOVE :
				desc = video.getFullname();
				break;
			case RANK :
				desc = video.getRank() + " - " + video.getFullname();
				break;
			default:
				desc = "Undefined Action : " + action.toString();
		}
		this.desc = desc;
		return MessageFormat.format("{0}, {1}, {2}, \"{3}\"{4}",
				new SimpleDateFormat(VIDEO.DATE_TIME_PATTERN).format(date), 
				video.getOpus(), 
				action, 
				desc, 
				CRAZY.LINE);
	}

	public String getStudio() {
		TitleValidator validator = new TitleValidator(desc);
		return validator.isInvalid() ? "" : validator.getStudio();
	}
	
	@Override
	public String toString() {
		return String.format("History [date=%s, opus=%s, action=%s, desc=%s]", date, opus, action, desc);
	}

}
