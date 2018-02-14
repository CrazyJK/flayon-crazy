package jk.kamoru.flayon.crazy.video;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.Video;

/**video에서 발생하는 에러
 * @author kamoru
 */
public class VideoException extends CrazyException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private Video video;
	
	public VideoException(String message, Throwable cause) {
		super(message, cause, KIND.Video);
	}

	public VideoException(String message) {
		super(message, KIND.Video);
	}

	public VideoException(Video video, String message, Throwable cause) {
		super(String.format("[%s] %s", video.getOpus(), message), cause, KIND.Video);
		this.video = video;
	}

	public VideoException(Video video, String message) {
		super(String.format("[%s] %s", video.getOpus(), message), KIND.Video);
		this.video = video;
	}

	public Video getVideo() {
		return video;
	}

}
