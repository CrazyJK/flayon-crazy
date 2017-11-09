package jk.kamoru.flayon.base;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@ControllerAdvice
public class BaseExceptionHandler {

	@ExceptionHandler(value = Exception.class)
	public ModelAndView exception(Exception exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/generalError");
	}

	@ExceptionHandler(value = BaseException.class)
	public ModelAndView flayonException(BaseException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/baseError");
	}

	private ModelAndView modelAndView(Exception exception, WebRequest request, HttpServletResponse response, String viewName) {
		ModelAndView modelAndView = new ModelAndView(viewName);
		modelAndView.addObject("timestamp", new java.util.Date());
		modelAndView.addObject("exception", exception);
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exception.getMessage());
		if (exception.getCause() != null)
			response.setHeader("error.cause", exception.getCause().toString());		
		
		log.error("Error : {} view={}", exception.getMessage(), viewName);
		if (request.getHeader("accept").contains("json"))
			return null;
		else
			return modelAndView;
	}

}