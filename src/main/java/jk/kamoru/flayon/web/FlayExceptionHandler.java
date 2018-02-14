package jk.kamoru.flayon.web;

import javax.servlet.http.HttpServletResponse;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import jk.kamoru.flayon.base.ExceptionHandlerAdapter;

@ControllerAdvice
public class FlayExceptionHandler extends ExceptionHandlerAdapter {

	@ExceptionHandler(value = FlayException.class)
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public ModelAndView flayException(FlayException exception, WebRequest request, HttpServletResponse response) {
		return modelAndView(exception, request, response, "error/base.error");
	}

}