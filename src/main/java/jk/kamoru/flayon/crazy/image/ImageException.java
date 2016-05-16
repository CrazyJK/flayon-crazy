package jk.kamoru.flayon.crazy.image;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.image.domain.Image;

public class ImageException extends CrazyException {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	private static final String KIND = "Image";

	private Image image; 
	
	public ImageException(Image image, String message, Throwable cause) {
		super(String.format("[%s] %s", image.getName(), message), cause);
		this.image = image;
	}

	public ImageException(Image image, String message) {
		super(String.format("[%s] %s", image.getName(), message));
		this.image = image;
	}

	public ImageException(Image image, Throwable cause) {
		super(String.format("[%s]", image.getName()), cause);
		this.image = image;
	}
	
	public ImageException(String message, Throwable cause) {
		super(message, cause);
	}
	
	public ImageException(String message) {
		super(message);
	}
	
	public Image getImage() {
		return image;
	}
	
	@Override
	public String getKind() {
		return KIND;
	}

}
