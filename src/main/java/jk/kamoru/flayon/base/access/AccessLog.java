package jk.kamoru.flayon.base.access;

import java.io.Serializable;
import java.util.Date;

import org.springframework.data.annotation.Id;

import jk.kamoru.flayon.FLAYON;
import jk.kamoru.flayon.base.security.User;
import lombok.Data;

@Data
public class AccessLog implements Serializable {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	@Id
    public String id;
    public Date accessDate;
    public String remoteAddr;
    public String method;
    public String requestURI;
    public String contentType;
    public long elapsedTime;
    public String handlerInfo;
    public String exceptionInfo;
    public String modelAndViewInfo;
    public User user;
    public int status;
    
	public AccessLog(Date accessDate, String remoteAddr, String method, String requestURI, String contentType, long elapsedTime,
			String handlerInfo, String exceptionInfo, String modelAndViewInfo, User user, int status) {
		super();
		this.accessDate = accessDate;
		this.remoteAddr = remoteAddr;
		this.method = method;
		this.requestURI = requestURI;
		this.contentType = contentType;
		this.elapsedTime = elapsedTime;
		this.handlerInfo = handlerInfo;
		this.exceptionInfo = exceptionInfo;
		this.modelAndViewInfo = modelAndViewInfo;
		this.user = user;
		this.status = status;
	}

	public String toLogString() {
		return String.format(
				"[%s - %s] %s %s %s %s %sms [%s] %s %s",
				remoteAddr, 
				user == null ? "" : user.toNameCard(), 
				method, 
				status,
				requestURI,
				contentType, 
				elapsedTime, 
				handlerInfo, 
				exceptionInfo, 
				modelAndViewInfo);
	}
 
}
