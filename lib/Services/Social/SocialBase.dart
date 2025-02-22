import 'package:undede/model/Social/AddOrUpdateSocialResult.dart';
import 'package:undede/model/Social/AddOrUpdateSocialReplyResult.dart';
import 'package:undede/model/Social/SocialResult.dart';

abstract class SocialBase {
  Future<SocialResult> GetSocialList(Map<String, String> header,
      {int UserId, int Type, int CategoryId, String Search});
  Future<AddOrUpdateSocialResult> AddOrUpdateSocial(Map<String, String> header,
      {int Id, int UserId, int Type, int CategoryId, String Feed});
  Future<AddOrUpdateSocialReplyResult> AddOrUpdateSocialReply(
      Map<String, String> header,
      {int Id,
      int UserId,
      int SocialId,
      String Feed});
  Future<bool> DeleteSocial(Map<String, String> header, {int Id});
  Future<bool> DeleteSocialReply(Map<String, String> header, {int Id});
}
