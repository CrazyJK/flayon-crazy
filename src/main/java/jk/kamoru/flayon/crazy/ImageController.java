package jk.kamoru.flayon.crazy;

import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import jk.kamoru.flayon.crazy.image.domain.ImageType;
import jk.kamoru.flayon.crazy.image.service.ImageService;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping("/image")
@Slf4j
public class ImageController extends AbstractController {

	private static final String Cookie_LAST_IMAGE_INDEX = "lastImageNo";

	private static final String Cookie_LAST_RANDOM_IMAGE_INDEX = "lastRandomImageNo";;

	@Autowired
	private ImageService imageService;

	@RequestMapping(method = RequestMethod.GET)
	public String viewSlide() {
		return "image/slide";
	}
	
	@RequestMapping("/data")
	@ResponseBody
	public Map<String, Object> getData(HttpServletResponse response, 
			@RequestParam(value = "n", required = false, defaultValue = "-1") int firstImageIndex,
			@RequestParam(value = "d", required = false, defaultValue = "-1") int deleteImageIndex,
			@CookieValue(value = Cookie_LAST_IMAGE_INDEX, defaultValue = "-1") int lastViewImageIndex) {
		Map<String, Object> data = new HashMap<>();
		int count = imageService.getImageSourceSize();
		
		if (firstImageIndex > -1)
			firstImageIndex = firstImageIndex > count ? count - 1 : firstImageIndex;
		else
			if (deleteImageIndex > -1)
				firstImageIndex = deleteImageIndex;
			else if (lastViewImageIndex > -1)
				firstImageIndex = lastViewImageIndex;
			else
				firstImageIndex = imageService.getRandomImageNo();

		response.addCookie(new Cookie(Cookie_LAST_IMAGE_INDEX, String.valueOf(firstImageIndex)));
		
		data.put("imageCount", count);
		data.put("selectedNumber", firstImageIndex);
		data.put("imageNameMap", imageService.getImageNameMap());
		return data;
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

	@RequestMapping(value = "/{idx}/thumbnail")
	public HttpEntity<byte[]> imageThumbnail(@PathVariable int idx) {
		return getImageEntity(imageService.getImage(idx).getByteArray(ImageType.THUMBNAIL), MediaType.IMAGE_GIF);
	}

	@RequestMapping(value = "/{idx}/WEB")
	public HttpEntity<byte[]> imageWEB(@PathVariable int idx) {
		return getImageEntity(imageService.getImage(idx).getByteArray(ImageType.WEB), MediaType.IMAGE_JPEG);
	}

	@RequestMapping(value = "/{idx}")
	public HttpEntity<byte[]> imageMaster(@PathVariable int idx, HttpServletResponse response) {
		response.addCookie(new Cookie(Cookie_LAST_IMAGE_INDEX, String.valueOf(idx)));
		return getImageEntity(imageService.getImage(idx).getByteArray(ImageType.MASTER), MediaType.IMAGE_JPEG);
	}

	@RequestMapping(value = "/random")
	public HttpEntity<byte[]> imageRandom(HttpServletResponse response) throws IOException {

		int randomNo = imageService.getRandomImageNo();
		byte[] imageBytes = imageService.getImage(randomNo).getByteArray(ImageType.MASTER);

		response.addCookie(new Cookie(Cookie_LAST_RANDOM_IMAGE_INDEX, String.valueOf(randomNo)));

		HttpHeaders headers = new HttpHeaders();
		headers.setCacheControl("max-age=1");
		headers.setContentLength(imageBytes.length);
		headers.setContentType(MediaType.IMAGE_JPEG);

		return new HttpEntity<byte[]>(imageBytes, headers);
	}

	@RequestMapping(value = "/{idx}", method = RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@PathVariable int idx) {
		log.info("Delete image {}", idx);
		imageService.delete(idx);
	}

	private HttpEntity<byte[]> getImageEntity(byte[] imageBytes, MediaType type) {
		long today = new Date().getTime();

		HttpHeaders headers = new HttpHeaders();
		headers.setCacheControl("max-age=" + VIDEO.WEBCACHETIME_SEC);
		headers.setContentLength(imageBytes.length);
		headers.setContentType(type);
		headers.setDate(today + VIDEO.WEBCACHETIME_MILI);
		headers.setExpires(today + VIDEO.WEBCACHETIME_MILI);
		headers.setLastModified(today - VIDEO.WEBCACHETIME_MILI);

		return new HttpEntity<byte[]>(imageBytes, headers);
	}

}
