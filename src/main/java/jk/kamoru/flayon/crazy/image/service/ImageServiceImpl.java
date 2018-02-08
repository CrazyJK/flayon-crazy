package jk.kamoru.flayon.crazy.image.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.source.ImageSource;
import jk.kamoru.flayon.util.RandomUtils;

/**
 * Implementation of {@link ImageService}
 * @author kamoru
 *
 */
@Service
public class ImageServiceImpl implements ImageService {

	@Autowired ImageSource imageSource;
	
	@Override
	public Image getImage(int idx) {
		return imageSource.get(idx);
	}

	@Override
	public Image getImage(int pathIndex, int imageIndex) {
		return imageSource.get(pathIndex, imageIndex);
	}

	@Override
	public Image getImageByRandom() {
		return imageSource.get(RandomUtils.getInt(imageSource.size()));
	}

	@Override
	public int getImageSourceSize() {
		return imageSource.size();
	}

	@Override
	public List<Image> getImageList() {
		return imageSource.getList();
	}

	@Override
	public List<String> getPathList() {
		return imageSource.getPathList();
	}

	@Override
	public List<Map<String, Object>> getImageInfoByPath() {
		List<Map<String, Object>> infos = new ArrayList<>();
		int index = -1;
		Map<String, Object> pathInfo0 = new HashMap<>();
		pathInfo0.put("index", index++);
		pathInfo0.put("path", "ALL");
		pathInfo0.put("size", imageSource.getList().size());
		infos.add(pathInfo0);
		for (Map.Entry<String, List<Image>> entry : imageSource.getImageMapByPath().entrySet()) {
			Map<String, Object> pathInfo = new HashMap<>();
			pathInfo.put("index", index++);
			pathInfo.put("path", entry.getKey());
			pathInfo.put("size", entry.getValue().size());
			infos.add(pathInfo);
		}
		return infos;
	}

	@Override
	public Map<Integer, String> getImageNameMap() {
		Map<Integer, String> map = new HashMap<>();
		int index = 0;
		for (Image image : imageSource.getList()) {
			map.put(index++, image.getInfo().getName());
		}
		return map;
	}

	@Override
	public void delete(int idx) {
		imageSource.delete(idx);
	}

	@Override
	public void deleteByPath(int pathIndex, int imageIndex) {
		imageSource.delete(pathIndex, imageIndex);
	}

}
