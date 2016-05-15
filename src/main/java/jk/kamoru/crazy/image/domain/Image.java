package jk.kamoru.crazy.image.domain;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

import jk.kamoru.crazy.CrazyException;
import jk.kamoru.crazy.image.ImageException;
import jk.kamoru.util.FileUtils;
import lombok.Cleanup;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import org.imgscalr.Scalr;
import org.imgscalr.Scalr.Method;

/**
 * Image Domain
 * @author kamoru
 *
 */
@Data
@Slf4j
public class Image {

	private int idx;
	private String name;
	private String suffix;
	private long size;
	private long lastModified;
	private File file;

	public Image(File file) {
		this(file, -1);
	}

	public Image(File file, int i) {
		this.file = file;
		this.idx = i;
		init();
	}

	private void init() {
		this.name = file.getName();
		this.suffix = FileUtils.getExtension(file);
		this.size = file.length();
		this.lastModified = file.lastModified();
	}

	/**
	 * return byte array of image file
	 * @param type
	 * @return image file byte array
	 */
	public byte[] getByteArray(ImageType type) {
		try {
			switch (type) {
			case MASTER:
				return FileUtils.readFileToByteArray(file);
			case WEB:
				return readBufferedImageToByteArray(
						Scalr.resize(
								ImageIO.read(file), 
								Scalr.Mode.FIT_TO_WIDTH, 
								ImageType.WEB.getSize()));
			case THUMBNAIL:
				return readBufferedImageToByteArray(
						Scalr.resize(
								ImageIO.read(file), 
								Method.SPEED, 
								ImageType.THUMBNAIL.getSize(), 
								Scalr.OP_ANTIALIAS, 
								Scalr.OP_BRIGHTER));
			default:
				throw new CrazyException("unknown PictureType = " + type);
			}
		} catch (IOException e) {
			throw new ImageException(this, "image io error", e);
		}
	}

	private byte[] readBufferedImageToByteArray(BufferedImage bi) throws IOException {
		@Cleanup
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		ImageIO.setUseCache(false);
		ImageIO.write(bi, "gif", outputStream);
		return outputStream.toByteArray();
	}

	/**
	 * delete image file
	 */
	public void delete() {
		FileUtils.deleteQuietly(file);
		log.info("DELETE - {}", name);
	}

}
