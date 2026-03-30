class ApiUrls {
  static const String login = 'login';
  static const String logout = 'logout';
  static const String addUser = 'addUser';
  static const String taskCheckIn = 'checkIn';
  static const String taskCheckOut = 'checkOut';
  static const String updateProjectStatus = 'updatProjectStatus';

  static const String getUsersListByRoleName = 'getUsersByRoleName';
  static const String getLeaves = 'getLeaveByHierarchy';
  static const String addLeave = 'postLeave';
  static const String adminLeaveActions = 'updateLeaveStatus';

  // location
  static const String updateLocation = 'saveLocation';
  static const String getUserLocation = 'getUserLocation';

  // get all user list to show location
  static const String getUserSkipCeo = 'getAllUserExceptCeo';

  // task apis
  static const String assignTask = 'assignTask';
  static const String getAssignedTask = 'getAssignTasks';

  // project apis

  static const String assignProject = 'assignProject';
  static const String getAssignProjects = 'getAssignProjects';

  // notifications
  static const String getNotificaton = 'getNotification';

  /// visit report apis
  ///
  static const String addVisit = 'addVisit';
  static const String getVisitReport = '/getVisit';
  static const String getFilterReport = 'filterVisit';
  static const String addVisitReport = 'addVisitReport';

  // Attendance

  static const String markAttendance = 'markAttendance';
  static const String getTodayAttendance = 'getTodayAttendance';
  static const String singleUserAttendance = 'singleUserAttendance';

  // chats

  static const String getChatMembers = 'getChat';
  static const String uploadImage = 'addImage';
}
