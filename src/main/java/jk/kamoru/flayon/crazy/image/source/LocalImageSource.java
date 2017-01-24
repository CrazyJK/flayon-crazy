package jk.kamoru.flayon.crazy.image.source;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.annotation.PostConstruct;

import lombok.extern.slf4j.Slf4j;

import org.apache.commons.io.FileUtils;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Repository;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.image.IMAGE;
import jk.kamoru.flayon.crazy.image.ImageNotFoundException;
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
		
		int idx = 0;

		if (imageList == null)
			imageList = new ArrayList<Image>();
		imageList.clear();

		for (String path : this.IMAGE_PATHS) {
			File dir = new File(path);
			if (dir.isDirectory()) {
				log.info("Image scanning ... {}", dir);
				for (File file : FileUtils.listFiles(dir, IMAGE.imageSuffix, true))
					imageList.add(new Image(file, idx++));
			}
		}
		log.info("{} images found", imageList.size());
		
		Collections.sort(imageList, new Comparator<Image>() {
			@Override
			public int compare(Image o1, Image o2) {
				return Utils.compareTo(o1.getLastModified(), o2.getLastModified());
			}
		});
		loading = false;
		
		NotiQueue.pushNoti("Image loading " + imageList.size());
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
		imageSource().get(idx).delete();
		imageSource().remove(idx);
	}

	@Override
	@PostConstruct
	@Scheduled(cron = "0 */17 * * * *")
	public void reload() {
		load();
	}

}
