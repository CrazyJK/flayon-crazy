package jk.kamoru.flayon;

import java.util.Iterator;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import lombok.extern.slf4j.Slf4j;

//@ControllerAdvice
@Slf4j
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

		Iterator<String> headerNames = request.getHeaderNames();
		while (headerNames.hasNext()) {
			String name = headerNames.next();
			log.info("header {}={}", name, request.getHeader(name));
		}
		log.error("Error : {}", exception.getMessage());
		if (request.getHeader("accept").contains("json"))
			return null;
		else
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

		log.error("Error : {}", exception.getMessage());

		return modelAndView;
	}

}