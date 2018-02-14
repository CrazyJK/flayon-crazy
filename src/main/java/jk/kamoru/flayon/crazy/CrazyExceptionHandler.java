package jk.kamoru.flayon.crazy;

import javax.servlet.http.HttpServletResponse;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import jk.kamoru.flayon.base.ExceptionHandlerAdapter;
import jk.kamoru.flayon.crazy.image.ImageException;
import jk.kamoru.flayon.crazy.video.VideoException;

@ControllerAdvice
public class CrazyExceptionHandler extends ExceptionHandlerAdapter {

	@ExceptionHandler(value = {CrazyException.class, VideoException.class, ImageException.class})
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public ModelAndView crazyException(CrazyException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/crazy.error");
	}
	
	@ExceptionHandler(value = CrazyNotFoundException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	public ModelAndView videoNotFoundException(CrazyException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/crazy.notfound");
	}
	
}
