package jk.kamoru.flayon;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

@ControllerAdvice
public class FlayOnExceptionHandling {

	@ExceptionHandler(value = FlayOnException.class)
	public ModelAndView flayonException(FlayOnException exception, WebRequest request, HttpServletResponse response) {

		ModelAndView modelAndView = new ModelAndView("error/flayonError");
		modelAndView.addObject("exception", exception);
		modelAndView.addObject("timestamp", new java.util.Date());
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exception.getMessage());
		if (exception.getCause() != null)
			response.setHeader("error.cause", exception.getCause().toString());		
		
		return modelAndView;
	}

	@ExceptionHandler(value = Exception.class)
	public ModelAndView exception(Exception exception, WebRequest request, HttpServletResponse response) {

		ModelAndView modelAndView = new ModelAndView("error/generalError");
		modelAndView.addObject("exception", exception);
		modelAndView.addObject("timestamp", new java.util.Date());
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exception.getMessage());
		if (exception.getCause() != null)
			response.setHeader("error.cause", exception.getCause().toString());		

		return modelAndView;
	}

}