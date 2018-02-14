package jk.kamoru.flayon.crazy.video;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyNotFoundException;

public class VideoNotFoundException extends CrazyNotFoundException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public VideoNotFoundException(String opus, Throwable cause) {
		super("Video [" + opus + "] not found", cause, KIND.VideoNotFound);
	}

	public VideoNotFoundException(String opus) {
		super("Video [" + opus + "] not found", KIND.VideoNotFound);
	}
	
}
