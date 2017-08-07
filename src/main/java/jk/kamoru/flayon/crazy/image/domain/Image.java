package jk.kamoru.flayon.crazy.image.domain;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.apache.commons.io.FileUtils;
import org.imgscalr.Scalr;
import org.imgscalr.Scalr.Method;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.image.ImageException;
import lombok.Getter;

/**
 * Image Domain
 * @author kamoru
 *
 */
@Getter
public class Image {

	public enum Type {

		/** Original size */
		MASTER(0), 
		/** width 500px size */
		WEB(500), 
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
	
	private File file;

	public Image(File file) {
		this.file  = file;
	}

	public String getName() {
		return file.getName();
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
			ImageIO.write(bi, "gif", outputStream);
			return outputStream.toByteArray();
		} catch (IOException e) {
			throw new CrazyException("read bufferedImage error", e);
		}
	}

}
