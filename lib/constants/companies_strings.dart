import 'dart:developer';

import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/main.dart';

class Company {
  static const String ROOFLINE = "Roofline";
  static const String RADIANT = "Radiant";
  static const String MAMZ = "Mamz";

  static List<String> getRoleBasedCompanies() {
    if (loginStorage.getUserRole() == UserRole.CEO) {
      return [ROOFLINE, RADIANT, MAMZ];
    } else {
      log("loginStorage.getUserCompany()! = ${loginStorage.getUserCompany()??""}");
      return [loginStorage.getUserCompany()??""];
    }
  }

  static getCompanyLogo(String company) {
    log("company in getCompanyLogo $company");
    if (company == RADIANT) {
      return "images/radiant.png";
    } else if (company == ROOFLINE) {
      return "images/roofline.jpg";
    } else if (company == MAMZ) {
      return "images/mamz.png";
    }
  }
}
