enum NotificationTemplateType {
  AdminFileOperation,
  CustomerFileOperation,
  AdminConfirmPeriod,
  CustomerClosePeriod,
  AdminTaskFileOperation,
  CustomerTaskFileOperation,
  CommonBoardInvate,
  CommonTaskInvate,
  CommonInvate,
  commonTaskDelete,
  commonDelete,
  CalendarInvite,
  CalendarAdd,
  CalendarRemove,
  TaskComment,
  Meeting,
  Message,
  Task,
  ChatMessage
}

/*      AdminFileOperation = 1,
        CustomerFileOperation = 2,
        AdminConfirmPeriod = 3,
        CustomerClosePeriod = 4,
        AdminTaskFileOperation = 5,
        CustomerTaskFileOperation = 6,
        CommonBoardInvate = 7, /api/common/ConfirmInviteUsersCommonBoard
        CommonTaskInvate = 8, /api/todo/ConfirmInviteUsersCommonTask
        CommonInvate = 9,     UpdateInviteProcess
        commonTaskDelete = 10,
        commonDelete = 11,
        CalendarInvite = 12,
        CalendarAdd = 13,
        CalendarRemove = 14,
        TaskComment = 15,       done
        Meeting = 16,
        Message = 17,
        Task = 18,
        ChatMessage = 19*/

extension FileManagerTypeExtension on NotificationTemplateType {

  int get typeId {
    return this.index + 1;
  }


}
