package jk.kamoru.flayon.crazy.image.service;

import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.domain.Image.Type;

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

	Image getImage(int pathIndex, int imageIndex);

	/**
	 * total image size
	 * @return
	 */
	int getImageSourceSize();

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

	void deleteByPath(int pathIndex, int imageIndex);

	/**
	 * map of whole image by idx, name
	 * @return
	 */
	Map<Integer, String> getImageNameMap();
	
	byte[] getBytes(int idx, Type imageType);

	int getRandomImageNo();

	List<String> getPathList();

	List<Map<String, Object>> getImageInfoByPath();

	
}
