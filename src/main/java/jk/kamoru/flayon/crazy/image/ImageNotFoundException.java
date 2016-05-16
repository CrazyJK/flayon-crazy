package jk.kamoru.flayon.crazy.image;



public class ImageNotFoundException extends ImageException {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	public ImageNotFoundException(int idx) {
		super(String.format("Image not found - %s", idx));
	}

	public ImageNotFoundException(int idx, Throwable cause) {
		super(String.format("Image not found - %s", idx), cause);
	}

}
