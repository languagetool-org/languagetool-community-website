package org.languagetool;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToOne;

@Entity
public class RegistrationTicket {
  
  private Long id;
  private String ticketCode;
  private Date generationDate;
  private User user;
  
  public RegistrationTicket() {
  }
  
  public RegistrationTicket(User user) {
    // FIXME: take from config file:
    String secret = "hfsjkfdsfewjk23s";
    String key = Math.random() + "/" + secret;
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      ticketCode = binaryToHex(md.digest(key.getBytes()));
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
    this.generationDate = new Date();
    this.user = user;
  }
  
  private String binaryToHex(byte[] array) {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < array.length; ++i) {
        sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
    }
    return sb.toString();
  }
  
  @Id
  @GeneratedValue
  public Long getId() {
      return id;
  }
  public void setId(Long id) {
      this.id = id;
  }

  public String getTicketCode() {
    return ticketCode;
  }
  public void setTicketCode(String ticketCode) {
    this.ticketCode = ticketCode;
  }

  public Date getGenerationDate() {
    return generationDate;
  }
  public void setGenerationDate(Date generationDate) {
    this.generationDate = generationDate;
  }

  @OneToOne
  public User getUser() {
    return user;
  }
  public void setUser(User user) {
    this.user = user;
  }

}