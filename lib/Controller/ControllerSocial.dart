import 'package:get/get.dart';
import 'package:undede/Services/Social/SocialBase.dart';
import 'package:undede/Services/Social/SocialDB.dart';
import 'package:undede/model/Social/AddOrUpdateSocialReplyResult.dart';
import 'package:undede/model/Social/AddOrUpdateSocialResult.dart';
import 'package:undede/model/Social/SocialResult.dart';

class ControllerSocial extends GetxController implements SocialBase {
  SocialDB _socialDB = SocialDB();
  List<Social> socialData = [];
  List<Social> socialPost = [];
  List<Social> socialQuestion = [];
  @override
  Future<SocialResult> GetSocialList(Map<String, String> header,
      {int? UserId, int? Type, int? CategoryId, String? Search}) async {
    var value = await _socialDB.GetSocialList(header,
        UserId: UserId, Type: Type, CategoryId: CategoryId, Search: Search);
    socialData = value.social!;
    update();
    return value;
  }

  Future<SocialResult> GetSocialPost(Map<String, String> header,
      {int? UserId, int? Type, int? CategoryId, String? Search}) async {
    var value = await _socialDB.GetSocialList(header,
        UserId: UserId!, Type: 1, CategoryId: CategoryId!, Search: Search!);
    socialPost = value.social!;
    update();
    return value;
  }

  Future<SocialResult> GetSocialQuestion(Map<String, String> header,
      {int? UserId, int? Type, int? CategoryId, String? Search}) async {
    var value = await _socialDB.GetSocialList(header,
        UserId: UserId!, Type: 2, CategoryId: CategoryId!, Search: Search!);
    socialQuestion = value.social!;
    update();
    return value;
  }

  @override
  Future<AddOrUpdateSocialResult> AddOrUpdateSocial(Map<String, String> header,
      {int? Id, int? UserId, int? Type, int? CategoryId, String? Feed,}) async {
    return await _socialDB.AddOrUpdateSocial(header,
        Id: Id!, UserId: UserId!, Type: Type!, CategoryId: CategoryId!, Feed: Feed!,);
  }

  @override
  Future<AddOrUpdateSocialReplyResult> AddOrUpdateSocialReply(
      Map<String, String> header,
      {int? Id,
      int? UserId,
      int? SocialId,
      String? Feed}) async {
    return await _socialDB.AddOrUpdateSocialReply(header,
        Id: Id!, UserId: UserId!, SocialId: SocialId!, Feed: Feed!,);
  }

  @override
  Future<bool> DeleteSocial(Map<String, String> header, {int? Id}) async {
    return await _socialDB.DeleteSocial(header, Id: Id!);
  }

  @override
  Future<bool> DeleteSocialReply(Map<String, String> header, {int? Id}) async {
    return await _socialDB.DeleteSocialReply(header, Id: Id!);
  }
}
