package jk.kamoru.flayon.crazy.video.service.queue;

import lombok.Data;

@Data
public class Noti {

	long timeMillis;
	String message;
	
	public Noti() {
		this(0, "");
	}
	
	public Noti(long timeMillis, String message) {
		super();
		this.timeMillis = timeMillis;
		this.message = message;
	}

}
