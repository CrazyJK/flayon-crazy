package jk.kamoru.flayon.crazy.image.domain;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.Serializable;

import javax.imageio.ImageIO;

import org.apache.commons.io.FileUtils;
import org.imgscalr.Scalr;
import org.imgscalr.Scalr.Method;

import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.error.ImageException;
import jk.kamoru.flayon.crazy.image.IMAGE;
import jk.kamoru.flayon.util.IOUtils;
import jk.kamoru.flayon.util.ImageUtils;
import lombok.Getter;

/**
 * Image Domain
 * @author kamoru
 *
 */
@Getter
public class Image implements Serializable {

	private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;

	public enum Type {

		/** Original size */
		MASTER(0), 
		/** width 500px size */
		WEB(500), 
		/** width 500px, with Title */
		TITLE(500),
		/**  width 100px size */
		THUMBNAIL(100);
		
		int size;
		
		Type(int size) {
			this.size = size;
		}
		
		int getSize() {
			return size;
		}
	}

	@Getter
	public class Info implements Serializable {
		private static final long serialVersionUID = IMAGE.SERIAL_VERSION_UID;
		String name;
		String path;
		long length;
		long lastModified;
		
		public Info(File file) {
			this.name = file.getName();
			this.path = file.getParent();
			this.length = file.length();
			this.lastModified = file.lastModified();
		}
	}
	
	private File file;
	private Info info;

	public Image(File file) {
		this.file = file;
		this.info = new Info(file);
	}

	public byte[] getByteArray() {
		return getByteArray(Type.MASTER);
	}
	
	/**
	 * return byte array of image file
	 * @param type
	 * @return image file byte array
	 */
	public byte[] getByteArray(Type type) {
		try {
			switch (type) {
			case MASTER:
				return FileUtils.readFileToByteArray(file);
			case TITLE:
				return ImageUtils.mergeTextToImage(ImageIO.read(file), info.getName(), "D2Coding", 18);
			case WEB:
				return readBufferedImageToByteArray(
						Scalr.resize(
								ImageIO.read(file), 
								Scalr.Mode.FIT_TO_WIDTH, 
								Type.WEB.getSize()));
			case THUMBNAIL:
				return readBufferedImageToByteArray(
						Scalr.resize(
								ImageIO.read(file), 
								Method.SPEED, 
								Type.THUMBNAIL.getSize(), 
								Scalr.OP_ANTIALIAS, 
								Scalr.OP_BRIGHTER));
			default:
				throw new CrazyException("unknown PictureType = " + type);
			}
		} catch (IOException e) {
			throw new ImageException(this, "image io error", e);
		}
	}

	/**
	 * {@link BufferedImage}를 읽어 byte[]로 반환 
	 * @param bi
	 * @return
	 */
	private byte[] readBufferedImageToByteArray(BufferedImage bi) {
		try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
			ImageIO.setUseCache(false);
			ImageIO.write(bi, IOUtils.getSuffix(file), outputStream);
			return outputStream.toByteArray();
		} catch (IOException e) {
			throw new CrazyException("read bufferedImage error", e);
		}
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((file == null) ? 0 : file.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Image other = (Image) obj;
		if (file == null) {
			if (other.file != null)
				return false;
		} else if (!file.getName().equals(other.file.getName()))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Image [" + file + "]";
	}

}
