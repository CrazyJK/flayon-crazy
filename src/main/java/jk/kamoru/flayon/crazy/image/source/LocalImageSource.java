package jk.kamoru.flayon.crazy.image.source;

import java.io.File;
import java.util.ArrayList;
//import java.util.Collections;
//import java.util.Comparator;
import java.util.List;

import javax.annotation.PostConstruct;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.io.FileUtils;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Repository;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.error.ImageNotFoundException;
//import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.image.IMAGE;
import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.video.service.queue.NotiQueue;

/**
 * Implementation of {@link ImageSource}
 * @author kamoru
 *
 */
@Repository
@Slf4j
public class LocalImageSource extends CrazyProperties implements ImageSource {

	private List<Image> imageList;
	
	private boolean loading = false;

	private synchronized void load() {
		loading = true;
		
		if (imageList == null)
			imageList = new ArrayList<>();
		imageList.clear();

		for (String path : this.IMAGE_PATHS) {
			File dir = new File(path);
			if (dir.isDirectory()) {
				log.info("Image scanning ... {}", dir);
				for (File file : FileUtils.listFiles(dir, IMAGE.SUFFIX_IMAGE_ARRAY, true))
					imageList.add(new Image(file));
			}
		}
		log.info("{} images found", imageList.size());
		NotiQueue.pushNoti("Image loading " + imageList.size());
		loading = false;
	}

	private List<Image> imageSource() {
		if (imageList == null)
			load();
		else 
			if (loading)
				do {
					try {
						Thread.sleep(500);
					} catch (InterruptedException e) {
						log.error("sleep error", e);
						break;
					}
				} while (loading);
		return imageList;
	}

	@Override
	public Image getImage(int idx) {
		try {
			return imageSource().get(idx);
		}
		catch(IndexOutOfBoundsException  e) {
			throw new ImageNotFoundException(idx, e);
		}
	}

	@Override
	public List<Image> getImageList() {
		return imageSource();
	}

	@Override
	public int getImageSourceSize() {
		return imageSource().size();
	}

	@Override
	public void delete(int idx) {
		FileUtils.deleteQuietly(imageSource().get(idx).getFile());
		imageSource().remove(idx);
	}

	@Override
	@PostConstruct
	@Scheduled(cron = "0 */17 * * * *")
	@CacheEvict(value = "flayon-image-cache", allEntries=true)
	public void reload() {
		load();
	}

}
