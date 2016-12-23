package jk.kamoru.flayon.crazy;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import jk.kamoru.flayon.crazy.image.ImageException;
import jk.kamoru.flayon.crazy.image.ImageNotFoundException;
import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VideoException;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;

@ControllerAdvice
public class CrazyExceptionHandling {

	@ExceptionHandler(value = CrazyException.class)
	public ModelAndView crazyException(CrazyException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/crazyError");
	}
	
	@ExceptionHandler(value = VideoException.class)
	public ModelAndView videoException(VideoException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/videoError");
	}
	
	@ExceptionHandler(value = VideoNotFoundException.class)
	public ModelAndView videoNotFoundException(VideoNotFoundException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/videoError");
	}
	
	@ExceptionHandler(value = StudioNotFoundException.class)
	public ModelAndView studioNotFoundException(StudioNotFoundException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/videoError");
	}
	
	@ExceptionHandler(value = ActressNotFoundException.class)
	public ModelAndView actressNotFoundException(ActressNotFoundException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/videoError");
	}
	
	@ExceptionHandler(value = ImageException.class)
	public ModelAndView imageException(ImageException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/imageError");
	}
	
	@ExceptionHandler(value = ImageNotFoundException.class)
	public ModelAndView imageNotFoundException(ImageNotFoundException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, response, "error/imageError");
	}

	private ModelAndView modelAndView(CrazyException exception, HttpServletResponse response, String viewName) {
		ModelAndView modelAndView = new ModelAndView(viewName);
		modelAndView.addObject("timestamp", new java.util.Date());
		
		if (exception instanceof CrazyException)
			modelAndView.addObject("exception", exception);
		else if (exception instanceof VideoException)
			modelAndView.addObject("exception", (VideoException)exception);
		else if (exception instanceof ImageException)
			modelAndView.addObject("exception", (ImageException)exception);
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exception.getMessage());
		if (exception.getCause() != null)
			response.setHeader("error.cause", exception.getCause().toString());		
		
		return modelAndView;
	}
}
