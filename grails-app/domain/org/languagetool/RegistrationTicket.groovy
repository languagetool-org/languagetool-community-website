package org.languagetool

import java.util.Date

class RegistrationTicket {
  
  String ticketCode;
  Date generationDate;
  User user
  
  public RegistrationTicket() {
  }
  
  public RegistrationTicket(User user, String secret) {
    String key = Math.random() + "/" + secret
    this.ticketCode = PasswordTools.hexMD5(key)
    this.generationDate = new Date()
    this.user = user
  }
  
}