package jk.kamoru.flayon.base.error;

import javax.servlet.http.HttpServletResponse;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

@ControllerAdvice
public class BaseExceptionHandler extends ExceptionHandlerAdapter {

	@ExceptionHandler(value = BaseException.class)
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public ModelAndView baseException(BaseException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/base.error");
	}

}