package jk.kamoru.flayon.crazy.video;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.Video;

/**video에서 발생하는 에러
 * @author kamoru
 */
public class VideoException extends CrazyException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String KIND = "Video";

	private Video video;
	
	public VideoException(String message, Throwable cause) {
		super(message, cause);
		super.setKind(KIND);
	}

	public VideoException(String message) {
		super(message);
		super.setKind(KIND);
	}

	public VideoException(Throwable cause) {
		super(cause);
		super.setKind(KIND);
	}

	public VideoException(Video video, String message, Throwable cause) {
		super(String.format("[%s] %s", video.getOpus(), message), cause);
		super.setKind(KIND);
		this.video = video;
	}

	public VideoException(Video video, String message) {
		super(String.format("[%s] %s", video.getOpus(), message));
		super.setKind(KIND);
		this.video = video;
	}

	public VideoException(Video video, Throwable cause) {
		super(String.format("[%s]", video.getOpus()), cause);
		super.setKind(KIND);
		this.video = video;
	}

	public Video getVideo() {
		return video;
	}

}
