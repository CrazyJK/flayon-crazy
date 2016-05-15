package jk.kamoru.crazy.image.service;

import java.util.List;

import jk.kamoru.crazy.image.domain.Image;

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
	 * json expression of total image by idx : name
	 * @return
	 */
	String getImageNameJSON();

	/**
	 * delete image
	 * @param idx
	 */
	void delete(int idx);

	/**
	 * random image no
	 * @return
	 */
	int getRandomImageNo();
}
