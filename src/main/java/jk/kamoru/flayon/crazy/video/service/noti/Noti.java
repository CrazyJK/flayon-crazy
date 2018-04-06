package jk.kamoru.flayon.crazy.video.service.noti;

import lombok.Data;

@Data
public class Noti {

	long time;
	String message;
	
	public Noti() {
		this(0, "");
	}
	
	public Noti(long time, String message) {
		this.time = time;
		this.message = message;
	}

}
