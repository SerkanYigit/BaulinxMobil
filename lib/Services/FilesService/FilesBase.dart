import 'package:undede/model/Common/DataLayoutAPI.dart';
import 'package:undede/model/Files/FilesForDirectory.dart';
import 'package:undede/model/Files/UploadFiles.dart';

abstract class FilesBase {
  Future<FilesForDirectory> GetFilesByUserIdForDirectory(
      Map<String, String> header,
      {int userId,
      int customerId,
      int moduleType,
      String directory,
      int page});

  Future<bool> CreateDirectory(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int ModuleTypeId,
      int OwnerId,
      String DirectoryName});

  Future<DirectoryItem> UploadFiles(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int ModuleTypeId,
      Files files,
      int OwnerId,
      bool IsCombine,
      String CombineFileName});

  Future<bool> UploadFilesToPrivate(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int ModuleTypeId,
      Files files,
      int OwnerId,
      bool IsCombine,
      String CombineFileName});

  Future<bool> RenameDirectory(Map<String, String> header,
      {int UserId,
      int ModuleTypeId,
      String DirectoryName,
      String NewDirectoryName,
      int SourceOwnerId});

  Future<bool> RenameFile(Map<String, String> header,
      {int UserId, int FileId, String NewFileName});

  Future<bool> DeleteDirectory(Map<String, String> header,
      {int UserId, int CustomerId, int ModuleTypeId, String DirectoryName});

  Future<bool> DeleteFile(Map<String, String> header, {int UserId, int FileId});
  Future<bool> DeleteMultiFileAndDirectory(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int ModuleTypeId,
      List<String> SourceDirectoryNameList,
      List<int> FileIdList,
      int SourceOwnerId});
  Future<bool> SendEMail(Map<String, String> header,
      {int UserId,
      String Receivers,
      String Subject,
      String Message,
      List<int> Attachtments,
      int Type,
      int UserEmailId,
      String Password});

  Future<bool> MoveDirectoryAndFile(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int TargetModuleTypeId,
      String TargetDirectoryName,
      int SourceModuleTypeId,
      List<String> SourceDirectoryNameList,
      List<int> FileIdList,
      int TargetOwnerId,
      int SourceOwnerId});

  Future<DataLayoutAPI> CopyDirectoryAndFile(Map<String, String> header,
      {int UserId,
      int CustomerId,
      int TargetModuleTypeId,
      String TargetDirectoryName,
      int SourceModuleTypeId,
      List<String> SourceDirectoryNameList,
      List<int> FileIdList,
      List<int> TargetOwnerIdList,
      int SourceOwnerId});

  Future<FilesResponse> GetFilesByUserIdForLabels(
    Map<String, String> header, {
    int userId,
    int customerId,
    int moduleType,
    String keyword = "",
    int pageIndex = 0,
    String endDate,
    String startDate,
    int isPaid = 0,
    int targetAccount = 0,
    List<int> labelIds = const [5],
  });
}
