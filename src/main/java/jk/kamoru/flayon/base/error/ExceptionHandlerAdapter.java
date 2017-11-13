package jk.kamoru.flayon.base.error;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public abstract class ExceptionHandlerAdapter {

	protected ModelAndView modelAndView(Exception exception, WebRequest request, HttpServletResponse response, String viewName) {
		ModelAndView modelAndView = new ModelAndView(viewName);
		modelAndView.addObject("timestamp", new java.util.Date());
		modelAndView.addObject("exception", exception);
		modelAndView.addObject("status", response.getStatus());
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exception.getMessage());
		if (exception.getCause() != null)
			response.setHeader("error.cause", exception.getCause().toString());		
		
		log.error("Error : {} view={}", exception.getClass().getName(), viewName);
		if (request.getHeader("accept").contains("json"))
			return null;
		else
			return modelAndView;
	}

}
