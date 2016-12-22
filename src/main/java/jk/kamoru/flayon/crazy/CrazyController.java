package jk.kamoru.flayon.crazy;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jk.kamoru.flayon.crazy.image.ImageException;
import jk.kamoru.flayon.crazy.image.ImageNotFoundException;
import jk.kamoru.flayon.crazy.image.service.ImageService;
import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VideoException;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Video;

public abstract class CrazyController extends CrazyProperties {

	@Autowired protected ImageService imageService;
	@Autowired private Environment environment;

	@ModelAttribute("bgImageCount")
	public Integer bgImageCount() {
		return imageService.getImageSourceSize();
	}

	@ModelAttribute("profiles")
	public String activeProfiles() {
		return StringUtils.join(environment.getActiveProfiles(), " ");
	}

	@RequestMapping("/throwError")
	public void throwError(@RequestParam(value="k", required=false, defaultValue="") String kind) {
		if (kind.equals("crazy")) 
			throw new CrazyException("CRAZY MESSAGE BLAR BLAR ");
		if (kind.equals("video")) 
			throw new VideoException("VIDEO MESSAGE");
		if (kind.equals("videonotfound"))
			throw new VideoNotFoundException("OPUS");
		if (kind.equals("studionotfound"))
			throw new StudioNotFoundException("STUDIO NAME");
		if (kind.equals("actressnotfound"))
			throw new ActressNotFoundException("ACTRESS NAME");
		if (kind.equals("image"))
			throw new ImageException("IMAGE ERROR");
		if (kind.equals("imagenotfound"))
			throw new ImageNotFoundException(-1);
		
		throw new CrazyException("CRAZY ERROR");
	}
	
}
