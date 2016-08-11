package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ModelAttribute;

import jk.kamoru.flayon.crazy.image.service.ImageService;

public abstract class CrazyController extends CrazyProperties {

	@Autowired protected ImageService imageService;

	@ModelAttribute("bgImageCount")
	public Integer bgImageCount() {
		return imageService.getImageSourceSize();
	}
	
}
