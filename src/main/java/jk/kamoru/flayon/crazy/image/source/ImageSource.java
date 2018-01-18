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

	List<Image> getList();

	Image get(int idx);
	
	Image get(int pathIndex, int imageIndex);

	int size();

	void delete(int idx);

	void delete(int pathIndex, int imageIndex);
	
	List<String> getPathList();

	Map<String, List<Image>> getImageMapByPath();

}
