package jk.kamoru.flayon.crazy.image.service;

import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.domain.ImageType;

/**
 * Image Service
 * @author kamoru
 *
 */
public interface ImageService {

	/**
	 * return image
	 * @param idx
	 * @return
	 */
	Image getImage(int idx);

	/**
	 * total image size
	 * @return
	 */
	int getImageSourceSize();

	/**
	 * image source reload
	 */
	void reload();

	/**
	 * random image
	 * @return
	 */
	Image getImageByRandom();

	/**
	 * image list
	 * @return
	 */
	List<Image> getImageList();

	/**
	 * json expression of whole image by idx : name
	 * @return
	 */
	String getImageNameJSON();

	/**
	 * delete image
	 * @param idx
	 */
	void delete(int idx);

	/**
	 * map of whole image by idx, name
	 * @return
	 */
	Map<Integer, String> getImageNameMap();
	
	byte[] getBytes(int idx, ImageType imageType);

	int getRandomImageNo();
	
}
