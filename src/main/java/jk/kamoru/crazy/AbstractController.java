package jk.kamoru.crazy;

import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ModelAttribute;

import jk.kamoru.crazy.image.service.ImageService;

public abstract class AbstractController {

	@Autowired private ImageService imageService;

	@ModelAttribute("auth")
	public Authentication getAuth() {
		return SecurityContextHolder.getContext().getAuthentication();
	}

	@ModelAttribute("bgImageCount")
	public Integer bgImageCount() {
		return imageService.getImageSourceSize();
	}
	
	@ModelAttribute("locale")
	public Locale locale(Locale locale) {
		return locale;
	}
}
