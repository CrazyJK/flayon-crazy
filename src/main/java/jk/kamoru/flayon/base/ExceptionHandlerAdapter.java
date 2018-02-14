package jk.kamoru.flayon.base;

import java.util.Date;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import jk.kamoru.flayon.crazy.CrazyNotFoundException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public abstract class ExceptionHandlerAdapter {

	private static final String LOG_FORMAT = "%s: %s. view [%s]";
	
	protected ModelAndView modelAndView(Exception exception, WebRequest request, HttpServletResponse response, String viewName) {
		final String exceptionClass = exception.getClass().getName();
		final String exceptionMessage = exception.getMessage();
		final Throwable exceptionCause = exception.getCause();
		final Date today = new Date();
		
		ModelAndView modelAndView = new ModelAndView(viewName);
		modelAndView.addObject("exception", exception);
		modelAndView.addObject("timestamp", today);
		
		response.setHeader("error", "true");
		response.setHeader("error.message", exceptionMessage);
		if (exceptionCause != null)
			response.setHeader("error.cause", exceptionCause.getMessage());		
		
		String logMessage = String.format(LOG_FORMAT, exceptionClass, exceptionMessage, viewName);
		if (exception instanceof CrazyNotFoundException)
			log.error(logMessage);
		else
			log.error(logMessage, exception);

		if (request.getHeader("accept").contains("json"))
			return null;
		else
			return modelAndView;
	}

}
