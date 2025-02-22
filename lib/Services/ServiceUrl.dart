import 'package:flutter/foundation.dart';

class ServiceUrl {
  static final String baseUrlShareWork =
      kDebugMode ? "https://api.baulinx.de/" : "https://api.baulinx.de/";
  //"http://apiv2.vir2ell-office.com"
  //"http://api-test.vir2ell-office.com"
  final String login = baseUrlShareWork + "/api/user/Login";

  final String register = baseUrlShareWork + "/api/user/CreateUser";

  final LogOut = baseUrlShareWork + "/api/user/LogOut";
  final verificationCheck = baseUrlShareWork + "/api/user/VerificationCheck";
  final addTempUser = baseUrlShareWork + "/api/user/AddTempUser";

  final String updateUserInfo = baseUrlShareWork + "/Account/UpdateUserInfo";

  final String setUserToken = baseUrlShareWork + "/Account/SetUserToken";

  final String deleteUserToken = baseUrlShareWork + "/Account/DeleteUserToken";

  final String getCountryList = baseUrlShareWork + "/Account/GetCountryList";

  final String getCityList = baseUrlShareWork + "/Account/GetCityList";

  final String getDistrictList = baseUrlShareWork + "/Account/GetDistrictList";

  final String getStreetList = baseUrlShareWork + "/Account/GetStreetList";

  final String getUserAdressList =
      baseUrlShareWork + "/Account/GetUserAdressList";

  final String getComments = baseUrlShareWork + "/Account/GetComments";

  final String forgotPasswordConfirm =
      baseUrlShareWork + "/Account/ForgotPasswordConfirm";

  final String forceUpdateCheck =
      baseUrlShareWork + "/Account/ForceUpdateCheck";

  final String getNotificationList =
      baseUrlShareWork + "/Account/GetNotificationList";

  final String insertComment = baseUrlShareWork + "/Account/InsertComment";

  final String getUserAdress = baseUrlShareWork + "/Account/GetUserAdress";

  final String insertOrUpdateUserAdress =
      baseUrlShareWork + "/Account/InsertOrUpdateUserAdress";

  final String changeProfilePhoto =
      baseUrlShareWork + "/Account/ChangeProfilePhoto";

  final String getOffice = baseUrlShareWork + "/Service/GetOffice";

  final String getServiceRequestOfferList =
      baseUrlShareWork + "/Service/GetServiceRequestOfferList";

  final String getServicesWithPhoto =
      baseUrlShareWork + "/Service/GetServicesWithPhoto";

  final String getOfficeOrder = baseUrlShareWork + "/Service/GetOfficeOrder";

  final String getTopOffices = baseUrlShareWork + "/Service/GetTopOffices";

  final String insertOrUpdateServiceRequestOffer =
      baseUrlShareWork + "/Service/InsertOrUpdateServiceRequestOffer";

  final String confirmOrder = baseUrlShareWork + "/Service/ConfirmOrder";

  final String getServiceRequestListWithServiceId =
      baseUrlShareWork + "/Service/GetServiceRequestListWithServiceId";

  final String getServiceRequestListWithUserId =
      baseUrlShareWork + "/Service/GetServiceRequestListWithUserId";

  final String editOfficeService =
      baseUrlShareWork + "/Service/EditOfficeService";

  final String insertOfficeImages =
      baseUrlShareWork + "/Service/InsertOfficeImages";

  final String getDepartment =
      baseUrlShareWork + "/Department/getdepartmentlist";

  final String getCustomers = baseUrlShareWork + "/Customer/getcustomerlist";

  final String getFilesByUserIdForDirectory =
      baseUrlShareWork + "/File/GetFilesByUserIdForDirectory";

  final String filesUpload = baseUrlShareWork + "/File/UploadFiles";

  final String fileRename = baseUrlShareWork + "/File/FileRename";

  final String addNewCustomer = baseUrlShareWork + "/Customer/addcustomer";

  final String getCustomeList = baseUrlShareWork + "/Customer/getcustomerlist";

  final String getProjectList = baseUrlShareWork + "/Project/GetProjects";

  final String getChatListWithoutMessages =
      baseUrlShareWork + "/Chat/GetChatListWithoutMessages";

  final String insertGroupChat = baseUrlShareWork + "/Chat/InsertGroupChat";

  // final String getChat = baseUrlShareWork + "/Chat/GetChat";

  final String insertChat = baseUrlShareWork + "/Chat/InsertChat";

  final String insertChatMessage = baseUrlShareWork + "/Chat/InsertChatMessage";

  final String chatFileUpload = baseUrlShareWork + "/Chat/FileUpload";

  //common
  final String getListCommonGroup =
      baseUrlShareWork + "/api/common/GetAllCommonGroupList";
  final String getAllCommons = baseUrlShareWork + "/api/common/getAllCommons";
  final String getCommons = baseUrlShareWork + "/api/common/getCommons";
  final String getGroupById = baseUrlShareWork + "/api/common/GetGroupById";
  final String getPublicMeetings =
      baseUrlShareWork + "/api/common/GetPublicMeetings";
  final String getInviteUserList =
      baseUrlShareWork + "/api/common/GetInviteUserList";
  final String careateOrJoinMetting =
      baseUrlShareWork + "/api/meeting/CareateOrJoinMetting";
  final String endMeeting = baseUrlShareWork + "/api/meeting/EndMeeting";
  final String insertCommon = baseUrlShareWork + "/api/common/InsertCommon";
  final String insertCommonGroup =
      baseUrlShareWork + "/api/common/InsertCommonGroup";
  final String getDefinedRoleList =
      baseUrlShareWork + "/api/common/GetDefinedRoleList";
  final String confirmInviteUsersCommonBoard =
      baseUrlShareWork + "/api/common/ConfirmInviteUsersCommonBoard";
  final String inviteUsersCommonBoard =
      baseUrlShareWork + "/api/common/InviteUsersCommonBoard";

  final String getCommonUserList =
      baseUrlShareWork + "/api/common/GetCommonUserList";
  final String changeCommonGroup =
      baseUrlShareWork + "/api/common/ChangeCommonGroup";
  final String copyCommon = baseUrlShareWork + "/api/common/CopyCommon";
  final String getCommonGroupBackground =
      baseUrlShareWork + "/api/common/GetCommonGroupBackground";
  final String commonInvite = baseUrlShareWork + "/api/common/CommonInvite";
  final String commonInviteList =
      baseUrlShareWork + "/api/common/CommonInviteList";
  final String deleteCommon = baseUrlShareWork + "/api/common/DeleteCommon";
  final String deleteCommonGroup =
      baseUrlShareWork + "/api/common/DeleteCommonGroup";
  final String getPermissionList =
      baseUrlShareWork + "/api/common/GetPermissionList";
  final String updateCommon = baseUrlShareWork + "/api/common/UpdateCommon";
  final String updateCommonGroup =
      baseUrlShareWork + "/api/common/UpdateCommonGroup";

  final String getPermissionListByCategoryId =
      baseUrlShareWork + "/api/common/GetPermissionListByCategoryId";
  final String insertOrUpdateDefinedRole =
      baseUrlShareWork + "/api/common/InsertOrUpdateDefinedRole";
  final String deleteDefinedRole =
      baseUrlShareWork + "/api/common/DeleteDefinedRole";
  final String getPublicCategory =
      baseUrlShareWork + "/api/common/GetPublicCategory";
  final String getOpenMeetings =
      baseUrlShareWork + "/api/meeting/GetOpenMeetings";
  final String inviteUsersCommonBoardWithRole =
      baseUrlShareWork + "/api/common/InviteUsersCommonBoardWithRole";

  //todoo
  final String getCommonTodos = baseUrlShareWork + "/api/todo/GetCommonTodos";
  //! Notelari getiriyor. Bu api degisecek
  final String getGenericTodos = baseUrlShareWork + "/api/todo/GetGenericTodos";
  final String getGenericCustomerTodos =
      baseUrlShareWork + "/api/todo/getGenericCustomerTodos";
  final String insertCommonTodos =
      baseUrlShareWork + "/api/todo/InsertCommonTodos";
  final String getTodoUserList = baseUrlShareWork + "/api/todo/GetTodoUserList";
  final String updateCommonTodos =
      baseUrlShareWork + "/api/todo/UpdateCommonTodos";
  final String getTodoComments = baseUrlShareWork + "/api/todo/GetTodoComments";
  final String likeCommon = baseUrlShareWork + "/api/common/Like";
  final String insertTodoComment =
      baseUrlShareWork + "/api/todo/InsertTodoComment";
  final String deleteTodo = baseUrlShareWork + "/api/todo/DeleteTodo";
  final String copyTodo = baseUrlShareWork + "/api/todo/CopyTodo";
  final String moveTodo = baseUrlShareWork + "/api/todo/MoveTodo";
  final String InviteUsersCommonTask =
      baseUrlShareWork + "/api/todo/InviteUsersCommonTask";
  final String ConfirmInviteUsersCommonTask =
      baseUrlShareWork + "/api/todo/ConfirmInviteUsersCommonTask";
  final String getTodo = baseUrlShareWork + "/api/todo/GetTodoById";
  final String getTodoCheckList =
      baseUrlShareWork + "/api/todo/GetTodoCheckList";
  final String insertOrUpdateTodoCheckList =
      baseUrlShareWork + "/api/todo/InsertOrUpdateTodoCheckList";
  final String deleteTodoCheckList =
      baseUrlShareWork + "/api/todo/DeleteTodoCheckList";

  //user
  final String getAdminCustomer =
      baseUrlShareWork + "/api/user/GetAdminCustomer";

  final userProfilUpdate = baseUrlShareWork + "/api/user/UserProfilUpdate";

  final changeUserPassword = baseUrlShareWork + "/api/user/ChangeUserPassword";
  final getAllActiveUser = baseUrlShareWork + "/api/user/GetAllActiveUser";
  final String forgotPassword = baseUrlShareWork + "/api/user/ForgetPassword";
  final String forgotPasswordDone =
      baseUrlShareWork + "/api/user/ForgetPasswordDone";
  final String getCompanyType = baseUrlShareWork + "/api/user/GetCompanyType";
  final String updateCustomer = baseUrlShareWork + "/api/user/UpdateCustomer";
  final String getCustomer = baseUrlShareWork + "/api/user/GetCustomer";
  final String getDetailAndSendNotification =
      baseUrlShareWork + "/api/user/GetDetailAndSendNotification";
  final String saveSignature =
      baseUrlShareWork + "/api/user/SaveSignatureContent";
  final String getSignatureContent =
      baseUrlShareWork + "/api/user/GetSignatureContent";
  //chat

  final String getUserList = baseUrlShareWork + "/api/chat/GetUserList";
  final String addUsersToAdministration =
      baseUrlShareWork + "/api/user/AddUsersToAdministration";
  final String deleteUsersToAdministration =
      baseUrlShareWork + "/api/user/DeleteUsersToAdministration";
  final String addUsersToCustomer =
      baseUrlShareWork + "/api/user/AddUsersToCustomer";
  final String deleteUsersToCustomer =
      baseUrlShareWork + "/api/user/DeleteUsersToCustomer";
  final String getConnectedCustomer =
      baseUrlShareWork + "/api/user/GetConnectedCustomer";
  final String addConnectedCustomer =
      baseUrlShareWork + "/api/user/AddConnectedCustomer";
  final String deleteConnectedCustomer =
      baseUrlShareWork + "/api/user/DeleteConnectedCustomer";
  final String getMyPersons = baseUrlShareWork + "/api/user/GetMyPersons";
  final String getChat = baseUrlShareWork + "/api/chat/GetChat";

  final String postChatMessageSave =
      baseUrlShareWork + "/api/chat/ChatMessageSave";
  final String deleteChatMessage =
      baseUrlShareWork + "/api/chat/DeleteChatMessage";
  final String setChatUnread = baseUrlShareWork + "/api/chat/SetChatUnread";
  //Gruop Chat and Public
  final String getPublicChatList =
      baseUrlShareWork + "/api/chat/GetPublicChatList";
  final String getGroupChatUserList =
      baseUrlShareWork + "/api/chat/GetGroupChatUserList";
  final String updateChatGroupTitle =
      baseUrlShareWork + "/api/chat/UpdateChatGroupTitle";
  final String updateGroupChatPicture =
      baseUrlShareWork + "/api/chat/UpdateGroupChatPicture";
  final String removeUserFromGroupChat =
      baseUrlShareWork + "/api/chat/removeUserFromGroupChat";
  final String insertChatGroupUser =
      baseUrlShareWork + "/api/chat/InsertChatGroupUser";
  final String newGroupChat = baseUrlShareWork + "/api/chat/NewGroupChat";
  final String newPublicChat = baseUrlShareWork + "/api/chat/NewPublicChat";
  final String getUnreadCountByUserId =
      baseUrlShareWork + "/api/chat/GetUnreadCountByUserId";
  final String forwardMessages = baseUrlShareWork + "/api/chat/ForwardMessages";
  //invoice
  final getInvoiceListRequestUrl =
      baseUrlShareWork + '/api/invoice/GetInvoiceList';
  final invoiceFileInsert = baseUrlShareWork + '/api/invoice/InvoiceFileInsert';
  final invoiceFileListInsert =
      baseUrlShareWork + '/api/invoice/invoiceFileListInsert';
  final getInvoiceTargetAccountList =
      baseUrlShareWork + '/api/invoice/GetInvoiceTargetAccountList';
  final invoiceMultiUpdate =
      baseUrlShareWork + '/api/invoice/InvoiceMultiUpdateAllFields';
  final getAccountTypeList =
      baseUrlShareWork + '/api/invoice/GetAccountTypeList';
  final getTaxAccountList = baseUrlShareWork + '/api/invoice/GetTaxAccountList';
  final deleteInvoice = baseUrlShareWork + '/api/invoice/DeleteInvoice';
  final deleteInvoiceList = baseUrlShareWork + '/api/invoice/DeleteInvoiceList';
  final closePeriod = baseUrlShareWork + '/api/invoice/ClosePeriod';
  final openPeriod = baseUrlShareWork + '/api/invoice/OpenPeriod';
  final confirmPeriod = baseUrlShareWork + '/api/invoice/ConfirmPeriod';
  final getInvoicePeriodList =
      baseUrlShareWork + '/api/invoice/GetInvoicePeriodList';
  final getInvoiceSummary = baseUrlShareWork + '/api/invoice/GetInvoiceSummary';
  final getInvoiceListWithOutFile =
      baseUrlShareWork + '/api/invoice/GetInvoiceListWithOutFile';
  final getInvoiceSummaryAll =
      baseUrlShareWork + '/api/invoice/GetInvoiceSummaryAll';
  final getInvoicePositions =
      baseUrlShareWork + '/api/invoice/GetInvoicePositions';
  final addInvoicePositions =
      baseUrlShareWork + '/api/invoice/AddInvoicePositions';
  final getInvoiceHandMadeInvoice =
      baseUrlShareWork + '/api/invoice/GetInvoiceHandMadeInvoice';
  final getAllOffer = baseUrlShareWork + '/api/invoice/GetAllOffer';
  final insertOffer = baseUrlShareWork + '/api/invoice/InsertOffer';
  final addOfferPositions = baseUrlShareWork + '/api/invoice/AddOfferPositions';
  final getOfferPositions = baseUrlShareWork + '/api/invoice/GetOfferPositions';
  //calendar
  final getCalendarByUserId =
      baseUrlShareWork + "/api/calendar/GetCalendarByUserId";
  final getCalendarDetail =
      baseUrlShareWork + "/api/calendar/GetCalendarDetail";
  final postAddorUpdateCalendar =
      baseUrlShareWork + "/api/calendar/InsertOrUpdateCalendar";
  final postAddCalendarAppointment =
      baseUrlShareWork + "/api/calendar/AddCalendarAppointment";
  final deleteCalendar = baseUrlShareWork + "/api/calendar/DeleteCalendar/";
  final deleteDeleteCalendarAppointment =
      baseUrlShareWork + "/api/calendar/DeleteCalendarAppointment/";
  final deleteTodoAppointment =
      baseUrlShareWork + "/api/calendar/DeleteTodoAppointment/";
  final addUserToCalendar =
      baseUrlShareWork + "/api/calendar/AddUserToCalendar";
  final confirmInviteCalendarUser =
      baseUrlShareWork + "/api/calendar/ConfirmInviteCalendarUser";
  //files
  final String GetFilesByUserIdForDirectory =
      baseUrlShareWork + "/api/files/GetFilesByUserIdForDirectory";
  final String GetFilesByUserIdForLabels =
      baseUrlShareWork + "/api/files/OCRSearch";

  final createDirectory = baseUrlShareWork + "/api/files/CreateDirectory";
  final uploadFiles = baseUrlShareWork + "/api/files/UploadFiles";
  final uploadFilesToPrivate =
      baseUrlShareWork + "/api/files/UploadPrivateImages";
  final renameFile = baseUrlShareWork + "/api/files/FileRename";
  final deleteFile = baseUrlShareWork + "/api/files/DeleteFile";
  final renameDirectory = baseUrlShareWork + "/api/files/RenameDirectory";
  final deleteDirectory = baseUrlShareWork + "/api/files/DeleteDirectory";
  final deleteMultiFileAndDirectory =
      baseUrlShareWork + "/api/files/DeleteMultiFileAndDirectory";
  final sendEMail = baseUrlShareWork + "/api/files/SendEMail";
  final moveDirectoryAndFile =
      baseUrlShareWork + "/api/files/MoveDirectoryAndFile";
  final copyDirectoryAndFile =
      baseUrlShareWork + "/api/files/CopyDirectoryAndFile";
  final oCRSearch = baseUrlShareWork + "/api/files/OCRSearch";

  //Label
  final getInvoiceCompany =
      baseUrlShareWork + "/api/invoice/GetInvoiceCompany?userId=";
  final getLabelByUserId = baseUrlShareWork + "/api/label/GetLabelByUserId";

  final insertLabel = baseUrlShareWork + "/api/label/InsertLabel";
  final updateLabel = baseUrlShareWork + "/api/label/UpdateLabel";
  final deleteLabel = baseUrlShareWork + "/api/label/DeleteLabel";
  final String getTodoLabelList =
      baseUrlShareWork + "/api/label/GetTodoLabelList";
  final insertTodoLabel = baseUrlShareWork + "/api/label/InsertTodoLabel";
  final insertTodoLabelList =
      baseUrlShareWork + "/api/label/InsertTodoLabelList";
  final insertFileListLabelList =
      baseUrlShareWork + "/api/label/InsertFileListLabelList";
  //Notification
  final getNotification =
      baseUrlShareWork + "/api/notification/GetNotificationList";
  final updateInviteProcess =
      baseUrlShareWork + "/api/notification/UpdateInviteProcess";
  final updateAllNotificationRead =
      baseUrlShareWork + "/api/notification/UpdateAllNotificationRead";
  final getFileLabelList = baseUrlShareWork + "/api/label/GetFileLabelList";
  //UserEmail
  final getUserEmailList = baseUrlShareWork + "/api/user/GetUserEmailList";
  final getEmailTypeList = baseUrlShareWork + "/api/user/GetEmailTypeList";
  final userEmailCreate = baseUrlShareWork + "/api/user/UserEmailCreate";
  final updateUserEmail = baseUrlShareWork + "/api/user/UpdateUserEmail";
  final userEmailDelete = baseUrlShareWork + "/api/user/UserEmailDelete";

  //Message
  final getMessageByUserId =
      baseUrlShareWork + "/api/message/GetMessageByUserId";
  final sendMessage = baseUrlShareWork + "/api/message/SendMessage";
  final sendMessageNew = baseUrlShareWork + "/api/message/SendEmail";
  final deleteMessage = baseUrlShareWork + "/api/message/DeleteMessage";
  final setMessageRead = baseUrlShareWork + "/api/message/SetMessageRead";
  final getMessageDetail = baseUrlShareWork + "/api/message/GetMessageDetail";
  final getMessageCategory =
      baseUrlShareWork + "/api/messagecategory/GetMessageCategory";
  final getUserEmails = baseUrlShareWork + "/api/user/GetUserEmails";
  final getMailFolders = baseUrlShareWork + "api/message/GetMailFolders";
  final getMails = baseUrlShareWork + "api/message/GetMails2";
  final getMailDetail = baseUrlShareWork + "api/message/GetInboxDetailMail2";

  //Search
  final getSearchResult = baseUrlShareWork + "/api/search/SearchResult";
  //Packages
  final getPackages = baseUrlShareWork + "/api/package/GetPackages";
  //Social
  final getSocialList = baseUrlShareWork + "/api/social/GetSocialList";
  final addOrUpdateSocial = baseUrlShareWork + "/api/social/AddOrUpdateSocial";
  final addOrUpdateSocialReply =
      baseUrlShareWork + "/api/social/AddOrUpdateSocialReply";
  final deleteSocial = baseUrlShareWork + "/api/social/DeleteSocial";
  final deleteSocialReply = baseUrlShareWork + "/api/social/DeleteSocialReply";
  //BlockReport
  final blockUser = baseUrlShareWork + "/api/blockreport/BlockUser";
  final unBlockUser = baseUrlShareWork + "/api/blockreport/UnBlockUser";
  final reportUser = baseUrlShareWork + "/api/blockreport/ReportUser";
  //CustomersBills
  final getCustomersBills =
      baseUrlShareWork + "/api/customersbills/GetCustomersBills";
  final insertOrUpdateCustomersBills =
      baseUrlShareWork + "/api/customersbills/InsertOrUpdateCustomersBills";
  final deleteCustomersBill =
      baseUrlShareWork + "/api/customersbills/DeleteCustomersBill";

  // OpenAı
  final getOpenAIChatMessages =
      baseUrlShareWork + "/api/openai/GetOpenAIChatMessages";
  final insertOpenAIChat = baseUrlShareWork + "/api/openai/SearchDocumentData";
  final deleteOpenAIChatMessage =
      baseUrlShareWork + "/api/openai/DeleteOpenAIChatMessage";
}
