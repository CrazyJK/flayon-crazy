package jk.kamoru.flayon.crazy.image;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.image.domain.Image;

public class ImageException extends CrazyException {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	private static final String KIND = "Image";

	private Image image; 
	
	public ImageException(Image image, String message, Throwable cause) {
		super(String.format("[%s] %s", image.getName(), message), cause);
		super.setKind(KIND);
		this.image = image;
	}

	public ImageException(Image image, String message) {
		super(String.format("[%s] %s", image.getName(), message));
		super.setKind(KIND);
		this.image = image;
	}

	public ImageException(Image image, Throwable cause) {
		super(String.format("[%s]", image.getName()), cause);
		super.setKind(KIND);
		this.image = image;
	}
	
	public ImageException(String message, Throwable cause) {
		super(message, cause);
		super.setKind(KIND);
	}
	
	public ImageException(String message) {
		super(message);
		super.setKind(KIND);
	}
	
	public Image getImage() {
		return image;
	}

}
