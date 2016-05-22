package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ModelAttribute;

import jk.kamoru.flayon.crazy.image.service.ImageService;

public abstract class AbstractController {

	@Autowired private ImageService imageService;

	@ModelAttribute("bgImageCount")
	public Integer bgImageCount() {
		return imageService.getImageSourceSize();
	}
	
}
