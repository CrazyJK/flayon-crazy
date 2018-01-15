package jk.kamoru.flayon.crazy.image.source;

import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.crazy.image.domain.Image;

/**
 * Image source
 * @author kamoru
 *
 */
public interface ImageSource {

	/**
	 * image
	 * @param idx
	 * @return
	 */
	Image getImage(int idx);
	
	/**
	 * total image list
	 * @return
	 */
	List<Image> getImageList();

	/**
	 * total image size
	 * @return
	 */
	int getImageSourceSize();

	/**
	 * delete image
	 * @param idx
	 */
	void delete(int idx);

	void delete(int pathIndex, int imageIndex);

	Image getImage(int pathIndex, int imageIndex);
	
	List<String> getPathList();

	Map<String, List<Image>> getImageMapByPath();

}
