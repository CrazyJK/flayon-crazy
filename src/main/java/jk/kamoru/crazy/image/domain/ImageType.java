package jk.kamoru.crazy.image.domain;

/**
 * {@link #MASTER}, {@link #WEB}, {@link #THUMBNAIL}
 * @author kamoru
 *
 */
public enum ImageType {

	/**
	 * Original size
	 */
	MASTER(0), 
	/**
	 * width 500px size
	 */
	WEB(500), 
	/**
	 * width 100px size 
	 */
	THUMBNAIL(100);
	
	int size;
	
	ImageType(int size) {
		this.size = size;
	}
	
	int getSize() {
		return size;
	}
}
