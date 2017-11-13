package jk.kamoru.flayon.crazy.error;

import jk.kamoru.flayon.crazy.image.IMAGE;
import jk.kamoru.flayon.crazy.image.domain.Image;

public class ImageException extends CrazyException {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	private Image image; 
	
	public ImageException(Image image, String message, Throwable cause) {
		super(String.format("%s [%s]", message, image.getName()), cause, KIND.Image);
		this.image = image;
	}

	public ImageException(Image image, String message) {
		super(String.format("%s [%s]", message, image.getName()), KIND.Image);
		this.image = image;
	}
	
	public ImageException(String message, Throwable cause) {
		super(message, cause, KIND.Image);
	}
	
	public ImageException(String message) {
		super(message, KIND.Image);
	}
	
	public Image getImage() {
		return image;
	}

//	@Override
//    public String toString() {
//        String message = getClass().getName() + ": " + getLocalizedMessage();
//        return (image != null) ? (message + ": " + image) : message;
//    }

}
