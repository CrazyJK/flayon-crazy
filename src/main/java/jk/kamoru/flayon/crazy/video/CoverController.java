package jk.kamoru.flayon.crazy.video;

import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import jk.kamoru.flayon.crazy.video.service.CoverService;

@Controller
@RequestMapping("/cover")
public class CoverController {

	@Autowired CoverService coverService;

	@GetMapping("/video/{opus}")
	public HttpEntity<byte[]> videoCover(HttpServletResponse response, @PathVariable String opus) {
		return coverService.getVideoCover(response, opus);
	}

	@GetMapping("/video/{opus}/title")
	public HttpEntity<byte[]> videoCoverWithTitle(HttpServletResponse response, @PathVariable String opus) {
		return coverService.getVideoCoverWithTitle(response, opus);
	}

	@GetMapping("/video/random")
	public HttpEntity<byte[]> randomVideoCover(HttpServletResponse response) {
		return coverService.getVideoCoverRandom(response);
	}

	@GetMapping("/video/random/title")
	public HttpEntity<byte[]> randomVideoCoverWithTitle(HttpServletResponse response) {
		return coverService.getVideoCoverRandomWithTitle(response);
	}

	@GetMapping("/actress/{actressName}")
	public HttpEntity<byte[]> actressImage(HttpServletResponse response, @PathVariable String actressName) {
		return coverService.getActressCover(response, actressName);
	}
	
	@GetMapping("/actress/{actressName}/title")
	public HttpEntity<byte[]> actressImageWithTitle(HttpServletResponse response, @PathVariable String actressName) {
		return coverService.getActressCoverWithName(response, actressName);
	}

}
