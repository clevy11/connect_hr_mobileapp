class AppConstants {
  // App Information
  static const String appName = 'HR Management';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleHrManager = 'hr_manager';
  static const String roleManager = 'manager';
  static const String roleEmployee = 'employee';
  
  // Attendance Status
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusHalfDay = 'half_day';
  
  // Leave Types
  static const String leaveTypeSick = 'sick';
  static const String leaveTypeVacation = 'vacation';
  static const String leaveTypePersonal = 'personal';
  static const String leaveTypeMaternity = 'maternity';
  static const String leaveTypePaternity = 'paternity';
  static const String leaveTypeBereavement = 'bereavement';
  static const String leaveTypeUnpaid = 'unpaid';
  
  // Leave Status
  static const String leaveStatusPending = 'pending';
  static const String leaveStatusApproved = 'approved';
  static const String leaveStatusRejected = 'rejected';
  static const String leaveStatusCancelled = 'cancelled';
  
  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefUsername = 'username';
  static const String prefUserRole = 'role';
  static const String prefEmployeeId = 'employee_id';
  static const String prefThemeMode = 'theme_mode';
  static const String prefIsFirstLaunch = 'is_first_launch';
  
  // Animation Durations
  static const int animationDurationFast = 200;
  static const int animationDurationMedium = 350;
  static const int animationDurationSlow = 500;
  
  // Pagination
  static const int paginationLimit = 20;
  
  // Date Formats
  static const String dateFormatDisplay = 'MMMM dd, yyyy';
  static const String dateFormatDatabase = 'yyyy-MM-dd';
  static const String timeFormatDisplay = 'hh:mm a';
  static const String timeFormatDatabase = 'HH:mm:ss';
  static const String dateTimeFormatDisplay = 'MMMM dd, yyyy hh:mm a';
  static const String dateTimeFormatDatabase = 'yyyy-MM-dd HH:mm:ss';
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorInvalidCredentials = 'Invalid username or password.';
  static const String errorUsernameTaken = 'Username is already taken.';
  static const String errorEmptyFields = 'Please fill in all required fields.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordLength = 'Password must be at least 6 characters long.';
  static const String errorPasswordMatch = 'Passwords do not match.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorDatabaseOperation = 'Database operation failed.';
  
  // Success Messages
  static const String successLogin = 'Login successful.';
  static const String successRegister = 'Registration successful.';
  static const String successLogout = 'Logout successful.';
  static const String successEmployeeAdd = 'Employee added successfully.';
  static const String successEmployeeUpdate = 'Employee updated successfully.';
  static const String successEmployeeDelete = 'Employee deleted successfully.';
  static const String successAttendanceClockIn = 'Clock in successful.';
  static const String successAttendanceClockOut = 'Clock out successful.';
  static const String successLeaveRequest = 'Leave request submitted successfully.';
  static const String successLeaveApprove = 'Leave request approved.';
  static const String successLeaveReject = 'Leave request rejected.';
  static const String successLeaveCancel = 'Leave request cancelled.';
  static const String successDepartmentAdd = 'Department added successfully.';
  static const String successDepartmentUpdate = 'Department updated successfully.';
  static const String successDepartmentDelete = 'Department deleted successfully.';
  
  // Confirmation Messages
  static const String confirmDeleteEmployee = 'Are you sure you want to delete this employee?';
  static const String confirmDeleteDepartment = 'Are you sure you want to delete this department?';
  static const String confirmCancelLeave = 'Are you sure you want to cancel this leave request?';
  static const String confirmLogout = 'Are you sure you want to logout?';
  
  // Button Text
  static const String buttonLogin = 'Login';
  static const String buttonRegister = 'Register';
  static const String buttonLogout = 'Logout';
  static const String buttonSave = 'Save';
  static const String buttonUpdate = 'Update';
  static const String buttonDelete = 'Delete';
  static const String buttonCancel = 'Cancel';
  static const String buttonApprove = 'Approve';
  static const String buttonReject = 'Reject';
  static const String buttonSubmit = 'Submit';
  static const String buttonClockIn = 'Clock In';
  static const String buttonClockOut = 'Clock Out';
  static const String buttonAdd = 'Add';
  static const String buttonEdit = 'Edit';
  static const String buttonView = 'View';
  static const String buttonYes = 'Yes';
  static const String buttonNo = 'No';
  static const String buttonContinue = 'Continue';
  static const String buttonBack = 'Back';
  
  // Screen Titles
  static const String titleLogin = 'Login';
  static const String titleRegister = 'Register';
  static const String titleDashboard = 'Dashboard';
  static const String titleEmployees = 'Employees';
  static const String titleEmployeeDetails = 'Employee Details';
  static const String titleAddEmployee = 'Add Employee';
  static const String titleEditEmployee = 'Edit Employee';
  static const String titleAttendance = 'Attendance';
  static const String titleLeaveRequests = 'Leave Requests';
  static const String titleLeaveRequestDetails = 'Leave Request Details';
  static const String titleAddLeaveRequest = 'New Leave Request';
  static const String titleDepartments = 'Departments';
  static const String titleAddDepartment = 'Add Department';
  static const String titleEditDepartment = 'Edit Department';
  static const String titleProfile = 'Profile';
  static const String titleSettings = 'Settings';
  static const String titleNotifications = 'Notifications';
  static const String titleReports = 'Reports';
  
  // Form Labels
  static const String labelUsername = 'Username';
  static const String labelPassword = 'Password';
  static const String labelConfirmPassword = 'Confirm Password';
  static const String labelFirstName = 'First Name';
  static const String labelLastName = 'Last Name';
  static const String labelEmail = 'Email';
  static const String labelPhone = 'Phone';
  static const String labelAddress = 'Address';
  static const String labelDateOfBirth = 'Date of Birth';
  static const String labelGender = 'Gender';
  static const String labelJobTitle = 'Job Title';
  static const String labelDepartment = 'Department';
  static const String labelManager = 'Manager';
  static const String labelHireDate = 'Hire Date';
  static const String labelSalary = 'Salary';
  static const String labelIsActive = 'Active';
  static const String labelLeaveType = 'Leave Type';
  static const String labelStartDate = 'Start Date';
  static const String labelEndDate = 'End Date';
  static const String labelReason = 'Reason';
  static const String labelStatus = 'Status';
  static const String labelNotes = 'Notes';
  static const String labelDepartmentName = 'Department Name';
  static const String labelDepartmentDescription = 'Description';
  static const String labelRole = 'Role';
  static const String labelSearch = 'Search';
  static const String labelFilter = 'Filter';
  static const String labelSort = 'Sort';
  static const String labelDate = 'Date';
  static const String labelTime = 'Time';
  
  // Placeholder Text
  static const String placeholderSearch = 'Search...';
  static const String placeholderUsername = 'Enter username';
  static const String placeholderPassword = 'Enter password';
  static const String placeholderConfirmPassword = 'Confirm password';
  static const String placeholderFirstName = 'Enter first name';
  static const String placeholderLastName = 'Enter last name';
  static const String placeholderEmail = 'Enter email address';
  static const String placeholderPhone = 'Enter phone number';
  static const String placeholderAddress = 'Enter address';
  static const String placeholderJobTitle = 'Enter job title';
  static const String placeholderSalary = 'Enter salary';
  static const String placeholderReason = 'Enter reason for leave';
  static const String placeholderNotes = 'Enter notes';
  static const String placeholderDepartmentName = 'Enter department name';
  static const String placeholderDepartmentDescription = 'Enter department description';
  
  // Empty State Messages
  static const String emptyEmployees = 'No employees found.';
  static const String emptyAttendance = 'No attendance records found.';
  static const String emptyLeaveRequests = 'No leave requests found.';
  static const String emptyDepartments = 'No departments found.';
  static const String emptyNotifications = 'No notifications found.';
  static const String emptySearchResults = 'No results found.';
  
  // Tab Labels
  static const String tabOverview = 'Overview';
  static const String tabDetails = 'Details';
  static const String tabAttendance = 'Attendance';
  static const String tabLeave = 'Leave';
  static const String tabPerformance = 'Performance';
  static const String tabDocuments = 'Documents';
  static const String tabPending = 'Pending';
  static const String tabApproved = 'Approved';
  static const String tabRejected = 'Rejected';
  static const String tabAll = 'All';
  
  // Navigation Labels
  static const String navDashboard = 'Dashboard';
  static const String navEmployees = 'Employees';
  static const String navAttendance = 'Attendance';
  static const String navLeave = 'Leave';
  static const String navReports = 'Reports';
  static const String navSettings = 'Settings';
  
  // Chart Labels
  static const String chartAttendance = 'Attendance Overview';
  static const String chartLeave = 'Leave Overview';
  static const String chartDepartments = 'Department Distribution';
  static const String chartSalary = 'Salary Distribution';
  
  // Report Types
  static const String reportAttendance = 'Attendance Report';
  static const String reportLeave = 'Leave Report';
  static const String reportEmployee = 'Employee Report';
  static const String reportDepartment = 'Department Report';
}
