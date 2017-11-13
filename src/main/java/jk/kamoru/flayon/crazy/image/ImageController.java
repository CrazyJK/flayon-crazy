package jk.kamoru.flayon.crazy.image;

import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.crazy.CrazyController;
import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/image")
public class ImageController extends CrazyController {

	private long today = new Date().getTime();

	@Autowired private VideoService videoService;

	@Scheduled(cron="0 0 0 * * *")
	public void updateDate() {
		today = new Date().getTime();
	}
	
	@RequestMapping()              public String slide()      { return "image/slide"; }
	@RequestMapping("/slides")     public String slidesjs()   { return "image/slidesjs"; }
	@RequestMapping("/canvas")     public String canvas()     { return "image/canvas"; }
	@RequestMapping("/aperture")   public String aperture()   { return "image/aperture"; }
	@RequestMapping("/lightbox")   public String lightbox()   { return "image/lightbox"; }
	@RequestMapping("/thumbnails") public String thumbnails() { return "image/thumbnails"; }
	@RequestMapping("/tablet")     public String tablet()     { return "image/tablet"; }

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

	@RequestMapping("/{idx}/{imageType}")
	@Deprecated
	public HttpEntity<byte[]> getImageOnType(@PathVariable int idx, @PathVariable Image.Type imageType, HttpServletResponse response) {
		log.warn("this method is deprecated");
		return getImageEntity(imageService.getBytes(idx, imageType), MediaType.IMAGE_JPEG, response);
	}

	@RequestMapping("/{idx}")
	public HttpEntity<byte[]> getImage(@PathVariable int idx, HttpServletResponse response) {
		return getImageEntity(imageService.getBytes(idx, Image.Type.MASTER), MediaType.IMAGE_JPEG, response);
	}

	@RequestMapping(value = "/{idx}", method = RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable int idx) {
		log.info("Delete image {}", idx);
		imageService.delete(idx);
	}

	@RequestMapping("/random")
	public HttpEntity<byte[]> getImageRandom() throws IOException {
		byte[] imageBytes = imageService.getBytes(imageService.getRandomImageNo(), Image.Type.MASTER);
		HttpHeaders headers = new HttpHeaders();
		headers.setCacheControl("max-age=1");
		headers.setContentLength(imageBytes.length);
		headers.setContentType(MediaType.IMAGE_JPEG);
		return new HttpEntity<byte[]>(imageBytes, headers);
	}

	private HttpEntity<byte[]> getImageEntity(byte[] imageBytes, MediaType type, HttpServletResponse response) {
		/*
		for (String name : response.getHeaderNames())
			for (String value : response.getHeaders(name))
				log.info("HEADER {}: {}", name, value);
		 */
		response.setHeader("Cache-Control",    "public, max-age=" + IMAGE.WEBCACHETIME_SEC);
		response.setHeader("Pragma",           "public");
		response.setDateHeader("Expires",       today + IMAGE.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", today - IMAGE.WEBCACHETIME_MILI);

		HttpHeaders headers = new HttpHeaders();
		headers.setContentLength(imageBytes.length);
		headers.setContentType(type);
//		headers.setCacheControl("public, max-age=" + VIDEO.WEBCACHETIME_SEC);
//		headers.setDate(today + VIDEO.WEBCACHETIME_MILI);
//		headers.setExpires(today + VIDEO.WEBCACHETIME_MILI);
//		headers.setLastModified(today + VIDEO.WEBCACHETIME_MILI);

		return new HttpEntity<byte[]>(imageBytes, headers);
	}

}
