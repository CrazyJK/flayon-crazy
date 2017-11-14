package jk.kamoru.flayon.crazy;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jk.kamoru.flayon.crazy.error.ActressNotFoundException;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.error.ImageException;
import jk.kamoru.flayon.crazy.error.ImageNotFoundException;
import jk.kamoru.flayon.crazy.error.StudioNotFoundException;
import jk.kamoru.flayon.crazy.error.VideoException;
import jk.kamoru.flayon.crazy.error.VideoNotFoundException;
import jk.kamoru.flayon.crazy.error.CrazyException.KIND;
import jk.kamoru.flayon.crazy.image.service.ImageService;
import jk.kamoru.flayon.crazy.video.service.VideoService;

public abstract class CrazyController {

	@Autowired protected VideoService videoService;
	@Autowired protected ImageService imageService;
	@Autowired Environment environment;

	@ModelAttribute("bgImageCount")
	public Integer bgImageCount() {
		return imageService.getImageSourceSize();
	}

	@ModelAttribute("PATH")
	public String contextPath(HttpServletRequest request) {
		return request.getContextPath();
	}
	
	@ModelAttribute("profiles")
	public String activeProfiles() {
		return StringUtils.join(environment.getActiveProfiles(), " ");
	}

	@RequestMapping("/throwError")
	public void throwError(@RequestParam(value="k", required=false, defaultValue="Crazy") KIND kind) {
		switch(kind) {
		case Crazy:
			throw new CrazyException("CRAZY MESSAGE BLAR BLAR ", new RuntimeException("it could be cause"));
		case Video:
			throw new VideoException(videoService.getVideoList().get(1), "file is invalid", new RuntimeException("file is not exist"));
		case VideoNotFound:
			throw new VideoNotFoundException("OPUS");
		case StudioNotFound:
			throw new StudioNotFoundException("STUDIO NAME");
		case ActressNotFound:
			throw new ActressNotFoundException("ACTRESS NAME");
		case Image:
			throw new ImageException(imageService.getImage(1), "image file error", new RuntimeException("file is not exist"));
		case ImageNotFound:
			throw new ImageNotFoundException(-1);
		}
	}
	
}
