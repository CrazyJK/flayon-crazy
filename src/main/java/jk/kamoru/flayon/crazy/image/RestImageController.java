package jk.kamoru.flayon.crazy.image;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.service.ImageService;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/image")
public class RestImageController {

	@Autowired VideoService videoService;
	@Autowired ImageService imageService;

	@RequestMapping("/data")
	public Map<String, Object> getData() {
		Map<String, Object> data = new HashMap<>();
		data.put("imageCount",   imageService.getImageSourceSize());
		data.put("imageNameMap", imageService.getImageNameMap());
		int index = 0;
		Map<Integer, String> map = new HashMap<>();
		for (Video video : videoService.getVideoList()) {
			map.put(index++, video.getOpus());
		}
		data.put("coverCount",   index);
		data.put("coverNameMap", map);
		return data;
	}

	@RequestMapping("/info/{index}")
	public Map<String, Object> getImageInfo(@PathVariable int index) {
		Image image = imageService.getImage(index);
		Map<String, Object> info = new HashMap<>();
		info.put("name", image.getName());
		info.put("path", image.getFile().getParent());
		info.put("length", image.getFile().length());
		info.put("modified", image.getFile().lastModified());
		return info;
	}
	
	@RequestMapping("/count")
	public Integer getCount() {
		return imageService.getImageSourceSize();
	}

	@RequestMapping("/paths")
	public List<String> getImagePathList() {
		List<String> paths = new ArrayList<>();
		for (Image image : imageService.getImageList()) {
			String path = image.getFile().getParent();
			if (!paths.contains(path))
				paths.add(path);
		}
		return paths;
	}
}
