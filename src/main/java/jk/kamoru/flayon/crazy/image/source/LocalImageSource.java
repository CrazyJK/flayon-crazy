package jk.kamoru.flayon.crazy.image.source;

import java.io.File;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import jk.kamoru.flayon.base.AsyncExecutorService;
import jk.kamoru.flayon.base.watch.DirectoryWatcher;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.image.IMAGE;
import jk.kamoru.flayon.crazy.image.ImageNotFoundException;
import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;
import lombok.extern.slf4j.Slf4j;

/**
 * Implementation of {@link ImageSource}
 * @author kamoru
 *
 */
@Repository
@Slf4j
public class LocalImageSource extends AsyncExecutorService implements ImageSource {

	@Autowired CrazyConfig config;

	private List<Image> imageList = new ArrayList<>();
	private List<String> pathList = new ArrayList<>();
	private Map<String, List<Image>> imageMapByPath = new HashMap<>();

	@PostConstruct
	private synchronized void load() {
		for (String path : config.getImagePaths()) {
			File dir = new File(path);
			if (dir.isDirectory()) {
				log.info("Image scanning ... {}", dir);
				for (File file : FileUtils.listFiles(dir, IMAGE.SUFFIX_IMAGE_ARRAY, true)) {
					imageList.add(new Image(file));
				}
			}
		}
		loadAfter();
		log.info("{} images found", size());
		NotiQueue.push("Image loading " + size());
	}

	@Override
	public List<Image> getList() {
		return imageList;
	}

	@Override
	public Image get(int idx) {
		try {
			return imageList.get(idx);
		} catch(IndexOutOfBoundsException e) {
			throw new ImageNotFoundException(idx, e);
		}
	}

	@Override
	public Image get(int pathIndex, int imageIndex) {
		try {
			if (pathIndex < 0)
				return get(imageIndex);
			else
				return imageMapByPath.get(pathList.get(pathIndex)).get(imageIndex);
		} catch(Exception e) {
			throw new ImageNotFoundException(String.format("NotFound %s %s ", pathIndex, imageIndex), e);
		}
	}

	@Override
	public int size() {
		return imageList.size();
	}

	@Override
	public void delete(int idx) {
		delete(get(idx));
	}

	@Override
	public void delete(int pathIndex, int imageIndex) {
		delete(get(pathIndex, imageIndex));
	}

	@Override
	public List<String> getPathList() {
		return pathList;
	}
	
	@Override
	public Map<String, List<Image>> getImageMapByPath() {
		return imageMapByPath;
	}

	@Override
	protected Runnable getTask() {
		return new DirectoryWatcher("Image", config.getImagePaths()) {

			@Override
			public void deleteEvent(Path path) {
				boolean remove = imageList.remove(new Image(path.toFile()));
				loadAfter();
				log.info("remove image {}. current size {}", remove, imageList.size());
			}

			@Override
			public void createEvent(Path path) {
				boolean add = imageList.add(new Image(path.toFile()));
				loadAfter();
				log.info("add image {}. current size {}", add, imageList.size());
			}};
	}

	private void delete(Image image) {
		imageList.remove(image);
		FileUtils.deleteQuietly(image.getFile());
		loadAfter();
	}
	
	private void loadAfter() {
		imageMapByPath = new HashMap<>();
		for (Image image : imageList) {
			String imagePath = image.getFile().getParent();
			if (!imageMapByPath.containsKey(imagePath)) {
				imageMapByPath.put(imagePath, new ArrayList<Image>());
			}
			imageMapByPath.get(imagePath).add(image);
		}
		pathList = imageMapByPath.keySet().stream().collect(Collectors.toList());
	}
}
