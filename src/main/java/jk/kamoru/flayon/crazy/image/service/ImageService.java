package jk.kamoru.flayon.crazy.image.service;

import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.crazy.image.domain.Image;

/**
 * Image Service
 * @author kamoru
 *
 */
public interface ImageService {

	Image getImage(int idx);

	Image getImage(int pathIndex, int imageIndex);

	Image getImageByRandom();

	int getImageSourceSize();

	List<Image> getImageList();
	
	List<String> getPathList();

	List<Map<String, Object>> getImageInfoByPath();

	Map<Integer, String> getImageNameMap();
	
	void delete(int idx);

	void deleteByPath(int pathIndex, int imageIndex);
	
}
