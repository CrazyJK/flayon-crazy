package jk.kamoru.flayon.crazy.error;

import jk.kamoru.flayon.crazy.CRAZY;

public class ImageNotFoundException extends NotFoundException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public ImageNotFoundException(int idx) {
		super("Image [" + idx + "] not found", KIND.ImageNotFound);
	}

	public ImageNotFoundException(int idx, Throwable cause) {
		super("Image [" + idx + "] not found", cause, KIND.ImageNotFound);
	}

	public ImageNotFoundException(String message, Throwable cause) {
		super(message, cause, KIND.ImageNotFound);
	}

}
