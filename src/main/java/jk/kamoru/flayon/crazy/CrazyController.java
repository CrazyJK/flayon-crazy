package jk.kamoru.flayon.crazy;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.ModelAttribute;

import jk.kamoru.flayon.crazy.image.service.ImageService;

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

}
