package jk.kamoru.flayon.crazy.image;



public class ImageNotFoundException extends ImageException {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	private static final String KIND = "ImageNotFound";

	public ImageNotFoundException(int idx) {
		super(String.format("Image not found - %s", idx));
		super.setKind(KIND);
	}

	public ImageNotFoundException(int idx, Throwable cause) {
		super(String.format("Image not found - %s", idx), cause);
		super.setKind(KIND);
	}

}
