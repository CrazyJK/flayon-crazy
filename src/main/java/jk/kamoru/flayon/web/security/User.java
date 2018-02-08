package jk.kamoru.flayon.web.security;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.hibernate.validator.constraints.NotEmpty;

import jk.kamoru.flayon.FLAYON;
import lombok.Data;

@Entity
@Data
public class User implements Serializable {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;
	
	@Column(name = "name", nullable = false)
	@Size(min=2, max=30)
	private String name;
		
	@NotEmpty
	private String password;
	
	@NotNull
	private String role;
	
	enum Role {
		USER, ADMIN;
	}

	public String toNameCard() {
		return name + "(" + id + ")";
	}

	@Override
	public String toString() {
		return String.format("User [id=%s, name=%s, password=[PROTECTED], role=%s]", id, name, role);
	}
	
}
