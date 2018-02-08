package jk.kamoru.flayon.crazy.image;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Date;

import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.base.util.JsonUtils;
import jk.kamoru.flayon.crazy.CrazyController;
import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.domain.Image.Type;
import jk.kamoru.flayon.crazy.image.service.ImageService;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping("/image")
@Slf4j
public class ImageController extends CrazyController {

	@Autowired ImageService imageService;

	private long today = new Date().getTime();

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
	@RequestMapping("/series")     public String series()     { return "image/series"; }

	@RequestMapping("/{idx}")
	public HttpEntity<byte[]> getImage(@PathVariable int idx, HttpServletResponse response) {
		return getImageEntity(imageService.getImage(idx), response);
	}

	@RequestMapping("/{idx}/{imageType}")
	public HttpEntity<byte[]> getImageOnType(@PathVariable int idx, @PathVariable Image.Type imageType, HttpServletResponse response) {
		return getImageEntity(imageService.getImage(idx), imageType, response);
	}

	@RequestMapping("/byPath/{pathIndex}/{imageIndex}")
	public HttpEntity<byte[]> getImageByPath(@PathVariable int pathIndex, @PathVariable int imageIndex, HttpServletResponse response) {
		return getImageEntity(imageService.getImage(pathIndex, imageIndex), response);
	}

	@RequestMapping("/byPath/{pathIndex}/{imageIndex}/{imageType}")
	public HttpEntity<byte[]> getImageByPathOnType(@PathVariable int pathIndex, @PathVariable int imageIndex, @PathVariable Image.Type imageType, HttpServletResponse response) {
		return getImageEntity(imageService.getImage(pathIndex, imageIndex), imageType, response);
	}

	@RequestMapping("/random")
	public HttpEntity<byte[]> getImageRandom() throws IOException {
		Image image = imageService.getImageByRandom();
		return ResponseEntity
				.ok()
				.cacheControl(CacheControl.noCache())
				.contentLength(image.getFile().length())
				.contentType(getMediaType(image.getFile()))
				.body(image.getByteArray());
	}

	@RequestMapping(value = "/{idx}", method = RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable int idx) {
		log.info("Delete image {}", idx);
		imageService.delete(idx);
	}

	@RequestMapping(value = "/byPath/{pathIndex}/{imageIndex}", method = RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteByPath(@PathVariable int pathIndex, @PathVariable int imageIndex) {
		log.info("DeleteByPath image {} / {}", pathIndex, imageIndex);
		imageService.deleteByPath(pathIndex, imageIndex);
	}

	private HttpEntity<byte[]> getImageEntity(Image image, HttpServletResponse response) {
		return getImageEntity(image, Type.MASTER, response);
	}
	
	private HttpEntity<byte[]> getImageEntity(Image image, Image.Type type, HttpServletResponse response) {
		/*
		for (String name : response.getHeaderNames())
			for (String value : response.getHeaders(name))
				log.info("HEADER {}: {}", name, value);
		 */
		response.setHeader("Cache-Control",    "public, max-age=" + IMAGE.WEBCACHETIME_SEC);
		response.setHeader("Pragma",           "public");
		response.setDateHeader("Expires",       today + IMAGE.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", today - IMAGE.WEBCACHETIME_MILI);
		response.setHeader("info", JsonUtils.toJsonString(image.getInfo()));

		byte[] byteArray = image.getByteArray(type);
		
		HttpHeaders headers = new HttpHeaders();
		headers.setContentLength(byteArray.length);
 		headers.setContentType(getMediaType(image.getFile()));

		return new HttpEntity<byte[]>(byteArray, headers);
	}

	private MediaType getMediaType(File file) {
		try {
			String contentType = Files.probeContentType(file.toPath());
			MediaType mediaType = MediaType.valueOf(contentType);
			return mediaType;
		} catch (IOException e) {
			return MediaType.IMAGE_JPEG;
		}
	}

}
