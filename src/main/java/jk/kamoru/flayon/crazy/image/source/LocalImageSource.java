package jk.kamoru.flayon.crazy.image.source;

import java.io.File;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Repository;

import jk.kamoru.flayon.base.watch.AsyncExecutorService;
import jk.kamoru.flayon.base.watch.DirectoryWatcher;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.error.ImageNotFoundException;
import jk.kamoru.flayon.crazy.image.IMAGE;
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

	@PostConstruct
	private synchronized void load() {
		for (String path : config.getImagePaths()) {
			File dir = new File(path);
			if (dir.isDirectory()) {
				log.info("Image scanning ... {}", dir);
				for (File file : FileUtils.listFiles(dir, IMAGE.SUFFIX_IMAGE_ARRAY, true))
					imageList.add(new Image(file));
			}
		}
		log.info("{} images found", imageList.size());
		NotiQueue.pushNoti("Image loading " + imageList.size());
	}

	@Override
	public Image getImage(int idx) {
		try {
			return imageList.get(idx);
		}
		catch(IndexOutOfBoundsException e) {
			throw new ImageNotFoundException(idx, e);
		}
	}

	@Override
	public List<Image> getImageList() {
		return imageList;
	}

	@Override
	public int getImageSourceSize() {
		return imageList.size();
	}

	@Override
	@CacheEvict(value = "flayon-image-cache", allEntries=true)
	public void delete(int idx) {
		Image image = imageList.get(idx);
		imageList.remove(image);
		FileUtils.deleteQuietly(image.getFile());
	}

	@Override
	protected Runnable getTask() {
		return new DirectoryWatcher("Image", config.getImagePaths()) {

			@Override
			public void deleteEvent(Path path) {
				boolean remove = imageList.remove(new Image(path.toFile()));
				log.info("remove image {}. current size {}", remove, imageList.size());
			}

			@Override
			public void createEvent(Path path) {
				boolean add = imageList.add(new Image(path.toFile()));
				log.info("add image {}. current size {}", add, imageList.size());
			}};
	}

}
