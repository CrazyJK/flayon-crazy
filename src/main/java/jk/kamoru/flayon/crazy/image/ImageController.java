package jk.kamoru.flayon.crazy.image;

import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.crazy.CrazyController;
import jk.kamoru.flayon.crazy.image.domain.ImageType;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping("/image")
@Slf4j
public class ImageController extends CrazyController {

	private static final long TODAY = new Date().getTime();

	@RequestMapping(method = RequestMethod.GET)
	public String viewSlide() {
		return "image/slide";
	}
	
	@RequestMapping(value = "/slides", method = RequestMethod.GET)
	public String viewSlidesjs() {
		return "image/slidesjs";
	}

	@RequestMapping(value = "/canvas", method = RequestMethod.GET)
	public String viewCanvas(@RequestParam(value = "d", required = false, defaultValue = "-1") int deleteImageIndex) {
		if (deleteImageIndex > -1) 
			imageService.delete(deleteImageIndex);
		return "image/canvas";
	}

	@RequestMapping(value = "/aperture", method = RequestMethod.GET)
	public String aperture() {
		return "image/aperture";
	}

	@RequestMapping(value = "/lightbox", method = RequestMethod.GET)
	public String lightbox() {
		return "image/lightbox";
	}

	@RequestMapping(value = "/thumbnails", method = RequestMethod.GET)
	public String thumbnails() {
		return "image/thumbnails";
	}

	@RequestMapping("/data")
	public Map<String, Object> getData() {
		Map<String, Object> data = new HashMap<>();
		data.put("imageCount", imageService.getImageSourceSize());
		data.put("imageNameMap", imageService.getImageNameMap());
		return data;
	}

	@RequestMapping(value = "/{idx}/thumbnail")
	public HttpEntity<byte[]> imageThumbnail(@PathVariable int idx, HttpServletResponse response) {
		return getImageEntity(imageService.getBytes(idx, ImageType.THUMBNAIL), MediaType.IMAGE_GIF, response);
	}

	@RequestMapping(value = "/{idx}/WEB")
	public HttpEntity<byte[]> imageWEB(@PathVariable int idx, HttpServletResponse response) {
		return getImageEntity(imageService.getBytes(idx, ImageType.WEB), MediaType.IMAGE_JPEG, response);
	}

	@RequestMapping(value = "/{idx}")
	public HttpEntity<byte[]> imageMaster(@PathVariable int idx, HttpServletResponse response) {
		return getImageEntity(imageService.getBytes(idx, ImageType.MASTER), MediaType.IMAGE_JPEG, response);
	}

	@RequestMapping(value = "/{idx}", method = RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable int idx) {
		log.info("Delete image {}", idx);
		imageService.delete(idx);
	}

	@RequestMapping(value = "/random")
	public HttpEntity<byte[]> imageRandom(HttpServletResponse response) throws IOException {

		byte[] imageBytes = imageService.getBytes(imageService.getRandomImageNo(), ImageType.MASTER);

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
		response.setHeader("Cache-Control",    "public, max-age=" + VIDEO.WEBCACHETIME_SEC);
		response.setHeader("Pragma",           "public");
		response.setDateHeader("Expires",       TODAY + VIDEO.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", TODAY - VIDEO.WEBCACHETIME_MILI);

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
