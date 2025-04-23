import 'package:undede/model/OpenAI/GetOpenAIChatMessagesResult.dart';
import 'package:undede/model/OpenAI/InsertOpenAIChatResult.dart';

abstract class OpenAIBase {
  Future<InsertOpenAIChatResult> InsertOpenAIChat(Map<String, String> header,
      {int SenderId, String Message, String SelectedMessages});
  Future<GetOpenAIChatMessagesResult> GetOpenAIChatMessages(
      Map<String, String> header,
      {int UserId});
  Future<bool> DeleteOpenAIChatMessage(Map<String, String> header, {int id});
}
